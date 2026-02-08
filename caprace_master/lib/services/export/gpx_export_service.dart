import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart' as xml;
import '../../models/gps_point.dart';
import '../../utils/constants.dart';

/// Service d'export au format GPX
/// Génère des fichiers GPX compatibles avec les applications GPS et cartographiques
class GPXExportService {
  /// Exporter une trace GPS vers un fichier GPX
  Future<File?> exportTraceToGPX({
    required int equipage,
    required int jour,
    required List<GPSPoint> points,
    String? trackName,
    String? description,
  }) async {
    try {
      // Créer le nom du fichier
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final filename = 'EQ-$equipage'
                      '_J${jour.toString().padLeft(2, '0')}'
                      '_$timestamp'
                      '${FileConfig.gpxExtension}';
      
      // Obtenir le répertoire d'export
      final directory = await _getExportDirectory();
      final file = File(path.join(directory.path, filename));
      
      // Générer le contenu GPX
      final gpxContent = _generateGPXContent(
        equipage: equipage,
        jour: jour,
        points: points,
        trackName: trackName ?? 'Trace Jour $jour',
        description: description,
      );
      
      // Écrire le fichier
      await file.writeAsString(gpxContent);
      
      debugPrint('🗺️ Export GPX réussi: $filename');
      debugPrint('   Chemin: ${file.path}');
      debugPrint('   Points: ${points.length}');
      
      return file;
      
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'export GPX: $e');
      return null;
    }
  }
  
  /// Générer le contenu du fichier GPX
  String _generateGPXContent({
    required int equipage,
    required int jour,
    required List<GPSPoint> points,
    required String trackName,
    String? description,
  }) {
    final builder = xml.XmlBuilder();
    
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    
    builder.element('gpx', nest: () {
      // Attributs GPX
      builder.attribute('version', '1.1');
      builder.attribute('creator', '${AppInfo.appName} v${AppInfo.version}');
      builder.attribute('xmlns', 'http://www.topografix.com/GPX/1/1');
      builder.attribute('xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
      builder.attribute('xsi:schemaLocation', 
        'http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd');
      
      // Métadonnées
      builder.element('metadata', nest: () {
        builder.element('name', nest: 'Equipage $equipage - Jour J${jour.toString().padLeft(2, '0')}');
        builder.element('desc', nest: description ?? 'Trace GPS générée par CAPRACE_MASTER');
        builder.element('author', nest: () {
          builder.element('name', nest: '${AppInfo.appName}');
        });
        builder.element('time', nest: DateTime.now().toIso8601String());
        
        // Bounds (limites géographiques)
        if (points.isNotEmpty) {
          final minLat = points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
          final maxLat = points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
          final minLon = points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
          final maxLon = points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);
          
          builder.element('bounds', nest: () {
            builder.attribute('minlat', minLat.toStringAsFixed(6));
            builder.attribute('minlon', minLon.toStringAsFixed(6));
            builder.attribute('maxlat', maxLat.toStringAsFixed(6));
            builder.attribute('maxlon', maxLon.toStringAsFixed(6));
          });
        }
      });
      
      // Track
      builder.element('trk', nest: () {
        builder.element('name', nest: trackName);
        builder.element('type', nest: 'GPS Tracking');
        
        // Extensions personnalisées
        builder.element('extensions', nest: () {
          builder.element('equipage', nest: equipage.toString());
          builder.element('jour', nest: jour.toString());
          builder.element('points_count', nest: points.length.toString());
        });
        
        // Track segment
        builder.element('trkseg', nest: () {
          for (final point in points) {
            builder.element('trkpt', nest: () {
              builder.attribute('lat', point.latitude.toStringAsFixed(6));
              builder.attribute('lon', point.longitude.toStringAsFixed(6));
              
              if (point.altitude != null) {
                builder.element('ele', nest: point.altitude!.toStringAsFixed(1));
              }
              
              builder.element('time', nest: point.timestamp.toIso8601String());
              
              // Extensions pour accuracy et speed
              builder.element('extensions', nest: () {
                builder.element('accuracy', nest: point.accuracy.toStringAsFixed(1));
                builder.element('speed', nest: point.speed.toStringAsFixed(1));
              });
            });
          }
        });
      });
    });
    
    final document = builder.buildDocument();
    return document.toXmlString(pretty: true, indent: '  ');
  }
  
  /// Exporter avec waypoints pour les checkpoints
  Future<File?> exportTraceWithWaypoints({
    required int equipage,
    required int jour,
    required List<GPSPoint> trackPoints,
    required List<({double lat, double lon, String name, bool validated})> waypoints,
  }) async {
    try {
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final filename = 'EQ-$equipage'
                      '_J${jour.toString().padLeft(2, '0')}'
                      '_WITH_CP_$timestamp'
                      '${FileConfig.gpxExtension}';
      
      final directory = await _getExportDirectory();
      final file = File(path.join(directory.path, filename));
      
      final gpxContent = _generateGPXWithWaypoints(
        equipage: equipage,
        jour: jour,
        trackPoints: trackPoints,
        waypoints: waypoints,
      );
      
      await file.writeAsString(gpxContent);
      
      debugPrint('🗺️ Export GPX avec waypoints réussi: $filename');
      return file;
      
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'export GPX avec waypoints: $e');
      return null;
    }
  }
  
  /// Générer GPX avec waypoints (checkpoints)
  String _generateGPXWithWaypoints({
    required int equipage,
    required int jour,
    required List<GPSPoint> trackPoints,
    required List<({double lat, double lon, String name, bool validated})> waypoints,
  }) {
    final builder = xml.XmlBuilder();
    
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    
    builder.element('gpx', nest: () {
      builder.attribute('version', '1.1');
      builder.attribute('creator', '${AppInfo.appName} v${AppInfo.version}');
      builder.attribute('xmlns', 'http://www.topografix.com/GPX/1/1');
      
      // Métadonnées
      builder.element('metadata', nest: () {
        builder.element('name', nest: 'Equipage $equipage - Jour J$jour avec Checkpoints');
        builder.element('time', nest: DateTime.now().toIso8601String());
      });
      
      // Waypoints (checkpoints)
      for (final waypoint in waypoints) {
        builder.element('wpt', nest: () {
          builder.attribute('lat', waypoint.lat.toStringAsFixed(6));
          builder.attribute('lon', waypoint.lon.toStringAsFixed(6));
          
          builder.element('name', nest: waypoint.name);
          builder.element('sym', nest: waypoint.validated ? 'Flag, Green' : 'Flag, Red');
          builder.element('type', nest: 'Checkpoint');
          
          builder.element('extensions', nest: () {
            builder.element('validated', nest: waypoint.validated.toString());
          });
        });
      }
      
      // Track
      builder.element('trk', nest: () {
        builder.element('name', nest: 'Trace J$jour');
        
        builder.element('trkseg', nest: () {
          for (final point in trackPoints) {
            builder.element('trkpt', nest: () {
              builder.attribute('lat', point.latitude.toStringAsFixed(6));
              builder.attribute('lon', point.longitude.toStringAsFixed(6));
              
              if (point.altitude != null) {
                builder.element('ele', nest: point.altitude!.toStringAsFixed(1));
              }
              
              builder.element('time', nest: point.timestamp.toIso8601String());
            });
          }
        });
      });
    });
    
    final document = builder.buildDocument();
    return document.toXmlString(pretty: true, indent: '  ');
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
  
  /// Obtenir la liste de tous les fichiers GPX exportés
  Future<List<File>> getAllGPXExports() async {
    try {
      final directory = await _getExportDirectory();
      
      final files = await directory
          .list()
          .where((entity) => 
              entity is File && 
              entity.path.endsWith(FileConfig.gpxExtension))
          .cast<File>()
          .toList();
      
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      
      return files;
      
    } catch (e) {
      debugPrint('❌ Erreur lors de la lecture des exports GPX: $e');
      return [];
    }
  }
  
  /// Supprimer un fichier GPX
  Future<bool> deleteGPXExport(File file) async {
    try {
      await file.delete();
      debugPrint('🗑️ Export GPX supprimé: ${path.basename(file.path)}');
      return true;
    } catch (e) {
      debugPrint('❌ Erreur lors de la suppression de l\'export GPX: $e');
      return false;
    }
  }
}
