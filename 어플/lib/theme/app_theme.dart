import 'package:flutter/material.dart';

class AppTheme {
  // Brand Color Palette
  static const Color cream = Color(0xFFFAF8F5);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color subBg = Color(0xFFF3EFEA);
  static const Color terracotta = Color(0xFFE06D3B);
  static const Color terracottaDark = Color(0xFFC85A28);
  static const Color terracottaLight = Color(0xFFFDEEE6);
  static const Color sageMint = Color(0xFFE8F3EE);
  static const Color sageDark = Color(0xFF2E6F5E);
  static const Color charcoal = Color(0xFF2C2520);
  static const Color mutedText = Color(0xFF6E655F);
  static const Color borderLight = Color(0xFFEAE3DA);
  static const Color warningRed = Color(0xFFD32F2F);
  static const Color warningOrange = Color(0xFFE65100);

  // Border Radius standard
  static final BorderRadius cardRadius = BorderRadius.circular(18.0);
  static final BorderRadius buttonRadius = BorderRadius.circular(14.0);
  static final BorderRadius chipRadius = BorderRadius.circular(12.0);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: terracotta,
        primary: terracotta,
        surface: cardBg,
      ),
      fontFamily: 'Noto Sans KR',
      appBarTheme: const AppBarTheme(
        backgroundColor: cream,
        foregroundColor: charcoal,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: charcoal,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardBg,
        selectedItemColor: terracotta,
        unselectedItemColor: mutedText,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        elevation: 8,
      ),
      cardTheme: CardTheme(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: cardRadius,
          side: const BorderSide(color: borderLight, width: 1.0),
        ),
      ),
    );
  }
}
