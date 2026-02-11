import 'package:flutter/material.dart';

import '../models/app_settings.dart';

class AppThemeData {
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
      case AppTheme.purple:
        return _purple;
    }
  }

  static ThemeData get _light => ThemeData.light().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C9EAD),
          brightness: Brightness.light,
          primary: const Color(0xFF5C9EAD),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFF5C9EAD),
          foregroundColor: Colors.white,
        ),
      );

  static ThemeData get _dark => ThemeData.dark().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7EB8DA),
          brightness: Brightness.dark,
          primary: const Color(0xFF7EB8DA),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFF1E3A5F),
          foregroundColor: Colors.white,
        ),
      );

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

  static ThemeData get _purple => ThemeData.light().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9B8BB8),
          brightness: Brightness.light,
          primary: const Color(0xFF9B8BB8),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFF9B8BB8),
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
