import 'dart:math';

/// Service de calcul de distance géographique
/// Utilise la formule de Haversine pour calculer la distance
/// entre deux points GPS sur une sphère (Terre)
class DistanceCalculator {
  /// Rayon de la Terre en mètres
  static const double earthRadiusMeters = 6371000.0;
  
  /// Calculer la distance entre deux points GPS en mètres
  /// Utilise la formule de Haversine
  /// 
  /// [lat1] Latitude du point 1 en degrés décimaux
  /// [lon1] Longitude du point 1 en degrés décimaux
  /// [lat2] Latitude du point 2 en degrés décimaux
  /// [lon2] Longitude du point 2 en degrés décimaux
  /// 
  /// Retourne la distance en mètres
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Convertir en radians
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final rLat1 = _toRadians(lat1);
    final rLat2 = _toRadians(lat2);
    
    // Formule de Haversine
    final a = sin(dLat / 2) * sin(dLat / 2) +
              cos(rLat1) * cos(rLat2) *
              sin(dLon / 2) * sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    final distance = earthRadiusMeters * c;
    
    return distance;
  }
  
  /// Calculer la distance totale d'une liste de points
  /// Retourne la distance en mètres
  double calculateTotalDistance(List<({double lat, double lon})> points) {
    if (points.length < 2) return 0.0;
    
    double totalDistance = 0.0;
    
    for (int i = 1; i < points.length; i++) {
      final distance = calculateDistance(
        points[i - 1].lat,
        points[i - 1].lon,
        points[i].lat,
        points[i].lon,
      );
      totalDistance += distance;
    }
    
    return totalDistance;
  }
  
  /// Calculer le bearing (cap) entre deux points en degrés
  /// 0° = Nord, 90° = Est, 180° = Sud, 270° = Ouest
  double calculateBearing(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLon = _toRadians(lon2 - lon1);
    final rLat1 = _toRadians(lat1);
    final rLat2 = _toRadians(lat2);
    
    final y = sin(dLon) * cos(rLat2);
    final x = cos(rLat1) * sin(rLat2) -
              sin(rLat1) * cos(rLat2) * cos(dLon);
    
    final bearingRadians = atan2(y, x);
    final bearingDegrees = _toDegrees(bearingRadians);
    
    // Normaliser entre 0 et 360
    return (bearingDegrees + 360) % 360;
  }
  
  /// Vérifier si un point est dans un rayon donné
  /// 
  /// [centerLat] Latitude du centre
  /// [centerLon] Longitude du centre
  /// [pointLat] Latitude du point à tester
  /// [pointLon] Longitude du point à tester
  /// [radiusMeters] Rayon en mètres
  /// 
  /// Retourne true si le point est dans le rayon
  bool isWithinRadius(
    double centerLat,
    double centerLon,
    double pointLat,
    double pointLon,
    double radiusMeters,
  ) {
    final distance = calculateDistance(
      centerLat,
      centerLon,
      pointLat,
      pointLon,
    );
    
    return distance <= radiusMeters;
  }
  
  /// Calculer la vitesse moyenne en km/h
  /// 
  /// [distanceMeters] Distance en mètres
  /// [durationSeconds] Durée en secondes
  /// 
  /// Retourne la vitesse en km/h
  double calculateAverageSpeed(double distanceMeters, int durationSeconds) {
    if (durationSeconds == 0) return 0.0;
    
    final distanceKm = distanceMeters / 1000.0;
    final durationHours = durationSeconds / 3600.0;
    
    return distanceKm / durationHours;
  }
  
  /// Formater une distance pour affichage
  /// 
  /// [meters] Distance en mètres
  /// 
  /// Retourne une chaîne formatée (ex: "1.5 km" ou "450 m")
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      final km = meters / 1000.0;
      return '${km.toStringAsFixed(1)} km';
    }
  }
  
  /// Convertir des degrés en radians
  double _toRadians(double degrees) {
    return degrees * pi / 180.0;
  }
  
  /// Convertir des radians en degrés
  double _toDegrees(double radians) {
    return radians * 180.0 / pi;
  }
  
  /// Calculer le point médian entre deux points GPS
  ({double lat, double lon}) calculateMidpoint(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final rLat1 = _toRadians(lat1);
    final rLat2 = _toRadians(lat2);
    final rLon1 = _toRadians(lon1);
    final dLon = _toRadians(lon2 - lon1);
    
    final bx = cos(rLat2) * cos(dLon);
    final by = cos(rLat2) * sin(dLon);
    
    final midLat = atan2(
      sin(rLat1) + sin(rLat2),
      sqrt((cos(rLat1) + bx) * (cos(rLat1) + bx) + by * by),
    );
    
    final midLon = rLon1 + atan2(by, cos(rLat1) + bx);
    
    return (
      lat: _toDegrees(midLat),
      lon: _toDegrees(midLon),
    );
  }
}
