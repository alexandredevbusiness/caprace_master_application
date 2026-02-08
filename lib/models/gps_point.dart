class GPSPoint {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracy;
  final double? speed;
  final double? heading;
  final DateTime timestamp;

  GPSPoint({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
    this.speed,
    this.heading,
    required this.timestamp,
  });

  // Ajoutez la méthode manquante
  Map<String, dynamic> toTraceLine() {
    return {
      'lat': latitude,
      'lon': longitude,
      'ele': altitude,
      'time': timestamp.toIso8601String(),
    };
  }

  // Autres méthodes utiles...
}
