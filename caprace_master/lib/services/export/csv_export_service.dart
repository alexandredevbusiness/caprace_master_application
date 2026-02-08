import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import '../../models/gps_point.dart';
import '../../utils/constants.dart';

/// Service d'export au format CSV
/// Génère des fichiers CSV compatibles Excel/Google Sheets
class CSVExportService {
  /// Exporter une trace GPS vers un fichier CSV
  /// 
  /// Format CSV:
  /// equipage,jour,timestamp,latitude,longitude,distance_km,cp_valides
  Future<File?> exportTraceToCSV({
    required int equipage,
    required int jour,
    required List<GPSPoint> points,
    required double totalDistanceKm,
    required int validatedCheckpoints,
  }) async {
    try {
      // Créer le nom du fichier
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final filename = 'EQ-$equipage'
                      '_J${jour.toString().padLeft(2, '0')}'
                      '_$timestamp'
                      '${FileConfig.csvExtension}';
      
      // Obtenir le répertoire d'export
      final directory = await _getExportDirectory();
      final file = File(path.join(directory.path, filename));
      
      // Créer le contenu CSV
      final csvContent = _generateCSVContent(
        equipage: equipage,
        jour: jour,
        points: points,
        totalDistanceKm: totalDistanceKm,
        validatedCheckpoints: validatedCheckpoints,
      );
      
      // Écrire le fichier
      await file.writeAsString(csvContent);
      
      debugPrint('📄 Export CSV réussi: $filename');
      debugPrint('   Chemin: ${file.path}');
      debugPrint('   Points: ${points.length}');
      
      return file;
      
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'export CSV: $e');
      return null;
    }
  }
  
  /// Générer le contenu du fichier CSV
  String _generateCSVContent({
    required int equipage,
    required int jour,
    required List<GPSPoint> points,
    required double totalDistanceKm,
    required int validatedCheckpoints,
  }) {
    final buffer = StringBuffer();
    
    // En-tête avec métadonnées
    buffer.writeln('# CAPRACE_MASTER - Export CSV');
    buffer.writeln('# Equipage: $equipage');
    buffer.writeln('# Jour: J${jour.toString().padLeft(2, '0')}');
    buffer.writeln('# Date export: ${DateTime.now().toIso8601String()}');
    buffer.writeln('# Distance totale: ${totalDistanceKm.toStringAsFixed(1)} km');
    buffer.writeln('# Checkpoints validés: $validatedCheckpoints / ${CheckpointConfig.checkpointsPerDay}');
    buffer.writeln('# Points GPS: ${points.length}');
    buffer.writeln('#');
    
    // En-tête des colonnes
    buffer.writeln('equipage${DataFormat.csvSeparator}'
                   'jour${DataFormat.csvSeparator}'
                   'timestamp${DataFormat.csvSeparator}'
                   'latitude${DataFormat.csvSeparator}'
                   'longitude${DataFormat.csvSeparator}'
                   'accuracy_m${DataFormat.csvSeparator}'
                   'speed_kmh${DataFormat.csvSeparator}'
                   'altitude_m');
    
    // Données
    for (final point in points) {
      buffer.writeln(
        '$equipage${DataFormat.csvSeparator}'
        '$jour${DataFormat.csvSeparator}'
        '${point.timestamp.toIso8601String()}${DataFormat.csvSeparator}'
        '${point.latitude.toStringAsFixed(6)}${DataFormat.csvSeparator}'
        '${point.longitude.toStringAsFixed(6)}${DataFormat.csvSeparator}'
        '${point.accuracy.toStringAsFixed(1)}${DataFormat.csvSeparator}'
        '${(point.speed * 3.6).toStringAsFixed(1)}${DataFormat.csvSeparator}'
        '${point.altitude?.toStringAsFixed(1) ?? ""}'
      );
    }
    
    // Ligne de synthèse
    buffer.writeln('#');
    buffer.writeln('# SYNTHÈSE');
    buffer.writeln('# Distance: ${totalDistanceKm.toStringAsFixed(1)} km');
    buffer.writeln('# Progression: $validatedCheckpoints / ${CheckpointConfig.checkpointsPerDay} CP');
    
    if (points.isNotEmpty) {
      final duration = points.last.timestamp.difference(points.first.timestamp);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      buffer.writeln('# Durée: ${hours}h ${minutes}min');
      
      if (duration.inSeconds > 0) {
        final avgSpeed = (totalDistanceKm / (duration.inSeconds / 3600.0));
        buffer.writeln('# Vitesse moyenne: ${avgSpeed.toStringAsFixed(1)} km/h');
      }
    }
    
    return buffer.toString();
  }
  
  /// Exporter un résumé journalier (une ligne par jour)
  Future<File?> exportDailySummaryToCSV({
    required List<Map<String, dynamic>> dailyData,
  }) async {
    try {
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final filename = 'SUMMARY_$timestamp${FileConfig.csvExtension}';
      
      final directory = await _getExportDirectory();
      final file = File(path.join(directory.path, filename));
      
      final buffer = StringBuffer();
      
      // En-tête
      buffer.writeln('# CAPRACE_MASTER - Résumé Journalier');
      buffer.writeln('# Date export: ${DateTime.now().toIso8601String()}');
      buffer.writeln('#');
      
      buffer.writeln('jour${DataFormat.csvSeparator}'
                     'equipage${DataFormat.csvSeparator}'
                     'distance_km${DataFormat.csvSeparator}'
                     'cp_valides${DataFormat.csvSeparator}'
                     'cp_total${DataFormat.csvSeparator}'
                     'progression_pct${DataFormat.csvSeparator}'
                     'date');
      
      for (final data in dailyData) {
        final validatedCount = data['cp_valides'] as int;
        final totalCount = data['cp_total'] as int;
        final progression = totalCount > 0 ? (validatedCount / totalCount * 100) : 0.0;
        
        buffer.writeln(
          '${data['jour']}${DataFormat.csvSeparator}'
          '${data['equipage']}${DataFormat.csvSeparator}'
          '${(data['distance_km'] as double).toStringAsFixed(1)}${DataFormat.csvSeparator}'
          '$validatedCount${DataFormat.csvSeparator}'
          '$totalCount${DataFormat.csvSeparator}'
          '${progression.toStringAsFixed(1)}${DataFormat.csvSeparator}'
          '${data['date']}'
        );
      }
      
      await file.writeAsString(buffer.toString());
      
      debugPrint('📄 Export résumé CSV réussi: $filename');
      return file;
      
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'export résumé CSV: $e');
      return null;
    }
  }
  
  /// Obtenir le répertoire d'export
  Future<Directory> _getExportDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final exportDirectory = Directory(
      path.join(directory.path, FileConfig.appDirectoryName, 'exports')
    );
    
    if (!await exportDirectory.exists()) {
      await exportDirectory.create(recursive: true);
    }
    
    return exportDirectory;
  }
  
  /// Obtenir la liste de tous les fichiers CSV exportés
  Future<List<File>> getAllCSVExports() async {
    try {
      final directory = await _getExportDirectory();
      
      final files = await directory
          .list()
          .where((entity) => 
              entity is File && 
              entity.path.endsWith(FileConfig.csvExtension))
          .cast<File>()
          .toList();
      
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      
      return files;
      
    } catch (e) {
      debugPrint('❌ Erreur lors de la lecture des exports CSV: $e');
      return [];
    }
  }
  
  /// Supprimer un fichier CSV
  Future<bool> deleteCSVExport(File file) async {
    try {
      await file.delete();
      debugPrint('🗑️ Export CSV supprimé: ${path.basename(file.path)}');
      return true;
    } catch (e) {
      debugPrint('❌ Erreur lors de la suppression de l\'export CSV: $e');
      return false;
    }
  }
}
