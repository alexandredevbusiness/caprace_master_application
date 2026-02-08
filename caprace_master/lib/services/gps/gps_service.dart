import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import '../../models/gps_point.dart';
import '../../utils/constants.dart';
import 'gps_filter.dart';
import 'distance_calculator.dart';

/// Qualité du signal GPS
enum GPSQuality {
  none,      // Aucun signal
  poor,      // Mauvais signal (accuracy > 20m)
  good,      // Bon signal (accuracy 10-20m)
  excellent  // Excellent signal (accuracy < 10m)
}

/// Service principal de gestion du GPS
/// Responsable de l'acquisition, du filtrage et du calcul de distance
class GPSService extends ChangeNotifier {
  // État
  bool _isTracking = false;
  Position? _currentPosition;
  GPSPoint? _lastValidPoint;
  GPSQuality _signalQuality = GPSQuality.none;
  double _totalDistance = 0.0;
  
  // Services
  final GPSFilter _filter = GPSFilter();
  final DistanceCalculator _calculator = DistanceCalculator();
  
  // Stream
  StreamSubscription<Position>? _positionStream;
  Timer? _acquisitionTimer;
  
  // Buffer pour écriture différée
  final List<GPSPoint> _pointsBuffer = [];
  Timer? _bufferFlushTimer;
  
  // Callbacks
  void Function(GPSPoint point)? onNewPoint;
  void Function(double distance)? onDistanceUpdate;
  void Function(GPSQuality quality)? onQualityChange;
  
  // Getters
  bool get isTracking => _isTracking;
  Position? get currentPosition => _currentPosition;
  GPSPoint? get lastValidPoint => _lastValidPoint;
  GPSQuality get signalQuality => _signalQuality;
  double get totalDistance => _totalDistance;
  List<GPSPoint> get bufferedPoints => List.unmodifiable(_pointsBuffer);
  
