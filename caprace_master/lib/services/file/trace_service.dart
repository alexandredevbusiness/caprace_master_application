import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import '../../models/gps_point.dart';
import '../../utils/constants.dart';

/// Service de gestion du fichier TRACE
/// Gère l'écriture et la lecture des coordonnées GPS
class TraceService {
  File? _currentTraceFile;
  IOSink? _fileSink;
  bool _isActive = false;
  
  int _currentEquipage = 0;
  int _currentJour = 0;
  DateTime? _sessionStartTime;
  
  int _pointsWritten = 0;
  
  // Getters
  bool get isActive => _isActive;
  File? get currentTraceFile => _currentTraceFile;
  int get pointsWritten => _pointsWritten;
  String? get currentTraceFilePath => _currentTraceFile?.path;
  
  /// Démarrer un nouveau fichier TRACE
  Future<bool> startNewTrace(int equipage, int jour) async {
    try {
      // Fermer le fichier actuel si ouvert
      if (_isActive) {
        await closeTrace();
      }
      
      _currentEquipage = equipage;
      _currentJour = jour;
      _sessionStartTime = DateTime.now();
      _pointsWritten = 0;
      
      // Créer le nom du fichier
      final timestamp = _sessionStartTime!.toIso8601String().replaceAll(':', '-').split('.')[0];
      final filename = '${FileConfig.traceFilePrefix}$equipage'
                      '_J${jour.toString().padLeft(2, '0')}'
                      '_$timestamp'
                      '${FileConfig.traceFileExtension}';
      
      // Obtenir le répertoire de l'application
      final directory = await _getAppDirectory();
      final tracesDirectory = Directory(path.join(directory.path, 'traces'));
      
      // Créer le répertoire si nécessaire
      if (!await tracesDirectory.exists()) {
        await tracesDirectory.create(recursive: true);
      }
      
      // Créer le fichier
      _currentTraceFile = File(path.join(tracesDirectory.path, filename));
      _fileSink = _currentTraceFile!.openWrite();
      
      // Écrire l'en-tête
      await _writeHeader();
      
      _isActive = true;
      debugPrint('📝 Nouveau fichier TRACE créé: $filename');
      debugPrint('   Chemin: ${_currentTraceFile!.path}');
      
      return true;
      
    } catch (e) {
      debugPrint('❌ Erreur lors de la création du fichier TRACE: $e');
      _isActive = false;
      return false;
    }
  }
  
  /// Écrire l'en-tête du fichier TRACE
  Future<void> _writeHeader() async {
    if (_fileSink == null) return;
    
    _fileSink!.writeln('# CAPRACE_MASTER TRACE FILE');
    _fileSink!.writeln('# Equipage: $_currentEquipage');
    _fileSink!.writeln('# Jour: J${_currentJour.toString().padLeft(2, '0')}');
    _fileSink!.writeln('# Date: ${_sessionStartTime!.toIso8601String()}');
    _fileSink!.writeln('# Version: ${AppInfo.version}');
    _fileSink!.writeln('#');
    _fileSink!.writeln('# Format: timestamp,latitude,longitude,accuracy,speed');
    _fileSink!.writeln('#');
    
    await _fileSink!.flush();
  }
  
