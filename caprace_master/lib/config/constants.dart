import 'package:flutter/material.dart';

/// Constantes pour les couleurs, styles et textes de l'application
class AppConstants {
  // Couleurs principales
  static const Color primaryBlack = Color(0xFF000000);
  static const Color primaryGreen = Color(0xFF00FF88);
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color dangerRed = Color(0xFFFF4444);
  
  // Couleurs de fond
  static const Color backgroundDark = Color(0xFF1A1A1A);
  static const Color cardDark = Color(0xFF2A2A2A);
  static const Color cardLight = Color(0xFF3A3A3A);
  
  // Couleurs pour les jours
  static const Color dayFuture = Color(0xFF555555);      // Gris clair - futur
  static const Color dayCompleted = Color(0xFF333333);   // Gris foncé - terminé
  static const Color dayCurrent = Color(0xFF4A90E2);     // Bleu - en cours
  
  // Couleurs pour les checkpoints
  static const Color checkpointPending = Color(0xFF555555);  // Gris - non validé
  static const Color checkpointValidated = Color(0xFF00FF88); // Vert - validé
  
  // Couleurs GPS
  static const Color gpsGood = Color(0xFF00FF88);
  static const Color gpsWaiting = Color(0xFFFF9800);
  static const Color gpsError = Color(0xFFFF4444);
  
  // Bordures et espacements
  static const double borderRadius = 12.0;
  static const double buttonHeight = 56.0;
  static const double cardPadding = 16.0;
  static const double spacing = 16.0;
  
  // Textes de l'interface
  static const String txtSystemReady = 'Système de Traçage Hors-Ligne';
  static const String txtSystemSubtitle = 'Prêt pour l\'acquisition de données';
  static const String txtGpsWaiting = 'En attente d\'activation...';
  static const String txtGpsActive = 'Signal GPS actif';
  static const String txtGpsNoSignal = 'Aucun signal';
  static const String txtDetectionZone = 'Zone de détection : 20m';
  
  // Textes des boutons
  static const String btnParticipant = 'ESPACE PARTICIPANT';
  static const String btnStart = 'START';
  static const String btnStop = 'STOP';
  static const String btnStopLong = 'Appui long 2s';
  static const String btnExport = 'ACCÉDER À L\'EXPORTATION';
  static const String btnParam = 'PARAMÈTRES DATA (SQLITE)';
  static const String btnBack = 'RETOUR À L\'ACCUEIL';
  static const String btnValidate = 'VALIDER L\'ACCÈS';
  static const String btnReturn = 'RETOUR À L\'ACCUEIL';
  static const String btnSave = 'SAVE';
  static const String btnImport = 'IMPORT';
  static const String btnReset = 'RESET';
  
  // Messages d'alerte
  static const String alertResetTrace = 'La réinitialisation supprimera définitivement toutes les coordonnées GPS enregistrées pour la journée en cours.';
  static const String alertResetData = 'Hold Reset for 2s to wipe all DATA';
  static const String alertNoCoordinates = 'Aucune coordonnée pour le jour';
  static const String alertImportInfo = 'Importez un fichier ou ajoutez les données manuellement';
  
  // Formats d'export
  static const String exportCsvFormat = 'Format tableur pour analyse Excel/Google Sheets';
  static const String exportGpxFormat = 'Format standard pour GPS et cartographie';
  
  // États
  static const String statusEncrypted = 'STATUS: ENCRYPTED SESSION';
  static const String statusActiveTrace = 'Fichier TRACE Actif';
  static const String statusConnectivity = 'Connectivité active : Wifi / Whatsapp - / Bluetooth';
  
  // Styles de texte
  static TextStyle titleStyle = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 1.2,
  );
  
  static TextStyle subtitleStyle = const TextStyle(
    fontSize: 14,
    color: primaryGreen,
    letterSpacing: 0.5,
  );
  
  static TextStyle bodyStyle = const TextStyle(
    fontSize: 14,
    color: Colors.white70,
  );
  
  static TextStyle labelStyle = const TextStyle(
    fontSize: 12,
    color: Colors.white60,
    letterSpacing: 0.5,
  );
  
  static TextStyle valueStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}