  /// Vérifier les permissions GPS
  Future<bool> checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifier si le service de localisation est activé
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('❌ Service de localisation désactivé');
      return false;
    }

    // Vérifier les permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('❌ Permission de localisation refusée');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('❌ Permission de localisation refusée définitivement');
      return false;
    }

    debugPrint('✅ Permissions GPS accordées');
    return true;
  }

  /// Démarrer le tracking GPS
  Future<bool> startTracking() async {
    if (_isTracking) {
      debugPrint('⚠️ Tracking déjà en cours');
      return true;
    }

    // Vérifier les permissions
    final hasPermission = await checkPermissions();
    if (!hasPermission) {
      return false;
    }

    try {
      // Configuration des paramètres de localisation
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0, // Pas de filtre de distance (on filtre manuellement)
      );

      // Démarrer le stream de positions
      _positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        _onPositionUpdate,
        onError: _onPositionError,
      );

      // Démarrer le timer de flush du buffer
      _bufferFlushTimer = Timer.periodic(
        const Duration(seconds: GPSConfig.diskWriteIntervalSeconds),
        _flushBuffer,
      );

      _isTracking = true;
      _totalDistance = 0.0;
      _lastValidPoint = null;
      _pointsBuffer.clear();
      
      debugPrint('✅ Tracking GPS démarré');
      notifyListeners();
      return true;
      
    } catch (e) {
      debugPrint('❌ Erreur lors du démarrage du tracking: $e');
      return false;
    }
  }

  /// Arrêter le tracking GPS
  Future<void> stopTracking() async {
    if (!_isTracking) {
      debugPrint('⚠️ Tracking déjà arrêté');
      return;
    }

    // Arrêter le stream
    await _positionStream?.cancel();
    _positionStream = null;

    // Arrêter le timer de flush
    _bufferFlushTimer?.cancel();
    _bufferFlushTimer = null;

    // Flush final du buffer
    if (_pointsBuffer.isNotEmpty) {
      _flushBuffer(null);
    }

    _isTracking = false;
    _currentPosition = null;
    _signalQuality = GPSQuality.none;
    
    debugPrint('✅ Tracking GPS arrêté - Distance totale: ${_totalDistance.toStringAsFixed(1)} km');
    notifyListeners();
  }

  /// Callback lors d'une nouvelle position
  void _onPositionUpdate(Position position) {
    _currentPosition = position;
    
    // Mettre à jour la qualité du signal
    _updateSignalQuality(position.accuracy);
    
    // Créer un point GPS
    final point = GPSPoint(
      timestamp: DateTime.now(),
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      speed: position.speed,
      altitude: position.altitude,
    );
    
    // Filtrer le point
    final isValid = _filter.filterPoint(point);
    
    if (isValid) {
      // Calculer la distance si on a un point précédent
      if (_lastValidPoint != null) {
        final distance = _calculator.calculateDistance(
          _lastValidPoint!.latitude,
          _lastValidPoint!.longitude,
          point.latitude,
          point.longitude,
        );
        
        // Vérifier que ce n'est pas un saut GPS
        if (distance <= GPSConfig.maximumJumpMeters) {
          _totalDistance += distance / 1000.0; // Convertir en km
          onDistanceUpdate?.call(_totalDistance);
          debugPrint('📏 Distance: +${distance.toStringAsFixed(1)}m | Total: ${_totalDistance.toStringAsFixed(1)}km');
        } else {
          debugPrint('⚠️ Saut GPS détecté: ${distance.toStringAsFixed(1)}m - point ignoré');
          return;
        }
      }
      
      // Sauvegarder comme dernier point valide
      _lastValidPoint = point;
      
      // Ajouter au buffer
      _pointsBuffer.add(point);
      
      // Notifier les listeners
      onNewPoint?.call(point);
      notifyListeners();
      
      debugPrint('📍 GPS: ${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)} | Accuracy: ${point.accuracy.toStringAsFixed(1)}m');
    } else {
      debugPrint('⚠️ Point GPS filtré (micro-mouvement ou mauvaise précision)');
    }
  }

  /// Callback en cas d'erreur de position
  void _onPositionError(dynamic error) {
    debugPrint('❌ Erreur GPS: $error');
    _signalQuality = GPSQuality.none;
    onQualityChange?.call(_signalQuality);
    notifyListeners();
  }

  /// Mettre à jour la qualité du signal GPS
  void _updateSignalQuality(double accuracy) {
    GPSQuality newQuality;
    
    if (accuracy < 10) {
      newQuality = GPSQuality.excellent;
    } else if (accuracy < 20) {
      newQuality = GPSQuality.good;
    } else {
      newQuality = GPSQuality.poor;
    }
    
    if (newQuality != _signalQuality) {
      _signalQuality = newQuality;
      onQualityChange?.call(_signalQuality);
      debugPrint('📡 Qualité GPS: ${_signalQuality.name}');
      notifyListeners();
    }
  }

  /// Flush le buffer vers le callback (appelé par TraceService)
  void _flushBuffer(Timer? timer) {
    if (_pointsBuffer.isEmpty) return;
    
    debugPrint('💾 Flush buffer: ${_pointsBuffer.length} points');
    // Le callback sera géré par TraceService qui s'abonnera aux points
    // Pour l'instant on garde les points dans le buffer
    // Ils seront nettoyés après écriture par TraceService
  }

  /// Vider le buffer après écriture
  void clearBuffer() {
    _pointsBuffer.clear();
  }

  /// Réinitialiser la distance totale
  void resetDistance() {
    _totalDistance = 0.0;
    _lastValidPoint = null;
    notifyListeners();
  }

  /// Obtenir la position actuelle (one-shot)
  Future<Position?> getCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'obtention de la position: $e');
      return null;
    }
  }

  @override
  void dispose() {
    stopTracking();
    _acquisitionTimer?.cancel();
    super.dispose();
  }
}
