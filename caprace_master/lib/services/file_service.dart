import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

/// Service de gestion des fichiers
class FileService {
  static final FileService instance = FileService._init();
  
  FileService._init();
  
  /// Obtenir le répertoire de l'application
  Future<Directory> getAppDirectory() async {
    return await getApplicationDocumentsDirectory();
  }
  
  /// Lire un fichier texte
  Future<String?> readTextFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;
      return await file.readAsString();
    } catch (e) {
      print('Erreur lecture fichier: $e');
      return null;
    }
  }
  
  /// Écrire dans un fichier texte
  Future<bool> writeTextFile(String filePath, String content) async {
    try {
      final file = File(filePath);
      await file.writeAsString(content);
      return true;
    } catch (e) {
      print('Erreur écriture fichier: $e');
      return false;
    }
  }
  
  /// Choisir un fichier via le sélecteur natif
  Future<File?> pickFile({List<String>? allowedExtensions}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
      );
      
      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      print('Erreur sélection fichier: $e');
      return null;
    }
  }
  
  /// Importer un fichier import.txt
  Future<String?> importDataFile() async {
    try {
      final file = await pickFile(allowedExtensions: ['txt']);
      if (file == null) return null;
      
      return await file.readAsString();
    } catch (e) {
      print('Erreur import fichier: $e');
      return null;
    }
  }
  
  /// Vérifier si un fichier existe
  Future<bool> fileExists(String filePath) async {
    return await File(filePath).exists();
  }
  
  /// Supprimer un fichier
  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur suppression fichier: $e');
      return false;
    }
  }
  
  /// Obtenir la taille d'un fichier
  Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      print('Erreur taille fichier: $e');
      return 0;
    }
  }
}
