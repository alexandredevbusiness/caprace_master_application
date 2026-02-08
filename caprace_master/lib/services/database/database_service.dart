import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../../models/checkpoint.dart';
import '../../utils/constants.dart';

/// Service de gestion de la base de données SQLite
/// Gère la table DATA avec les checkpoints
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();
  
  Database? _database;
  
  /// Obtenir l'instance de la base de données
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  /// Initialiser la base de données
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, FileConfig.databaseFileName);
    
    debugPrint('📁 Initialisation de la base de données: $path');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  /// Créer la structure de la base de données
  Future<void> _onCreate(Database db, int version) async {
    debugPrint('🏗️ Création de la table checkpoints');
    
    await db.execute('''
      CREATE TABLE checkpoints (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        jour INTEGER NOT NULL,
        cp INTEGER NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        passageok INTEGER DEFAULT 0,
        UNIQUE(jour, cp)
      )
    ''');
    
    // Créer un index pour les requêtes par jour
    await db.execute('''
      CREATE INDEX idx_jour ON checkpoints(jour)
    ''');
    
    // Initialiser avec des données vides pour les 15 jours
    await _initializeEmptyCheckpoints(db);
    
    debugPrint('✅ Table checkpoints créée avec succès');
  }
  
  /// Gérer les mises à niveau de schéma
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('⬆️ Mise à niveau de la base de données de v$oldVersion vers v$newVersion');
    // Gérer les migrations futures ici
  }
  
  /// Initialiser la table avec des checkpoints vides
  Future<void> _initializeEmptyCheckpoints(Database db) async {
    final batch = db.batch();
    
    for (int jour = 1; jour <= CheckpointConfig.totalDays; jour++) {
      for (int cp = 1; cp <= CheckpointConfig.checkpointsPerDay; cp++) {
        batch.insert('checkpoints', {
          'jour': jour,
          'cp': cp,
          'latitude': 0.0,
          'longitude': 0.0,
          'passageok': 0,
        });
      }
    }
    
    await batch.commit(noResult: true);
    debugPrint('✅ ${CheckpointConfig.totalDays * CheckpointConfig.checkpointsPerDay} checkpoints initialisés');
  }
  
  /// Obtenir tous les checkpoints d'un jour
  Future<List<Checkpoint>> getCheckpointsForDay(int jour) async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'checkpoints',
      where: 'jour = ?',
      whereArgs: [jour],
      orderBy: 'cp ASC',
    );
    
    return List.generate(maps.length, (i) => Checkpoint.fromMap(maps[i]));
  }
  
  /// Obtenir un checkpoint spécifique
  Future<Checkpoint?> getCheckpoint(int jour, int cp) async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'checkpoints',
      where: 'jour = ? AND cp = ?',
      whereArgs: [jour, cp],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return Checkpoint.fromMap(maps.first);
  }
  
  /// Mettre à jour les coordonnées d'un checkpoint
  Future<int> updateCheckpoint(Checkpoint checkpoint) async {
    final db = await database;
    
    final result = await db.update(
      'checkpoints',
      checkpoint.toMap(),
      where: 'jour = ? AND cp = ?',
      whereArgs: [checkpoint.jour, checkpoint.cp],
    );
    
    debugPrint('✏️ Checkpoint J${checkpoint.jour}-CP${checkpoint.cp} mis à jour');
    return result;
  }
  
  /// Marquer un checkpoint comme validé
  Future<int> validateCheckpoint(int jour, int cp) async {
    final db = await database;
    
    final result = await db.update(
      'checkpoints',
      {'passageok': 1},
      where: 'jour = ? AND cp = ?',
      whereArgs: [jour, cp],
    );
    
    debugPrint('✅ Checkpoint J$jour-CP$cp validé');
    return result;
  }
  
  /// Obtenir le nombre de checkpoints validés pour un jour
  Future<int> getValidatedCountForDay(int jour) async {
    final db = await database;
    
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM checkpoints WHERE jour = ? AND passageok = 1',
      [jour],
    );
    
    return Sqflite.firstIntValue(result) ?? 0;
  }
  
  /// Obtenir tous les checkpoints validés d'un jour
  Future<List<Checkpoint>> getValidatedCheckpointsForDay(int jour) async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'checkpoints',
      where: 'jour = ? AND passageok = 1',
      whereArgs: [jour],
      orderBy: 'cp ASC',
    );
    
    return List.generate(maps.length, (i) => Checkpoint.fromMap(maps[i]));
  }
  
  /// Obtenir tous les checkpoints non validés d'un jour
  Future<List<Checkpoint>> getUnvalidatedCheckpointsForDay(int jour) async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'checkpoints',
      where: 'jour = ? AND passageok = 0 AND latitude != 0 AND longitude != 0',
      whereArgs: [jour],
      orderBy: 'cp ASC',
    );
    
    return List.generate(maps.length, (i) => Checkpoint.fromMap(maps[i]));
  }
  
  /// Réinitialiser tous les checkpoints (passageok = 0)
  Future<int> resetAllCheckpoints() async {
    final db = await database;
    
    final result = await db.update(
      'checkpoints',
      {'passageok': 0},
    );
    
    debugPrint('🔄 Tous les checkpoints réinitialisés');
    return result;
  }
  
  /// Réinitialiser les checkpoints d'un jour spécifique
  Future<int> resetCheckpointsForDay(int jour) async {
    final db = await database;
    
    final result = await db.update(
      'checkpoints',
      {'passageok': 0},
      where: 'jour = ?',
      whereArgs: [jour],
    );
    
    debugPrint('🔄 Checkpoints du jour $jour réinitialisés');
    return result;
  }
  
  /// Importer des checkpoints depuis une liste de données
  /// Format: List de Maps avec {jour, cp, latitude, longitude}
  Future<void> importCheckpoints(List<Map<String, dynamic>> data) async {
    final db = await database;
    final batch = db.batch();
    
    for (final item in data) {
      batch.update(
        'checkpoints',
        {
          'latitude': item['latitude'],
          'longitude': item['longitude'],
        },
        where: 'jour = ? AND cp = ?',
        whereArgs: [item['jour'], item['cp']],
      );
    }
    
    await batch.commit(noResult: true);
    debugPrint('📥 ${data.length} checkpoints importés');
  }
  
  /// Exporter tous les checkpoints
  Future<List<Checkpoint>> exportAllCheckpoints() async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'checkpoints',
      orderBy: 'jour ASC, cp ASC',
    );
    
    return List.generate(maps.length, (i) => Checkpoint.fromMap(maps[i]));
  }
  
  /// Supprimer tous les checkpoints (pour réinitialisation complète)
  Future<void> deleteAllCheckpoints() async {
    final db = await database;
    await db.delete('checkpoints');
    await _initializeEmptyCheckpoints(db);
    debugPrint('🗑️ Tous les checkpoints supprimés et réinitialisés');
  }
  
  /// Obtenir des statistiques globales
  Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;
    
    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM checkpoints',
    );
    final total = Sqflite.firstIntValue(totalResult) ?? 0;
    
    final validatedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM checkpoints WHERE passageok = 1',
    );
    final validated = Sqflite.firstIntValue(validatedResult) ?? 0;
    
    final configuredResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM checkpoints WHERE latitude != 0 AND longitude != 0',
    );
    final configured = Sqflite.firstIntValue(configuredResult) ?? 0;
    
    return {
      'total': total,
      'validated': validated,
      'configured': configured,
      'validationRate': total > 0 ? (validated / total * 100) : 0.0,
      'configurationRate': total > 0 ? (configured / total * 100) : 0.0,
    };
  }
  
  /// Fermer la base de données
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
    debugPrint('🔒 Base de données fermée');
  }
}
