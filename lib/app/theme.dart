import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette pastel « cosy & kawaii ».
class KawaiiColors {
  static const mint = Color(0xFFB8E0D2);
  static const leaf = Color(0xFF7FBF8E);
  static const peach = Color(0xFFFFD6BA);
  static const blush = Color(0xFFF7B2C4);
  static const cream = Color(0xFFFFF8EC);
  static const cocoa = Color(0xFF5B4636);
}

ThemeData buildKawaiiTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: KawaiiColors.leaf,
    primary: KawaiiColors.leaf,
    secondary: KawaiiColors.blush,
    tertiary: KawaiiColors.peach,
    surface: KawaiiColors.cream,
  );
  final rounded = RoundedRectangleBorder(borderRadius: BorderRadius.circular(24));
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: KawaiiColors.cream,
    textTheme: GoogleFonts.nunitoTextTheme().apply(
      bodyColor: KawaiiColors.cocoa,
      displayColor: KawaiiColors.cocoa,
    ),
    cardTheme: CardTheme(elevation: 0, color: Colors.white, shape: rounded),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: KawaiiColors.blush,
      shape: rounded,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: KawaiiColors.mint,
    ),
  );
}
