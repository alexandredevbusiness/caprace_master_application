import 'package:flutter/foundation.dart';
import '../../models/gps_point.dart';
import '../../utils/constants.dart';
import 'distance_calculator.dart';

/// Service de filtrage des données GPS
/// Élimine les anomalies : micro-mouvements, sauts GPS, mauvaise précision
class GPSFilter {
  GPSPoint? _lastPoint;
  final DistanceCalculator _calculator = DistanceCalculator();
  
  // Statistiques de filtrage
  int _totalPoints = 0;
  int _filteredPoints = 0;
  int _microMovements = 0;
  int _poorAccuracy = 0;
  int _gpsJumps = 0;
  
  // Getters pour statistiques
  int get totalPoints => _totalPoints;
  int get filteredPoints => _filteredPoints;
  int get acceptedPoints => _totalPoints - _filteredPoints;
  double get filterRate => _totalPoints > 0 ? (_filteredPoints / _totalPoints) * 100 : 0.0;
  int get microMovements => _microMovements;
  int get poorAccuracy => _poorAccuracy;
  int get gpsJumps => _gpsJumps;
  
  /// Filtrer un point GPS
  /// Retourne true si le point est valide, false sinon
  bool filterPoint(GPSPoint point) {
    _totalPoints++;
    
    // 1. Vérifier la précision
    if (point.accuracy > GPSConfig.minimumAccuracyMeters) {
      _filteredPoints++;
      _poorAccuracy++;
      debugPrint('🔴 Point filtré - Précision insuffisante: ${point.accuracy.toStringAsFixed(1)}m');
      return false;
    }
    
    // 2. Si c'est le premier point, on l'accepte
    if (_lastPoint == null) {
      _lastPoint = point;
      debugPrint('🟢 Premier point accepté');
      return true;
    }
    
    // 3. Calculer la distance avec le dernier point
    final distance = _calculator.calculateDistance(
      _lastPoint!.latitude,
      _lastPoint!.longitude,
      point.latitude,
      point.longitude,
    );
    
    // 4. Vérifier les micro-mouvements (< 2m)
    if (distance < GPSConfig.minimumMovementMeters) {
      _filteredPoints++;
      _microMovements++;
      debugPrint('🟡 Point filtré - Micro-mouvement: ${distance.toStringAsFixed(2)}m');
      return false;
    }
    
    // 5. Vérifier les sauts GPS (> 100m en 1 seconde)
    final timeDiff = point.timestamp.difference(_lastPoint!.timestamp).inSeconds;
    if (timeDiff > 0) {
      final speed = distance / timeDiff; // mètres par seconde
      final speedKmh = speed * 3.6;
      
      if (speedKmh > 360) { // Équivalent à 100m en 1s
        _filteredPoints++;
        _gpsJumps++;
        debugPrint('🔴 Point filtré - Saut GPS: ${distance.toStringAsFixed(1)}m en ${timeDiff}s (${speedKmh.toStringAsFixed(0)} km/h)');
        return false;
      }
    }
    
    // 6. Point valide
    _lastPoint = point;
    debugPrint('🟢 Point accepté - Distance: ${distance.toStringAsFixed(1)}m');
    return true;
  }
  
  /// Réinitialiser le filtre
  void reset() {
    _lastPoint = null;
    _totalPoints = 0;
    _filteredPoints = 0;
    _microMovements = 0;
    _poorAccuracy = 0;
    _gpsJumps = 0;
    debugPrint('🔄 Filtre GPS réinitialisé');
  }
  
  /// Obtenir un rapport de filtrage
  String getFilterReport() {
    final buffer = StringBuffer();
    buffer.writeln('=== RAPPORT DE FILTRAGE GPS ===');
    buffer.writeln('Points totaux: $_totalPoints');
    buffer.writeln('Points acceptés: $acceptedPoints (${(100 - filterRate).toStringAsFixed(1)}%)');
    buffer.writeln('Points filtrés: $_filteredPoints (${filterRate.toStringAsFixed(1)}%)');
    buffer.writeln('  - Précision insuffisante: $_poorAccuracy');
    buffer.writeln('  - Micro-mouvements: $_microMovements');
    buffer.writeln('  - Sauts GPS: $_gpsJumps');
    buffer.writeln('==============================');
    return buffer.toString();
  }
  
  /// Vérifier si un point serait filtré (sans l'enregistrer)
  /// Utile pour les prévisualisations
  bool wouldFilter(GPSPoint point) {
    // Vérifier la précision
    if (point.accuracy > GPSConfig.minimumAccuracyMeters) {
      return true;
    }
    
    // Si pas de point précédent, on ne filtre pas
    if (_lastPoint == null) {
      return false;
    }
    
    // Calculer la distance
    final distance = _calculator.calculateDistance(
      _lastPoint!.latitude,
      _lastPoint!.longitude,
      point.latitude,
      point.longitude,
    );
    
    // Vérifier micro-mouvement
    if (distance < GPSConfig.minimumMovementMeters) {
      return true;
    }
    
    // Vérifier saut GPS
    final timeDiff = point.timestamp.difference(_lastPoint!.timestamp).inSeconds;
    if (timeDiff > 0) {
      final speed = distance / timeDiff;
      final speedKmh = speed * 3.6;
      if (speedKmh > 360) {
        return true;
      }
    }
    
    return false;
  }
}
