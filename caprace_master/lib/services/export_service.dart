import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/trace_data.dart';
import 'tracking_service.dart';

/// Service d'export des données
class ExportService {
  static final ExportService instance = ExportService._init();
  
  ExportService._init();
  
  final TrackingService _tracking = TrackingService.instance;
  
  /// Exporter en CSV
  Future<File?> exportToCsv(int crewNumber, int day) async {
    try {
      // Obtenir les données de trace
      TraceData? traceData = _tracking.getTraceData(crewNumber, day);
      
      // Si pas de session active, charger depuis le fichier
      if (traceData == null) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'TRACE_EQ${crewNumber}_J${day.toString().padLeft(2, '0')}.txt';
        final filePath = '${directory.path}/$fileName';
        traceData = await _tracking.loadTraceFile(filePath);
      }
      
      if (traceData == null) return null;
      
      // Créer le fichier CSV
      final directory = await getApplicationDocumentsDirectory();
      final csvFileName = 'EQ-${crewNumber}_J-${day.toString().padLeft(2, '0')}.csv';
      final csvFile = File('${directory.path}/$csvFileName');
      
      // Écrire le contenu
      await csvFile.writeAsString(traceData.toCsv());
      
      return csvFile;
    } catch (e) {
      print('Erreur export CSV: $e');
      return null;
    }
  }
  
  /// Exporter en GPX
  Future<File?> exportToGpx(int crewNumber, int day) async {
    try {
      // Obtenir les données de trace
      TraceData? traceData = _tracking.getTraceData(crewNumber, day);
      
      // Si pas de session active, charger depuis le fichier
      if (traceData == null) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'TRACE_EQ${crewNumber}_J${day.toString().padLeft(2, '0')}.txt';
        final filePath = '${directory.path}/$fileName';
        traceData = await _tracking.loadTraceFile(filePath);
      }
      
      if (traceData == null) return null;
      
      // Créer le fichier GPX
      final directory = await getApplicationDocumentsDirectory();
      final gpxFileName = 'EQ-${crewNumber}_J-${day.toString().padLeft(2, '0')}.gpx';
      final gpxFile = File('${directory.path}/$gpxFileName');
      
      // Écrire le contenu
      await gpxFile.writeAsString(traceData.toGpx());
      
      return gpxFile;
    } catch (e) {
      print('Erreur export GPX: $e');
      return null;
    }
  }
  
  /// Partager un fichier via le système natif
  Future<void> shareFile(File file) async {
    try {
      final xFile = XFile(file.path);
      await Share.shareXFiles(
        [xFile],
        text: 'Export CAPRACE_MASTER',
      );
    } catch (e) {
      print('Erreur partage fichier: $e');
    }
  }
  
  /// Partager CSV
  Future<void> shareCsv(int crewNumber, int day) async {
    final file = await exportToCsv(crewNumber, day);
    if (file != null) {
      await shareFile(file);
    }
  }
  
  /// Partager GPX
  Future<void> shareGpx(int crewNumber, int day) async {
    final file = await exportToGpx(crewNumber, day);
    if (file != null) {
      await shareFile(file);
    }
  }
  
  /// Obtenir la liste des fichiers TRACE disponibles
  Future<List<String>> getAvailableTraces() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync();
      
      return files
          .where((f) => f.path.contains('TRACE_') && f.path.endsWith('.txt'))
          .map((f) => f.path.split('/').last)
          .toList();
    } catch (e) {
      print('Erreur listage TRACE: $e');
      return [];
    }
  }
  
  /// Obtenir les statistiques d'un fichier TRACE
  Future<Map<String, dynamic>?> getTraceStats(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final traceData = await _tracking.loadTraceFile(filePath);
      
      if (traceData == null) return null;
      
      return {
        'crew': traceData.crewNumber,
        'day': traceData.day,
        'points': traceData.pointCount,
        'distance': traceData.totalDistance,
        'startTime': traceData.startTime,
        'endTime': traceData.endTime,
        'duration': traceData.duration,
      };
    } catch (e) {
      print('Erreur stats TRACE: $e');
      return null;
    }
  }
}
