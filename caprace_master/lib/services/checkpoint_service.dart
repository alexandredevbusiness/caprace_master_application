import 'dart:async';
import '../models/checkpoint.dart';
import '../models/gps_point.dart';
import '../config/app_config.dart';
import '../utils/gps_utils.dart';
import 'database_service.dart';
import 'gps_service.dart';

/// Service de validation des checkpoints
class CheckpointService {
  static final CheckpointService instance = CheckpointService._init();
  
  CheckpointService._init();
  
  final DatabaseService _db = DatabaseService.instance;
  final GPSService _gps = GPSService.instance;
  
  StreamSubscription<GPSPoint>? _gpsSubscription;
  int? _currentDay;
  bool _isMonitoring = false;
  
  final StreamController<Checkpoint> _validationController = 
      StreamController<Checkpoint>.broadcast();
  
  /// Stream des checkpoints validés
  Stream<Checkpoint> get validationStream => _validationController.stream;
  
  /// Démarrer la surveillance des checkpoints
  Future<void> startMonitoring(int day) async {
    if (_isMonitoring) return;
    
    _currentDay = day;
    
    // S'abonner au flux GPS
    _gpsSubscription = _gps.gpsStream.listen(_onGPSUpdate);
    _isMonitoring = true;
  }
  
  /// Arrêter la surveillance
  Future<void> stopMonitoring() async {
    await _gpsSubscription?.cancel();
    _gpsSubscription = null;
    _isMonitoring = false;
    _currentDay = null;
  }
  
  /// Gestion des mises à jour GPS
  Future<void> _onGPSUpdate(GPSPoint point) async {
    if (_currentDay == null) return;
    
    // Récupérer tous les checkpoints du jour
    final checkpoints = await _db.getCheckpointsForDay(_currentDay!);
    
    for (final cp in checkpoints) {
      // Ignorer les checkpoints déjà validés
      if (cp.isValidated) continue;
      
      // Ignorer les checkpoints sans coordonnées
      if (!cp.hasCoordinates) continue;
      
      // Calculer la distance
      final distance = GPSUtils.calculateDistance(
        point.latitude,
        point.longitude,
        cp.latitude,
        cp.longitude,
      );
      
      // Vérifier si on est dans le rayon de validation
      if (distance <= AppConfig.checkpointRadiusMeters) {
        // Valider le checkpoint
        await _db.validateCheckpoint(cp.jour, cp.cp);
        
        // Notifier la validation
        final validatedCp = cp.copyWith(passageok: 1);
        _validationController.add(validatedCp);
        
        print('✓ Checkpoint validé: J${cp.jour}-CP${cp.cp} (${distance.toStringAsFixed(1)}m)');
      }
    }
  }
  
  /// Vérifier manuellement si on est proche d'un checkpoint
  Future<Checkpoint?> checkNearbyCheckpoint(
    double latitude,
    double longitude,
    int day,
  ) async {
    final checkpoints = await _db.getCheckpointsForDay(day);
    
    for (final cp in checkpoints) {
      if (cp.isValidated) continue;
      if (!cp.hasCoordinates) continue;
      
      final distance = GPSUtils.calculateDistance(
        latitude,
        longitude,
        cp.latitude,
        cp.longitude,
      );
      
      if (distance <= AppConfig.checkpointRadiusMeters) {
        return cp;
      }
    }
    
    return null;
  }
  
  /// Obtenir le statut de tous les checkpoints d'un jour
  Future<List<Checkpoint>> getCheckpointStatus(int day) async {
    return await _db.getCheckpointsForDay(day);
  }
  
  /// Obtenir le nombre de checkpoints validés
  Future<int> getValidatedCount(int day) async {
    return await _db.getValidatedCount(day);
  }
  
  /// Réinitialiser les validations d'un jour
  Future<void> resetDayValidations(int day) async {
    await _db.resetDayValidations(day);
  }
  
  /// Nettoyer les ressources
  void dispose() {
    _gpsSubscription?.cancel();
    _validationController.close();
  }
}
