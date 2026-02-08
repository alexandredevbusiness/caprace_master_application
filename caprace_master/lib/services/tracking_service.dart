import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/gps_point.dart';
import '../models/trace_data.dart';
import '../config/app_config.dart';
import '../utils/gps_utils.dart';
import 'gps_service.dart';

/// Service de gestion du tracking GPS (enregistrement TRACE)
class TrackingService {
  static final TrackingService instance = TrackingService._init();
  
  TrackingService._init();
  
  final GPSService _gpsService = GPSService.instance;
  StreamSubscription<GPSPoint>? _gpsSubscription;
  
  File? _traceFile;
  bool _isTracking = false;
  DateTime? _startTime;
  double _totalDistance = 0.0;
  GPSPoint? _lastPoint;
  final List<GPSPoint> _sessionPoints = [];
  
  final StreamController<double> _distanceController = StreamController<double>.broadcast();
  final StreamController<int> _pointCountController = StreamController<int>.broadcast();
  
  /// Stream de la distance totale
  Stream<double> get distanceStream => _distanceController.stream;
  
  /// Stream du nombre de points
  Stream<int> get pointCountStream => _pointCountController.stream;
  
  /// Vérifier si le tracking est actif
  bool get isTracking => _isTracking;
  
  /// Obtenir la distance totale
  double get totalDistance => _totalDistance;
  
  /// Obtenir le nombre de points enregistrés
  int get pointCount => _sessionPoints.length;
  
  /// Démarrer le tracking
  Future<bool> start(int crewNumber, int day) async {
    if (_isTracking) return true;
    
    try {
      // Créer le fichier TRACE
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'TRACE_EQ${crewNumber}_J${day.toString().padLeft(2, '0')}.txt';
      _traceFile = File('${directory.path}/$fileName');
      
      // Créer ou vider le fichier
      await _traceFile!.writeAsString('');
      
      // Écrire l'en-tête
      await _traceFile!.writeAsString(
        'timestamp,latitude,longitude,altitude,accuracy,speed\n',
        mode: FileMode.append,
      );
      
      // Démarrer le GPS
      final started = await _gpsService.start();
      if (!started) return false;
      
      // S'abonner au flux GPS
      _gpsSubscription = _gpsService.gpsStream.listen(_onGPSPoint);
      
      _isTracking = true;
      _startTime = DateTime.now();
      _totalDistance = 0.0;
      _lastPoint = null;
      _sessionPoints.clear();
      
      _distanceController.add(_totalDistance);
      _pointCountController.add(0);
      
      return true;
    } catch (e) {
      print('Erreur démarrage tracking: $e');
      return false;
    }
  }
  
  /// Arrêter le tracking
  Future<void> stop() async {
    if (!_isTracking) return;
    
    await _gpsSubscription?.cancel();
    _gpsSubscription = null;
    
    await _gpsService.stop();
    
    _isTracking = false;
    _traceFile = null;
  }
  
  /// Gestion d'un nouveau point GPS
  void _onGPSPoint(GPSPoint point) async {
    if (!_isTracking || _traceFile == null) return;
    
    try {
      // Calculer la distance depuis le dernier point
      if (_lastPoint != null) {
        final distance = GPSUtils.calculateDistance(
          _lastPoint!.latitude,
          _lastPoint!.longitude,
          point.latitude,
          point.longitude,
        );
        
        // Ajouter à la distance totale (en km)
        _totalDistance += distance / 1000.0;
        _distanceController.add(_totalDistance);
      }
      
      // Enregistrer le point dans le fichier
      await _traceFile!.writeAsString(
        '${point.toTraceString()}\n',
        mode: FileMode.append,
      );
      
      // Ajouter à la session
      _sessionPoints.add(point);
      _pointCountController.add(_sessionPoints.length);
      
      _lastPoint = point;
    } catch (e) {
      print('Erreur enregistrement point: $e');
    }
  }
  
  /// Obtenir les données de trace de la session
  TraceData? getTraceData(int crewNumber, int day) {
    if (_startTime == null) return null;
    
    return TraceData(
      crewNumber: crewNumber,
      day: day,
      startTime: _startTime!,
      endTime: _isTracking ? null : DateTime.now(),
      points: List.from(_sessionPoints),
      totalDistance: _totalDistance,
    );
  }
  
  /// Charger un fichier TRACE existant
  Future<TraceData?> loadTraceFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;
      
      final content = await file.readAsString();
      final lines = content.split('\n');
      
      // Extraire les infos du nom de fichier
      final fileName = filePath.split('/').last;
      final regex = RegExp(r'TRACE_EQ(\d+)_J(\d+)\.txt');
      final match = regex.firstMatch(fileName);
      
      if (match == null) return null;
      
      final crewNumber = int.parse(match.group(1)!);
      final day = int.parse(match.group(2)!);
      
      final points = <GPSPoint>[];
      double distance = 0.0;
      GPSPoint? lastPoint;
      
      for (int i = 1; i < lines.length; i++) { // Sauter l'en-tête
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        
        try {
          final point = GPSPoint.fromTraceString(line);
          points.add(point);
          
          if (lastPoint != null) {
            distance += GPSUtils.calculateDistance(
              lastPoint.latitude,
              lastPoint.longitude,
              point.latitude,
              point.longitude,
            ) / 1000.0;
          }
          lastPoint = point;
        } catch (e) {
          // Ignorer les lignes invalides
        }
      }
      
      if (points.isEmpty) return null;
      
      return TraceData(
        crewNumber: crewNumber,
        day: day,
        startTime: points.first.timestamp,
        endTime: points.last.timestamp,
        points: points,
        totalDistance: distance,
      );
    } catch (e) {
      print('Erreur chargement TRACE: $e');
      return null;
    }
  }
  
  /// Réinitialiser le fichier TRACE (DANGER)
  Future<bool> resetTrace(int crewNumber, int day) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'TRACE_EQ${crewNumber}_J${day.toString().padLeft(2, '0')}.txt';
      final file = File('${directory.path}/$fileName');
      
      if (await file.exists()) {
        await file.delete();
      }
      
      _totalDistance = 0.0;
      _sessionPoints.clear();
      _distanceController.add(_totalDistance);
      _pointCountController.add(0);
      
      return true;
    } catch (e) {
      print('Erreur reset TRACE: $e');
      return false;
    }
  }
  
  /// Nettoyer les ressources
  void dispose() {
    _gpsSubscription?.cancel();
    _distanceController.close();
    _pointCountController.close();
  }
}
