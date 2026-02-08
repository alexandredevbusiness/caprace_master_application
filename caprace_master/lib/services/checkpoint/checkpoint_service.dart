import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';
import '../../models/checkpoint.dart';
import '../../utils/constants.dart';
import '../gps/distance_calculator.dart';
import '../database/database_service.dart';

/// Service de validation des checkpoints
/// Vérifie la proximité GPS et marque les checkpoints comme validés
class CheckpointService extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final DistanceCalculator _calculator = DistanceCalculator();
  
  // État
  int _currentDay = 1;
  List<Checkpoint> _checkpointsForDay = [];
  final Set<int> _validatedCheckpoints = {};
  
  // Callbacks
  void Function(Checkpoint checkpoint)? onCheckpointValidated;
  void Function(int jour, int validatedCount)? onValidationCountChanged;
  
  // Getters
  int get currentDay => _currentDay;
  List<Checkpoint> get checkpointsForDay => List.unmodifiable(_checkpointsForDay);
  Set<int> get validatedCheckpoints => Set.unmodifiable(_validatedCheckpoints);
  int get validatedCount => _validatedCheckpoints.length;
  
  /// Initialiser le service pour un jour donné
  Future<void> initialize(int jour) async {
    _currentDay = jour;
    await _loadCheckpointsForDay();
    debugPrint('🎯 CheckpointService initialisé pour le jour $jour');
  }
  
  /// Charger les checkpoints du jour actuel
  Future<void> _loadCheckpointsForDay() async {
    _checkpointsForDay = await _dbService.getCheckpointsForDay(_currentDay);
    _validatedCheckpoints.clear();
    
    for (final cp in _checkpointsForDay) {
      if (cp.isValidated) {
        _validatedCheckpoints.add(cp.cp);
      }
    }
    
    debugPrint('📋 ${_checkpointsForDay.length} checkpoints chargés, ${_validatedCheckpoints.length} validés');
    notifyListeners();
  }
  
  /// Changer de jour
  Future<void> setCurrentDay(int jour) async {
    if (jour < 1 || jour > CheckpointConfig.totalDays) {
      debugPrint('⚠️ Jour invalide: $jour');
      return;
    }
    
    _currentDay = jour;
    await _loadCheckpointsForDay();
    notifyListeners();
  }
  
  /// Vérifier la proximité avec les checkpoints et valider si nécessaire
  /// Retourne la liste des checkpoints nouvellement validés
  Future<List<Checkpoint>> checkProximity(double latitude, double longitude) async {
    final newlyValidated = <Checkpoint>[];
    
    // Obtenir uniquement les checkpoints non validés
    final unvalidated = _checkpointsForDay
        .where((cp) => !cp.isValidated && cp.latitude != 0 && cp.longitude != 0)
        .toList();
    
    for (final checkpoint in unvalidated) {
      final distance = _calculator.calculateDistance(
        latitude,
        longitude,
        checkpoint.latitude,
        checkpoint.longitude,
      );
      
      // Vérifier si on est dans le rayon de validation
      if (distance <= CheckpointConfig.validationRadiusMeters) {
        // Marquer comme validé en base de données
        await _dbService.validateCheckpoint(checkpoint.jour, checkpoint.cp);
        
        // Mettre à jour l'état local
        _validatedCheckpoints.add(checkpoint.cp);
        
        // Créer une copie validée du checkpoint
        final validatedCheckpoint = checkpoint.copyWith(passageok: 1);
        newlyValidated.add(validatedCheckpoint);
        
        // Déclencher les feedbacks
        await _triggerValidationFeedback(validatedCheckpoint, distance);
        
        debugPrint('✅ Checkpoint J${checkpoint.jour}-CP${checkpoint.cp} validé à ${distance.toStringAsFixed(1)}m');
      } else if (distance <= CheckpointConfig.preAlertRadiusMeters) {
        debugPrint('📍 Approche du checkpoint J${checkpoint.jour}-CP${checkpoint.cp} à ${distance.toStringAsFixed(1)}m');
      }
    }
    
    // Si au moins un checkpoint a été validé
    if (newlyValidated.isNotEmpty) {
      // Recharger les checkpoints pour mettre à jour l'UI
      await _loadCheckpointsForDay();
      
      // Notifier le callback
      onValidationCountChanged?.call(_currentDay, _validatedCheckpoints.length);
      
      for (final cp in newlyValidated) {
        onCheckpointValidated?.call(cp);
      }
    }
    
    return newlyValidated;
  }
  
  /// Déclencher les feedbacks de validation (vibration, son, etc.)
  Future<void> _triggerValidationFeedback(Checkpoint checkpoint, double distance) async {
    // Vibration
    if (await Vibration.hasVibrator() ?? false) {
      await Vibration.vibrate(duration: UIConfig.validationVibrationMs);
    }
    
    // Son (optionnel - à implémenter avec audioplayers si nécessaire)
    // await _playValidationSound();
    
    debugPrint('🔔 Feedback de validation déclenché pour CP${checkpoint.cp}');
  }
  
  /// Obtenir le nombre de checkpoints validés pour le jour actuel
  Future<int> getValidatedCountForCurrentDay() async {
    return await _dbService.getValidatedCountForDay(_currentDay);
  }
  
  /// Obtenir la distance jusqu'au checkpoint le plus proche non validé
  double? getDistanceToNearestUnvalidated(double latitude, double longitude) {
    final unvalidated = _checkpointsForDay
        .where((cp) => !cp.isValidated && cp.latitude != 0 && cp.longitude != 0)
        .toList();
    
    if (unvalidated.isEmpty) return null;
    
    double? minDistance;
    
    for (final checkpoint in unvalidated) {
      final distance = _calculator.calculateDistance(
        latitude,
        longitude,
        checkpoint.latitude,
        checkpoint.longitude,
      );
      
      if (minDistance == null || distance < minDistance) {
        minDistance = distance;
      }
    }
    
    return minDistance;
  }
  
  /// Obtenir le checkpoint le plus proche (validé ou non)
  Checkpoint? getNearestCheckpoint(double latitude, double longitude) {
    if (_checkpointsForDay.isEmpty) return null;
    
    Checkpoint? nearest;
    double? minDistance;
    
    for (final checkpoint in _checkpointsForDay) {
      if (checkpoint.latitude == 0 && checkpoint.longitude == 0) continue;
      
      final distance = _calculator.calculateDistance(
        latitude,
        longitude,
        checkpoint.latitude,
        checkpoint.longitude,
      );
      
      if (minDistance == null || distance < minDistance) {
        minDistance = distance;
        nearest = checkpoint;
      }
    }
    
    return nearest;
  }
  
  /// Vérifier si tous les checkpoints du jour sont validés
  bool areAllCheckpointsValidated() {
    final configured = _checkpointsForDay
        .where((cp) => cp.latitude != 0 && cp.longitude != 0)
        .length;
    
    return _validatedCheckpoints.length == configured;
  }
  
  /// Réinitialiser les validations du jour actuel
  Future<void> resetCurrentDay() async {
    await _dbService.resetCheckpointsForDay(_currentDay);
    await _loadCheckpointsForDay();
    debugPrint('🔄 Jour $_currentDay réinitialisé');
  }
  
  /// Réinitialiser toutes les validations
  Future<void> resetAll() async {
    await _dbService.resetAllCheckpoints();
    await _loadCheckpointsForDay();
    debugPrint('🔄 Toutes les validations réinitialisées');
  }
  
  /// Obtenir un rapport de progression
  String getProgressReport() {
    final configured = _checkpointsForDay
        .where((cp) => cp.latitude != 0 && cp.longitude != 0)
        .length;
    
    final buffer = StringBuffer();
    buffer.writeln('=== RAPPORT DE PROGRESSION ===');
    buffer.writeln('Jour: $_currentDay / ${CheckpointConfig.totalDays}');
    buffer.writeln('Checkpoints configurés: $configured / ${CheckpointConfig.checkpointsPerDay}');
    buffer.writeln('Checkpoints validés: ${_validatedCheckpoints.length} / $configured');
    
    if (configured > 0) {
      final percentage = (_validatedCheckpoints.length / configured * 100);
      buffer.writeln('Progression: ${percentage.toStringAsFixed(1)}%');
    }
    
    buffer.writeln('============================');
    return buffer.toString();
  }
}
