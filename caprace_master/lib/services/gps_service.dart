import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../models/gps_point.dart';
import '../config/app_config.dart';
import '../utils/gps_utils.dart';

/// Service de gestion du GPS
class GPSService {
  static final GPSService instance = GPSService._init();
  
  GPSService._init();
  
  StreamSubscription<Position>? _positionStream;
  final StreamController<GPSPoint> _gpsController = StreamController<GPSPoint>.broadcast();
  final StreamController<String> _statusController = StreamController<String>.broadcast();
  
  GPSPoint? _lastValidPoint;
  bool _isActive = false;
  
  /// Stream des points GPS
  Stream<GPSPoint> get gpsStream => _gpsController.stream;
  
  /// Stream du statut GPS
  Stream<String> get statusStream => _statusController.stream;
  
  /// Vérifier si le GPS est actif
  bool get isActive => _isActive;
  
  /// Dernier point GPS valide
  GPSPoint? get lastPoint => _lastValidPoint;
  
  /// Vérifier les permissions de localisation
  Future<bool> checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;
    
    // Vérifier si le service de localisation est activé
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _statusController.add('Service de localisation désactivé');
      return false;
    }
    
    // Vérifier les permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _statusController.add('Permission de localisation refusée');
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      _statusController.add('Permission de localisation refusée définitivement');
      return false;
    }
    
    _statusController.add('Signal GPS actif');
    return true;
  }
  
  /// Démarrer l'acquisition GPS
  Future<bool> start() async {
    if (_isActive) return true;
    
    final hasPermission = await checkPermissions();
    if (!hasPermission) return false;
    
    try {
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0, // Recevoir toutes les mises à jour
        timeLimit: Duration(seconds: AppConfig.gpsUpdateIntervalSeconds),
      );
      
      _positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        _onPositionUpdate,
        onError: _onError,
      );
      
      _isActive = true;
      _statusController.add('Signal GPS actif');
      return true;
    } catch (e) {
      _statusController.add('Erreur GPS: $e');
      return false;
    }
  }
  
  /// Arrêter l'acquisition GPS
  Future<void> stop() async {
    await _positionStream?.cancel();
    _positionStream = null;
    _isActive = false;
    _statusController.add('GPS arrêté');
  }
  
  /// Gestion de la mise à jour de position
  void _onPositionUpdate(Position position) {
    final point = GPSPoint.fromPosition(
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: position.altitude,
      accuracy: position.accuracy,
      speed: position.speed,
      timestamp: position.timestamp ?? DateTime.now(),
    );
    
    // Filtrer les points invalides
    if (!point.isValid) {
      return;
    }
    
    // Filtrer les micro-mouvements si on a un point précédent
    if (_lastValidPoint != null) {
      final distance = GPSUtils.calculateDistance(
        _lastValidPoint!.latitude,
        _lastValidPoint!.longitude,
        point.latitude,
        point.longitude,
      );
      
      // Ignorer si mouvement < 0.5m (micro-mouvement)
      if (distance < AppConfig.minMovementMeters) {
        return;
      }
      
      // Détecter les sauts GPS brusques (> 100m en 1 seconde)
      if (distance > 100.0 && point.accuracy > 20.0) {
        // Point suspect, ne pas l'enregistrer
        return;
      }
    }
    
    // Point valide, le diffuser
    _lastValidPoint = point;
    _gpsController.add(point);
    
    // Mettre à jour le statut avec la précision
    _statusController.add(
      'Signal GPS actif (±${point.accuracy.toStringAsFixed(1)}m)'
    );
  }
  
  /// Gestion des erreurs
  void _onError(dynamic error) {
    _statusController.add('Erreur GPS: $error');
  }
  
  /// Obtenir la position actuelle (une seule fois)
  Future<GPSPoint?> getCurrentPosition() async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) return null;
      
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      return GPSPoint.fromPosition(
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
        accuracy: position.accuracy,
        speed: position.speed,
        timestamp: position.timestamp ?? DateTime.now(),
      );
    } catch (e) {
      _statusController.add('Erreur: $e');
      return null;
    }
  }
  
  /// Nettoyer les ressources
  void dispose() {
    _positionStream?.cancel();
    _gpsController.close();
    _statusController.close();
  }
}
