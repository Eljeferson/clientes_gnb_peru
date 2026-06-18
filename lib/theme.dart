import 'package:flutter/material.dart';

class GnbColors {
  // Official GNB Peru Colors
  static const Color verdeGNB = Color(0xFF8EC63F);
  static const Color azulGNB = Color(0xFF01609C);
  static const Color blancoGNB = Color(0xFFFFFFFF);
  static const Color verdeOscuro = Color(0xFF71A42A);
  static const Color verdeClaro = Color(0xFF82BB4A);
  static const Color azulOscuroGNB = Color(0xFF045CA3);
  static const Color azulClaroGNB = Color(0xFF1A9DD8);
  static const Color azulPuntosGNB = Color(0xFF0072A6);
  static const Color naranjaGNB = Color(0xFFE46C19);
  static const Color naranjaClaro = Color(0xFFEF8432);
  static const Color amarilloGNB = Color(0xFFD4A103);
  
  // Neutrals
  static const Color grisFondo = Color(0xFFF5F5F5);
  static const Color grisFondoClaro = Color(0xFFF2F2F2);
  static const Color grisTexto = Color(0xFF333333);
  static const Color grisTextoSec = Color(0xFF666666);
  static const Color blancoPuro = Color(0xFFFFFFFF);

  // Premium Custom Tokens (Organic / Forest Theme)
  static const Color fondoCrema = Color(0xFFF7FAF4);   // Soft off-white
  static const Color bordeSuave = Color(0xFFE4ECE2);   // Ultra-thin Sage border
  static const Color verdeSage = Color(0xFFEAF1E7);    // Menthol Container background
  static const Color verdeSageOscuro = Color(0xFF4C6A40); // Sage for descriptive labels
  static const Color verdeBosqueOscuro = Color(0xFF1E3514); // High-contrast title green
  static const Color verdeBotonForest = Color(0xFF385A27); // Action call buttons green
  static const Color grisSage = Color(0xFF5A7255);     // Charcoal Sage secondary texts

  // States
  static const Color verdeExito = Color(0xFF71A42A);
  static const Color rojoError = Color(0xFFE74C3C);
  static const Color naranjaAviso = Color(0xFFE46C19);
}

class GnbTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: GnbColors.fondoCrema,
      colorScheme: ColorScheme.fromSeed(
        seedColor: GnbColors.verdeBotonForest,
        primary: GnbColors.verdeBotonForest,
        secondary: GnbColors.verdeSageOscuro,
        surface: GnbColors.blancoPuro,
        error: GnbColors.rojoError,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: GnbColors.verdeBosqueOscuro,
          fontWeight: FontWeight.bold,
          fontFamily: 'Outfit',
        ),
        headlineMedium: TextStyle(
          color: GnbColors.verdeBosqueOscuro,
          fontWeight: FontWeight.bold,
          fontFamily: 'Outfit',
        ),
        titleLarge: TextStyle(
          color: GnbColors.verdeBosqueOscuro,
          fontWeight: FontWeight.bold,
          fontFamily: 'Outfit',
        ),
        bodyLarge: TextStyle(
          color: GnbColors.verdeBosqueOscuro,
          fontFamily: 'Inter',
        ),
        bodyMedium: TextStyle(
          color: GnbColors.grisSage,
          fontFamily: 'Inter',
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: GnbColors.fondoCrema,
        elevation: 0,
        iconTheme: IconThemeData(color: GnbColors.verdeBosqueOscuro),
        titleTextStyle: TextStyle(
          color: GnbColors.verdeBosqueOscuro,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Outfit',
        ),
      ),
      cardTheme: CardThemeData(
        color: GnbColors.blancoPuro,
        elevation: 2,
        shadowColor: GnbColors.verdeSageOscuro.withOpacity(0.08),
        shape: RoundedCornerShape.rounded28,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GnbColors.verdeBotonForest,
          foregroundColor: GnbColors.blancoPuro,
          elevation: 0,
          shape: RoundedCornerShape.capsule,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: GnbColors.verdeBotonForest,
          side: const BorderSide(color: GnbColors.bordeSuave, width: 1.5),
          shape: RoundedCornerShape.capsule,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: GnbColors.verdeBosqueOscuro,
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GnbColors.fondoCrema,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: GnbColors.bordeSuave),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: GnbColors.bordeSuave),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: GnbColors.verdeBotonForest, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: GnbColors.rojoError),
        ),
        labelStyle: const TextStyle(color: GnbColors.grisSage, fontSize: 13, fontWeight: FontWeight.bold),
        floatingLabelStyle: const TextStyle(color: GnbColors.verdeBotonForest, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class RoundedCornerShape {
  static RoundedRectangleBorder get rounded16 => RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
  static RoundedRectangleBorder get rounded24 => RoundedRectangleBorder(borderRadius: BorderRadius.circular(24));
  static RoundedRectangleBorder get rounded28 => RoundedRectangleBorder(borderRadius: BorderRadius.circular(28));
  static RoundedRectangleBorder get rounded32 => RoundedRectangleBorder(borderRadius: BorderRadius.circular(32));
  static RoundedRectangleBorder get capsule => RoundedRectangleBorder(borderRadius: BorderRadius.circular(50));
}

