/// Constantes globales de l'application CAPRACE_MASTER
library;

/// Configuration GPS
class GPSConfig {
  /// Intervalle d'acquisition GPS (en secondes)
  static const int acquisitionIntervalSeconds = 1;
  
  /// Précision minimale acceptable (en mètres)
  static const double minimumAccuracyMeters = 20.0;
  
  /// Distance minimale pour détecter un mouvement (en mètres)
  static const double minimumMovementMeters = 2.0;
  
  /// Distance maximale entre 2 points consécutifs pour être considéré valide (en mètres)
  /// Au-delà = saut GPS (100m en 1s = 360km/h)
  static const double maximumJumpMeters = 100.0;
  
  /// Timeout pour l'acquisition GPS (en secondes)
  static const int acquisitionTimeoutSeconds = 5;
  
  /// Intervalle d'écriture sur disque (en secondes)
  static const int diskWriteIntervalSeconds = 10;
}

/// Configuration Checkpoints
class CheckpointConfig {
  /// Nombre de checkpoints par jour
  static const int checkpointsPerDay = 15;
  
  /// Nombre total de jours
  static const int totalDays = 15;
  
  /// Rayon de validation d'un checkpoint (en mètres)
  static const double validationRadiusMeters = 20.0;
  
  /// Rayon de pré-alerte (en mètres) - pour UI
  static const double preAlertRadiusMeters = 50.0;
}

/// Configuration de sécurité
class SecurityConfig {
  /// Nombre de clics requis sur l'image pour accès Organisation
  static const int clicksToUnlock = 5;
  
  /// Délai entre les clics pour reset le compteur (en millisecondes)
  static const int clickResetDelayMs = 2000;
  
  /// Durée d'appui long pour STOP (en secondes)
  static const int longPressStopSeconds = 2;
  
  /// Durée d'appui long pour RESET (en secondes)
  static const int longPressResetSeconds = 2;
  
  /// Mot de passe par défaut (à changer en production)
  static const String defaultPasswordHash = 
      'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'; // empty string SHA256
  
  /// Timeout de session (en minutes)
  static const int sessionTimeoutMinutes = 30;
}

/// Chemins de fichiers
class FileConfig {
  /// Nom du répertoire de l'application
  static const String appDirectoryName = 'CAPRACE_MASTER';
  
  /// Nom du fichier de base de données
  static const String databaseFileName = 'caprace_data.db';
  
  /// Préfixe des fichiers TRACE
  static const String traceFilePrefix = 'TRACE_EQ';
  
  /// Extension des fichiers TRACE
  static const String traceFileExtension = '.txt';
  
  /// Nom du fichier d'import
  static const String importFileName = 'import.txt';
  
  /// Extension CSV
  static const String csvExtension = '.csv';
  
  /// Extension GPX
  static const String gpxExtension = '.gpx';
}

/// Formats de données
class DataFormat {
  /// Format de date/heure ISO 8601
  static const String dateTimeFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'";
  
  /// Format de date simple
  static const String dateFormat = 'yyyy-MM-dd';
  
  /// Format d'heure
  static const String timeFormat = 'HH:mm:ss';
  
  /// Précision de la distance (nombre de décimales)
  static const int distancePrecision = 1;
  
  /// Séparateur CSV
  static const String csvSeparator = ',';
  
  /// Séparateur import.txt
  static const String importSeparator = '/';
}

/// Configuration UI
class UIConfig {
  /// Durée de l'animation de validation checkpoint (en millisecondes)
  static const int checkpointValidationAnimationMs = 500;
  
  /// Durée de l'animation de changement de jour (en millisecondes)
  static const int dayChangeAnimationMs = 300;
  
  /// Durée de vibration lors de validation (en millisecondes)
  static const int validationVibrationMs = 200;
  
  /// Intervalle de rafraîchissement de l'UI GPS (en millisecondes)
  static const int gpsRefreshIntervalMs = 1000;
  
  /// Durée d'affichage du popup de validation (en secondes)
  static const int validationPopupDurationSeconds = 3;
}

/// Clés SharedPreferences
class PrefsKeys {
  static const String currentEquipage = 'current_equipage';
  static const String currentDay = 'current_day';
  static const String passwordHash = 'password_hash';
  static const String lastSessionTimestamp = 'last_session_timestamp';
  static const String totalDistanceToday = 'total_distance_today';
  static const String isFirstLaunch = 'is_first_launch';
}

/// Messages utilisateur
class AppMessages {
  // Messages d'erreur
  static const String errorGPSPermission = 
      'Permission GPS requise pour le tracking';
  static const String errorGPSDisabled = 
      'Veuillez activer le GPS';
  static const String errorNoGPSSignal = 
      'Aucun signal GPS détecté';
  static const String errorDatabaseInit = 
      'Erreur d\'initialisation de la base de données';
  static const String errorFileWrite = 
      'Erreur d\'écriture du fichier';
  static const String errorImportFile = 
      'Erreur lors de l\'import du fichier';
  
  // Messages de succès
  static const String successCheckpointValidated = 
      'Checkpoint validé !';
  static const String successExportCSV = 
      'Export CSV réussi';
  static const String successExportGPX = 
      'Export GPX réussi';
  static const String successDataImported = 
      'Données importées avec succès';
  static const String successDataReset = 
      'Données réinitialisées';
  
  // Messages d'info
  static const String infoTrackingStarted = 
      'Enregistrement démarré';
  static const String infoTrackingStopped = 
      'Enregistrement arrêté';
  static const String infoNoDataToExport = 
      'Aucune donnée à exporter';
  
  // Confirmations
  static const String confirmResetTrace = 
      'Réinitialiser le fichier TRACE ?\nToutes les coordonnées GPS seront supprimées.';
  static const String confirmResetData = 
      'Réinitialiser toutes les données ?\nTous les checkpoints seront remis à zéro.';
  static const String confirmStopTracking = 
      'Arrêter l\'enregistrement ?';
}

/// Version de l'application
class AppInfo {
  static const String version = '1.0.0';
  static const String buildNumber = '1';
  static const String appName = 'CAPRACE_MASTER';
  static const String tagline = 'GPS TRACKING & VALIDATION';
  static const String systemName = 'SECURE TRACE SYSTEM';
  static const String developer = 'Senior Flutter Architect';
}