  /// Ajouter un point GPS au fichier
  Future<bool> appendGPSPoint(GPSPoint point) async {
    if (!_isActive || _fileSink == null) {
      debugPrint('⚠️ Tentative d\'écriture sur un fichier TRACE inactif');
      return false;
    }
    
    try {
      _fileSink!.writeln(point.toTraceLine());
      _pointsWritten++;
      
      // Flush périodique pour éviter la perte de données
      if (_pointsWritten % 10 == 0) {
        await _fileSink!.flush();
        debugPrint('💾 Buffer flushed: $_pointsWritten points écrits');
      }
      
      return true;
      
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'écriture du point GPS: $e');
      return false;
    }
  }
  
  /// Ajouter plusieurs points GPS en batch
  Future<bool> appendGPSPoints(List<GPSPoint> points) async {
    if (!_isActive || _fileSink == null) {
      debugPrint('⚠️ Tentative d\'écriture sur un fichier TRACE inactif');
      return false;
    }
    
    try {
      for (final point in points) {
        _fileSink!.writeln(point.toTraceLine());
        _pointsWritten++;
      }
      
      await _fileSink!.flush();
      debugPrint('💾 Batch écrit: ${points.length} points | Total: $_pointsWritten');
      
      return true;
      
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'écriture batch: $e');
      return false;
    }
  }
  
  /// Fermer le fichier TRACE actuel
  Future<void> closeTrace() async {
    if (!_isActive || _fileSink == null) {
      return;
    }
    
    try {
      // Écrire le pied de page
      _fileSink!.writeln('#');
      _fileSink!.writeln('# Fin de session: ${DateTime.now().toIso8601String()}');
      _fileSink!.writeln('# Points enregistrés: $_pointsWritten');
      
      if (_sessionStartTime != null) {
        final duration = DateTime.now().difference(_sessionStartTime!);
        final hours = duration.inHours;
        final minutes = duration.inMinutes % 60;
        _fileSink!.writeln('# Durée: ${hours}h ${minutes}min');
      }
      
      // Fermer le sink
      await _fileSink!.flush();
      await _fileSink!.close();
      
      debugPrint('📕 Fichier TRACE fermé: $_pointsWritten points enregistrés');
      
      _fileSink = null;
      _isActive = false;
      
    } catch (e) {
      debugPrint('❌ Erreur lors de la fermeture du fichier TRACE: $e');
    }
  }
  
  /// Lire un fichier TRACE complet
  Future<List<GPSPoint>> readTrace(File file) async {
    final points = <GPSPoint>[];
    
    try {
      final lines = await file.readAsLines();
      
      for (final line in lines) {
        // Ignorer les commentaires et lignes vides
        if (line.trim().isEmpty || line.startsWith('#')) {
          continue;
        }
        
        try {
          final point = GPSPoint.fromTraceLine(line);
          points.add(point);
        } catch (e) {
          debugPrint('⚠️ Ligne invalide ignorée: $line');
        }
      }
      
      debugPrint('📖 Fichier TRACE lu: ${points.length} points');
      return points;
      
    } catch (e) {
      debugPrint('❌ Erreur lors de la lecture du fichier TRACE: $e');
      return [];
    }
  }
  
  /// Lire le fichier TRACE actuel
  Future<List<GPSPoint>> readCurrentTrace() async {
    if (_currentTraceFile == null) {
      debugPrint('⚠️ Aucun fichier TRACE actuel');
      return [];
    }
    
    // Fermer temporairement pour lire
    final wasActive = _isActive;
    if (_isActive) {
      await _fileSink?.flush();
    }
    
    final points = await readTrace(_currentTraceFile!);
    
    return points;
  }
  
  /// Obtenir la liste de tous les fichiers TRACE
  Future<List<File>> getAllTraceFiles() async {
    try {
      final directory = await _getAppDirectory();
      final tracesDirectory = Directory(path.join(directory.path, 'traces'));
      
      if (!await tracesDirectory.exists()) {
        return [];
      }
      
      final files = await tracesDirectory
          .list()
          .where((entity) => 
              entity is File && 
              entity.path.endsWith(FileConfig.traceFileExtension))
          .cast<File>()
          .toList();
      
      // Trier par date de modification (plus récent en premier)
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      
      debugPrint('📚 ${files.length} fichiers TRACE trouvés');
      return files;
      
    } catch (e) {
      debugPrint('❌ Erreur lors de la lecture des fichiers TRACE: $e');
      return [];
    }
  }
  
  /// Supprimer le fichier TRACE actuel
  Future<bool> deleteCurrentTrace() async {
    if (_currentTraceFile == null) {
      debugPrint('⚠️ Aucun fichier TRACE actuel à supprimer');
      return false;
    }
    
    try {
      // Fermer le fichier si ouvert
      if (_isActive) {
        await closeTrace();
      }
      
      await _currentTraceFile!.delete();
      debugPrint('🗑️ Fichier TRACE supprimé: ${_currentTraceFile!.path}');
      
      _currentTraceFile = null;
      _pointsWritten = 0;
      
      return true;
      
    } catch (e) {
      debugPrint('❌ Erreur lors de la suppression du fichier TRACE: $e');
      return false;
    }
  }
  
  /// Supprimer tous les fichiers TRACE
  Future<int> deleteAllTraces() async {
    try {
      final files = await getAllTraceFiles();
      int deletedCount = 0;
      
      for (final file in files) {
        try {
          await file.delete();
          deletedCount++;
        } catch (e) {
          debugPrint('⚠️ Impossible de supprimer ${file.path}: $e');
        }
      }
      
      debugPrint('🗑️ $deletedCount fichiers TRACE supprimés');
      return deletedCount;
      
    } catch (e) {
      debugPrint('❌ Erreur lors de la suppression des fichiers TRACE: $e');
      return 0;
    }
  }
  
  /// Obtenir le répertoire de l'application
  Future<Directory> _getAppDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final appDirectory = Directory(path.join(directory.path, FileConfig.appDirectoryName));
    
    if (!await appDirectory.exists()) {
      await appDirectory.create(recursive: true);
    }
    
    return appDirectory;
  }
  
  /// Obtenir des informations sur le fichier TRACE actuel
  Map<String, dynamic>? getCurrentTraceInfo() {
    if (_currentTraceFile == null) return null;
    
    return {
      'equipage': _currentEquipage,
      'jour': _currentJour,
      'path': _currentTraceFile!.path,
      'filename': path.basename(_currentTraceFile!.path),
      'pointsWritten': _pointsWritten,
      'startTime': _sessionStartTime?.toIso8601String(),
      'isActive': _isActive,
    };
  }
  
  /// Dispose des ressources
  Future<void> dispose() async {
    if (_isActive) {
      await closeTrace();
    }
  }
}
