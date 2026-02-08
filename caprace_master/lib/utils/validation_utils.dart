/// Utilitaires de validation
class ValidationUtils {
  /// Valider un numéro d'équipage
  static bool isValidCrewNumber(int? number) {
    if (number == null) return false;
    return number >= 1 && number <= 999;
  }
  
  /// Valider un numéro de jour
  static bool isValidDay(int? day) {
    if (day == null) return false;
    return day >= 1 && day <= 15;
  }
  
  /// Valider un numéro de checkpoint
  static bool isValidCheckpoint(int? cp) {
    if (cp == null) return false;
    return cp >= 1 && cp <= 15;
  }
  
  /// Valider une latitude
  static bool isValidLatitude(double? lat) {
    if (lat == null) return false;
    return lat >= -90 && lat <= 90;
  }
  
  /// Valider une longitude
  static bool isValidLongitude(double? lon) {
    if (lon == null) return false;
    return lon >= -180 && lon <= 180;
  }
  
  /// Valider des coordonnées complètes
  static bool areCoordinatesValid(double? lat, double? lon) {
    return isValidLatitude(lat) && isValidLongitude(lon);
  }
  
  /// Valider un mot de passe (minimum 4 caractères)
  static bool isValidPassword(String? password) {
    if (password == null || password.isEmpty) return false;
    return password.length >= 4;
  }
  
  /// Valider une distance (positive)
  static bool isValidDistance(double? distance) {
    if (distance == null) return false;
    return distance >= 0;
  }
  
  /// Valider une précision GPS (positive)
  static bool isValidAccuracy(double? accuracy) {
    if (accuracy == null) return false;
    return accuracy >= 0;
  }
  
  /// Parser un entier depuis une chaîne
  static int? parseInt(String? value) {
    if (value == null || value.isEmpty) return null;
    return int.tryParse(value.trim());
  }
  
  /// Parser un double depuis une chaîne
  static double? parseDouble(String? value) {
    if (value == null || value.isEmpty) return null;
    return double.tryParse(value.trim());
  }
  
  /// Nettoyer une chaîne (trim et enlever espaces multiples)
  static String cleanString(String? value) {
    if (value == null) return '';
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
  
  /// Vérifier si une chaîne est vide ou nulle
  static bool isNullOrEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }
  
  /// Formater un numéro d'équipage pour affichage
  static String formatCrewNumber(int number) {
    return 'EQ-$number';
  }
  
  /// Formater un jour pour affichage
  static String formatDay(int day) {
    return 'J${day.toString().padLeft(2, '0')}';
  }
  
  /// Formater un checkpoint pour affichage
  static String formatCheckpoint(int cp) {
    return 'CP ${cp.toString().padLeft(2, '0')}';
  }
}
