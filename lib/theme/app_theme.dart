import 'package:flutter/material.dart';

import '../models/app_settings.dart';

class AppThemeData {
  /// 라이트 테마용 라벤더 액센트 (스플래시·라이트 테마 공통)
  static const Color feelyLavender = Color(0xFFB8A9C9);

  static ThemeData forTheme(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return _light;
      case AppTheme.dark:
        return _dark;
      case AppTheme.blue:
        return _blue;
      case AppTheme.green:
        return _green;
    }
  }

  static ThemeData get _light => ThemeData.light().copyWith(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: feelyLavender,
          brightness: Brightness.light,
          primary: feelyLavender,
          surface: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2D2D2D),
          elevation: 0,
          iconTheme: const IconThemeData(color: feelyLavender),
          titleTextStyle: const TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: const Color(0xFFF8F7FC),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E0F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: feelyLavender, width: 1.5),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: feelyLavender,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: feelyLavender,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      );

  static ThemeData get _dark {
    const scaffoldBg = Color(0xFF2D2D2D);
    const surface = Color(0xFF3D3D3D);
    const surfaceDim = Color(0xFF383838);
    const outline = Color(0xFF707070);
    final baseDark = ThemeData.dark().colorScheme;
    return ThemeData.dark().copyWith(
      useMaterial3: true,
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: baseDark.copyWith(
        surface: scaffoldBg,
        onSurface: Colors.white,
        surfaceContainerHighest: surfaceDim,
        onSurfaceVariant: const Color(0xFFE0E0E0),
        outline: outline,
        primary: Colors.white,
        onPrimary: const Color(0xFF2D2D2D),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Color(0xFF2D2D2D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDim,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white70, width: 1.5),
        ),
      ),
    );
  }

  static ThemeData get _blue => ThemeData.light().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B9BD5),
          brightness: Brightness.light,
          primary: const Color(0xFF5B9BD5),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFF5B9BD5),
          foregroundColor: Colors.white,
        ),
      );

  static ThemeData get _green => ThemeData.light().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B9B5A),
          brightness: Brightness.light,
          primary: const Color(0xFF6B9B5A),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFF6B9B5A),
          foregroundColor: Colors.white,
        ),
      );

}

/// 감정 강도 1~10에 따른 색상 (카드 배지 등).
Color intensityColor(int intensity) {
  if (intensity <= 2) return const Color(0xFF81C784); // 연한 초록
  if (intensity <= 4) return const Color(0xFFAED581);
  if (intensity <= 6) return const Color(0xFFFFD54F); // 노랑
  if (intensity <= 8) return const Color(0xFFFFB74D);
  return const Color(0xFFFF8A65); // 강할수록 주황/빨강 쪽
}
