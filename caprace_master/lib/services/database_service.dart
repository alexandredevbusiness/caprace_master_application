import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/checkpoint.dart';
import '../config/app_config.dart';

/// Service de gestion de la base de données SQLite
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;
  
  DatabaseService._init();
  
  /// Obtenir l'instance de la base de données
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }
  
  /// Initialiser la base de données
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConfig.databaseName);
    
    return await openDatabase(
      path,
      version: AppConfig.databaseVersion,
      onCreate: _createDB,
    );
  }
  
  /// Créer les tables de la base de données
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE DATA (
        jour INTEGER NOT NULL,
        cp INTEGER NOT NULL,
        latitude REAL NOT NULL DEFAULT 0.0,
        longitude REAL NOT NULL DEFAULT 0.0,
        passageok INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (jour, cp)
      )
    ''');
    
    // Initialiser avec 15 jours x 15 checkpoints (tous à 0,0 non validés)
    for (int jour = 1; jour <= AppConfig.maxDays; jour++) {
      for (int cp = 1; cp <= AppConfig.maxCheckpointsPerDay; cp++) {
        await db.insert('DATA', {
          'jour': jour,
          'cp': cp,
          'latitude': 0.0,
          'longitude': 0.0,
          'passageok': 0,
        });
      }
    }
  }
  
  /// Obtenir tous les checkpoints d'un jour
  Future<List<Checkpoint>> getCheckpointsForDay(int jour) async {
    final db = await database;
    final maps = await db.query(
      'DATA',
      where: 'jour = ?',
      whereArgs: [jour],
      orderBy: 'cp ASC',
    );
    
    return maps.map((map) => Checkpoint.fromMap(map)).toList();
  }
  
  /// Obtenir un checkpoint spécifique
  Future<Checkpoint?> getCheckpoint(int jour, int cp) async {
    final db = await database;
    final maps = await db.query(
      'DATA',
      where: 'jour = ? AND cp = ?',
      whereArgs: [jour, cp],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return Checkpoint.fromMap(maps.first);
  }
  
  /// Mettre à jour un checkpoint
  Future<int> updateCheckpoint(Checkpoint checkpoint) async {
    final db = await database;
    return await db.update(
      'DATA',
      checkpoint.toMap(),
      where: 'jour = ? AND cp = ?',
      whereArgs: [checkpoint.jour, checkpoint.cp],
    );
  }
  
  /// Marquer un checkpoint comme validé
  Future<void> validateCheckpoint(int jour, int cp) async {
    final db = await database;
    await db.update(
      'DATA',
      {'passageok': 1},
      where: 'jour = ? AND cp = ?',
      whereArgs: [jour, cp],
    );
  }
  
  /// Compter les checkpoints validés pour un jour
  Future<int> getValidatedCount(int jour) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM DATA WHERE jour = ? AND passageok = 1',
      [jour],
    );
    
    return Sqflite.firstIntValue(result) ?? 0;
  }
  
  /// Réinitialiser tous les passages d'un jour
  Future<void> resetDayValidations(int jour) async {
    final db = await database;
    await db.update(
      'DATA',
      {'passageok': 0},
      where: 'jour = ?',
      whereArgs: [jour],
    );
  }
  
  /// Réinitialiser toute la base de données (DANGER)
  Future<void> resetAllData() async {
    final db = await database;
    
    // Supprimer toutes les données
    await db.delete('DATA');
    
    // Réinsérer les données vides
    for (int jour = 1; jour <= AppConfig.maxDays; jour++) {
      for (int cp = 1; cp <= AppConfig.maxCheckpointsPerDay; cp++) {
        await db.insert('DATA', {
          'jour': jour,
          'cp': cp,
          'latitude': 0.0,
          'longitude': 0.0,
          'passageok': 0,
        });
      }
    }
  }
  
  /// Importer des données depuis un fichier
  /// Format: jour,cp,latitude,longitude (un par ligne)
  Future<int> importFromText(String content) async {
    final db = await database;
    int importedCount = 0;
    
    final lines = content.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      
      final parts = trimmed.split(',');
      if (parts.length < 4) continue;
      
      try {
        final jour = int.parse(parts[0].trim());
        final cp = int.parse(parts[1].trim());
        final lat = double.parse(parts[2].trim());
        final lon = double.parse(parts[3].trim());
        
        if (jour >= 1 && jour <= AppConfig.maxDays &&
            cp >= 1 && cp <= AppConfig.maxCheckpointsPerDay) {
          await db.update(
            'DATA',
            {
              'latitude': lat,
              'longitude': lon,
              'passageok': 0, // Réinitialiser la validation
            },
            where: 'jour = ? AND cp = ?',
            whereArgs: [jour, cp],
          );
          importedCount++;
        }
      } catch (e) {
        // Ignorer les lignes mal formatées
        continue;
      }
    }
    
    return importedCount;
  }
  
  /// Exporter tous les checkpoints en texte
  Future<String> exportToText() async {
    final db = await database;
    final maps = await db.query('DATA', orderBy: 'jour ASC, cp ASC');
    
    final buffer = StringBuffer();
    buffer.writeln('jour,cp,latitude,longitude,passageok');
    
    for (final map in maps) {
      buffer.writeln(
        '${map['jour']},${map['cp']},${map['latitude']},${map['longitude']},${map['passageok']}'
      );
    }
    
    return buffer.toString();
  }
  
  /// Fermer la base de données
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
