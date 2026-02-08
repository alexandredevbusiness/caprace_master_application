import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

/// Service d'authentification pour l'accès Organisation
class AuthService {
  static final AuthService instance = AuthService._init();
  
  AuthService._init();
  
  static const String _passwordKey = 'org_password';
  static const String _crewKey = 'crew_number';
  static const String _dayKey = 'current_day';
  
  /// Obtenir le mot de passe stocké
  Future<String> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_passwordKey) ?? AppConfig.defaultPassword;
  }
  
  /// Définir un nouveau mot de passe
  Future<void> setPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passwordKey, password);
  }
  
  /// Vérifier le mot de passe
  Future<bool> verifyPassword(String inputPassword) async {
    final storedPassword = await getPassword();
    return inputPassword == storedPassword;
  }
  
  /// Obtenir le numéro d'équipage
  Future<int> getCrewNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_crewKey) ?? AppConfig.defaultCrewNumber;
  }
  
  /// Définir le numéro d'équipage
  Future<void> setCrewNumber(int crewNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_crewKey, crewNumber);
  }
  
  /// Obtenir le jour actuel
  Future<int> getCurrentDay() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_dayKey) ?? AppConfig.defaultDay;
  }
  
  /// Définir le jour actuel
  Future<void> setCurrentDay(int day) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dayKey, day);
  }
  
  /// Réinitialiser toutes les préférences
  Future<void> resetPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
