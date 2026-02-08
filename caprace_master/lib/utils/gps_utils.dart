import 'dart:math';

/// Utilitaires pour les calculs GPS
class GPSUtils {
  /// Rayon de la Terre en mètres
  static const double earthRadius = 6371000.0;
  
  /// Calculer la distance entre deux points GPS (formule de Haversine)
  /// Retourne la distance en mètres
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Convertir en radians
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    
    final lat1Rad = _degreesToRadians(lat1);
    final lat2Rad = _degreesToRadians(lat2);
    
    // Formule de Haversine
    final a = sin(dLat / 2) * sin(dLat / 2) +
              sin(dLon / 2) * sin(dLon / 2) * 
              cos(lat1Rad) * cos(lat2Rad);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  /// Convertir des degrés en radians
  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }
  
  /// Convertir des radians en degrés
  static double radiansToDegrees(double radians) {
    return radians * 180.0 / pi;
  }
  
  /// Calculer la vitesse en km/h depuis m/s
  static double msToKmh(double metersPerSecond) {
    return metersPerSecond * 3.6;
  }
  
  /// Calculer la vitesse en m/s depuis km/h
  static double kmhToMs(double kilometersPerHour) {
    return kilometersPerHour / 3.6;
  }
  
  /// Vérifier si des coordonnées sont valides
  static bool areCoordinatesValid(double latitude, double longitude) {
    return latitude.abs() <= 90 && longitude.abs() <= 180;
  }
  
  /// Formater des coordonnées pour affichage
  static String formatCoordinates(double latitude, double longitude) {
    final latDir = latitude >= 0 ? 'N' : 'S';
    final lonDir = longitude >= 0 ? 'E' : 'W';
    
    return '${latitude.abs().toStringAsFixed(6)}°$latDir, '
           '${longitude.abs().toStringAsFixed(6)}°$lonDir';
  }
  
  /// Formater une distance en mètres ou kilomètres
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    }
  }
  
  /// Calculer le bearing (cap) entre deux points
  /// Retourne l'angle en degrés (0-360)
  static double calculateBearing(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final lat1Rad = _degreesToRadians(lat1);
    final lat2Rad = _degreesToRadians(lat2);
    final dLon = _degreesToRadians(lon2 - lon1);
    
    final y = sin(dLon) * cos(lat2Rad);
    final x = cos(lat1Rad) * sin(lat2Rad) -
              sin(lat1Rad) * cos(lat2Rad) * cos(dLon);
    
    final bearingRad = atan2(y, x);
    final bearingDeg = radiansToDegrees(bearingRad);
    
    return (bearingDeg + 360) % 360;
  }
  
  /// Obtenir la direction cardinale depuis un bearing
  static String getCardinalDirection(double bearing) {
    const directions = [
      'N', 'NNE', 'NE', 'ENE',
      'E', 'ESE', 'SE', 'SSE',
      'S', 'SSO', 'SO', 'OSO',
      'O', 'ONO', 'NO', 'NNO'
    ];
    
    final index = ((bearing + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }
}
