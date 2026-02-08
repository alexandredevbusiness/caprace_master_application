/// Configuration globale de l'application CAPRACE_MASTER
class AppConfig {
  // Version de l'application
  static const String appVersion = 'v1.0.4';
  static const String appName = 'CAPRACE_MASTER';
  static const String appSubtitle = 'GPS TRACKING & VALIDATION';
  
  // Configuration GPS
  static const int gpsUpdateIntervalSeconds = 1; // Acquisition toutes les secondes
  static const double minGpsAccuracyMeters = 20.0; // Précision minimale acceptable
  static const double maxSpeedKmh = 200.0; // Vitesse maximale plausible (détection anomalies)
  static const double minMovementMeters = 0.5; // Distance minimale pour filtrer micro-mouvements
  
  // Configuration Checkpoints
  static const double checkpointRadiusMeters = 20.0; // Rayon de validation
  static const int maxCheckpointsPerDay = 15;
  static const int maxDays = 15;
  
  // Configuration Sécurité
  static const int tapCountToUnlock = 5; // Nombre de clics pour accès Organisation
  static const int stopButtonHoldSeconds = 2; // Durée appui long STOP
  static const int resetButtonHoldSeconds = 2; // Durée appui long RESET
  
  // Configuration Base de données
  static const String databaseName = 'caprace_data.db';
  static const int databaseVersion = 1;
  
  // Configuration Fichiers
  static const String traceFileName = 'TRACE.txt';
  static const String importFileName = 'import.txt';
  
  // Valeurs par défaut
  static const String defaultPassword = '1234'; // Mot de passe organisation par défaut
  static const int defaultCrewNumber = 1;
  static const int defaultDay = 1;
}
