import 'gps_point.dart';

/// Modèle représentant une session de traçage complète
class TraceData {
  final int crewNumber;
  final int day;
  final DateTime startTime;
  final DateTime? endTime;
  final List<GPSPoint> points;
  final double totalDistance; // en kilomètres
  
  TraceData({
    required this.crewNumber,
    required this.day,
    required this.startTime,
    this.endTime,
    required this.points,
    required this.totalDistance,
  });
  
  /// Vérifier si la session est en cours
  bool get isActive => endTime == null;
  
  /// Obtenir la durée de la session
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }
  
  /// Obtenir le nombre de points GPS enregistrés
  int get pointCount => points.length;
  
  /// Obtenir la distance formatée avec 1 décimale
  String get formattedDistance => '${totalDistance.toStringAsFixed(1)} km';
  
  /// Exporter en CSV
  String toCsv() {
    final buffer = StringBuffer();
    buffer.writeln('Équipage,Jour,Timestamp,Latitude,Longitude,Altitude,Accuracy,Speed');
    
    for (final point in points) {
      buffer.writeln(
        'EQ-$crewNumber,J-${day.toString().padLeft(2, '0')},'
        '${point.timestamp.toIso8601String()},'
        '${point.latitude},${point.longitude},'
        '${point.altitude},${point.accuracy},${point.speed}'
      );
    }
    
    return buffer.toString();
  }
  
  /// Exporter en GPX
  String toGpx() {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<gpx version="1.1" creator="CAPRACE_MASTER">');
    buffer.writeln('  <metadata>');
    buffer.writeln('    <name>Équipage $crewNumber - Jour $day</name>');
    buffer.writeln('    <time>${startTime.toIso8601String()}</time>');
    buffer.writeln('  </metadata>');
    buffer.writeln('  <trk>');
    buffer.writeln('    <name>Trace EQ-$crewNumber J$day</name>');
    buffer.writeln('    <trkseg>');
    
    for (final point in points) {
      buffer.writeln(point.toGpxTrkpt());
    }
    
    buffer.writeln('    </trkseg>');
    buffer.writeln('  </trk>');
    buffer.writeln('</gpx>');
    
    return buffer.toString();
  }
  
  @override
  String toString() {
    return 'TraceData(EQ$crewNumber-J$day: ${points.length} points, ${formattedDistance})';
  }
}
