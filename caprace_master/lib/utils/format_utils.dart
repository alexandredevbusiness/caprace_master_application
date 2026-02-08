/// Utilitaires de formatage
class FormatUtils {
  /// Formater une distance en km avec 1 décimale
  static String formatDistance(double kilometers) {
    return '${kilometers.toStringAsFixed(1)} km';
  }
  
  /// Formater une durée
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
    } else {
      return '${seconds}s';
    }
  }
  
  /// Formater un timestamp
  static String formatTimestamp(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
           '${dateTime.month.toString().padLeft(2, '0')}/'
           '${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  /// Formater une heure seule
  static String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  /// Formater une date seule
  static String formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
           '${dateTime.month.toString().padLeft(2, '0')}/'
           '${dateTime.year}';
  }
  
  /// Formater une précision GPS
  static String formatAccuracy(double accuracy) {
    return '±${accuracy.toStringAsFixed(1)} m';
  }
  
  /// Formater une vitesse en km/h
  static String formatSpeed(double metersPerSecond) {
    final kmh = metersPerSecond * 3.6;
    return '${kmh.toStringAsFixed(1)} km/h';
  }
  
  /// Formater une altitude
  static String formatAltitude(double altitude) {
    return '${altitude.toStringAsFixed(0)} m';
  }
  
  /// Formater des coordonnées (courtes)
  static String formatCoordinatesShort(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  }
  
  /// Formater des coordonnées (complètes)
  static String formatCoordinatesFull(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }
  
  /// Formater un nombre de points
  static String formatPointCount(int count) {
    return '$count ${count > 1 ? 'points' : 'point'}';
  }
  
  /// Formater un pourcentage
  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(0)}%';
  }
  
  /// Formater un ratio (ex: 8/15)
  static String formatRatio(int current, int total) {
    return '$current / $total';
  }
  
  /// Obtenir la taille d'un fichier lisible
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
