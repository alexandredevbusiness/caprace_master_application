import 'package:flutter/material.dart';

/// Thème de l'application CAPRACE_MASTER
/// Style dark avec accents vert et bleu
class AppTheme {
  // Couleurs principales
  static const Color backgroundColor = Color(0xFF000000);      // Noir
  static const Color primaryColor = Color(0xFF00FF00);        // Vert
  static const Color secondaryColor = Color(0xFF808080);      // Gris
  static const Color accentColor = Color(0xFF0080FF);         // Bleu
  static const Color textColor = Color(0xFFFFFFFF);           // Blanc
  static const Color textSecondaryColor = Color(0xFFB0B0B0);  // Gris clair
  
  // Couleurs d'état
  static const Color successColor = Color(0xFF00FF00);        // Vert
  static const Color errorColor = Color(0xFFFF0000);          // Rouge
  static const Color warningColor = Color(0xFFFFAA00);        // Orange
  static const Color infoColor = Color(0xFF0080FF);           // Bleu
  
  // Couleurs checkpoints
  static const Color checkpointDefault = Color(0xFF404040);   // Gris foncé
  static const Color checkpointValidated = Color(0xFF00FF00); // Vert
  
  // Couleurs jours
  static const Color dayFuture = Color(0xFF606060);           // Gris clair
  static const Color dayPast = Color(0xFF303030);             // Gris foncé
  static const Color dayActive = Color(0xFF0080FF);           // Bleu
  
  // Thème dark
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Couleurs générales
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: Color(0xFF1A1A1A),
        error: errorColor,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: textColor,
        onError: Colors.white,
      ),
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'RobotoMono',
          color: primaryColor,
        ),
      ),
      
      // Texte
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textColor,
          fontFamily: 'RobotoMono',
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textColor,
          fontFamily: 'RobotoMono',
        ),
        displaySmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textColor,
          fontFamily: 'RobotoMono',
        ),
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColor,
          fontFamily: 'RobotoMono',
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor,
          fontFamily: 'RobotoMono',
        ),
        bodyLarge: TextStyle(
          fontSize: 14,
          color: textColor,
          fontFamily: 'RobotoMono',
        ),
        bodyMedium: TextStyle(
          fontSize: 12,
          color: textSecondaryColor,
          fontFamily: 'RobotoMono',
        ),
      ),
      
      // Boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'RobotoMono',
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'RobotoMono',
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'RobotoMono',
          ),
        ),
      ),
      
      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: secondaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: secondaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
        labelStyle: const TextStyle(
          color: textSecondaryColor,
          fontFamily: 'RobotoMono',
        ),
        hintStyle: const TextStyle(
          color: textSecondaryColor,
          fontFamily: 'RobotoMono',
        ),
      ),
      
      // Cards
      cardTheme: CardTheme(
        color: const Color(0xFF1A1A1A),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Dialogs
      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textColor,
          fontFamily: 'RobotoMono',
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          color: textColor,
          fontFamily: 'RobotoMono',
        ),
      ),
      
      // Icons
      iconTheme: const IconThemeData(
        color: primaryColor,
        size: 24,
      ),
    );
  }
  
  // Styles de texte personnalisés
  static const TextStyle monospaceLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    fontFamily: 'RobotoMono',
    color: textColor,
  );
  
  static const TextStyle monospaceMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: 'RobotoMono',
    color: textColor,
  );
  
  static const TextStyle monospaceSmall = TextStyle(
    fontSize: 12,
    fontFamily: 'RobotoMono',
    color: textSecondaryColor,
  );
  
  static const TextStyle gpsDataStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: 'RobotoMono',
    color: primaryColor,
  );
  
  static const TextStyle distanceStyle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    fontFamily: 'RobotoMono',
    color: primaryColor,
  );
  
  // Décorations personnalisées
  static BoxDecoration cardDecoration = BoxDecoration(
    color: const Color(0xFF1A1A1A),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: secondaryColor.withOpacity(0.3), width: 1),
  );
  
  static BoxDecoration activeCardDecoration = BoxDecoration(
    color: const Color(0xFF1A1A1A),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: primaryColor, width: 2),
  );
  
  // Ombres
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  // Padding standards
  static const EdgeInsets paddingSmall = EdgeInsets.all(8);
  static const EdgeInsets paddingMedium = EdgeInsets.all(16);
  static const EdgeInsets paddingLarge = EdgeInsets.all(24);
  
  // Spacing
  static const SizedBox spacingSmall = SizedBox(height: 8, width: 8);
  static const SizedBox spacingMedium = SizedBox(height: 16, width: 16);
  static const SizedBox spacingLarge = SizedBox(height: 24, width: 24);
}
