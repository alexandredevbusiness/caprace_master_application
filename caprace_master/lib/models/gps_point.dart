/// Modèle représentant un point GPS enregistré
class GPSPoint {
  final double latitude;
  final double longitude;
  final double altitude;
  final double accuracy;
  final double speed;
  final DateTime timestamp;
  
  GPSPoint({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.accuracy,
    required this.speed,
    required this.timestamp,
  });
  
  factory GPSPoint.fromPosition({
    required double latitude,
    required double longitude,
    double? altitude,
    double? accuracy,
    double? speed,
    DateTime? timestamp,
  }) {
    return GPSPoint(
      latitude: latitude,
      longitude: longitude,
      altitude: altitude ?? 0.0,
      accuracy: accuracy ?? 0.0,
      speed: speed ?? 0.0,
      timestamp: timestamp ?? DateTime.now(),
    );
  }
  
  String toTraceString() {
    return '${timestamp.toIso8601String()},$latitude,$longitude,$altitude,$accuracy,$speed';
  }
  
  factory GPSPoint.fromTraceString(String line) {
    final parts = line.split(',');
    if (parts.length < 6) {
      throw FormatException('Invalid TRACE line format');
    }
    
    return GPSPoint(
      timestamp: DateTime.parse(parts[0]),
      latitude: double.parse(parts[1]),
      longitude: double.parse(parts[2]),
      altitude: double.parse(parts[3]),
      accuracy: double.parse(parts[4]),
      speed: double.parse(parts[5]),
    );
  }
  
  String toGpxTrkpt() {
    return '''
    <trkpt lat="$latitude" lon="$longitude">
      <ele>$altitude</ele>
      <time>${timestamp.toIso8601String()}</time>
    </trkpt>''';
  }
  
  bool get hasGoodAccuracy => accuracy > 0 && accuracy <= 20.0;
  
  bool get isValid {
    return latitude.abs() <= 90 &&
           longitude.abs() <= 180 &&
           accuracy >= 0 &&
           speed >= 0;
  }
}
