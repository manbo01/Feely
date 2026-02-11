import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/diary_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/diary_detail_screen.dart';
import 'screens/diary_write_screen.dart';
import 'screens/main_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

class FeelyApp extends StatelessWidget {
  const FeelyApp({super.key});

  static ThemeData _splashTheme() {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: FeelySplashColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppThemeData.feelyLavender,
        brightness: Brightness.light,
        primary: AppThemeData.feelyLavender,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DiaryProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          if (!settingsProvider.loaded) {
            return MaterialApp(
              theme: _splashTheme(),
              debugShowCheckedModeBanner: false,
              home: const SplashScreen(progress: 0.2),
            );
          }
          final theme = AppThemeData.forTheme(settingsProvider.settings.theme);
          return MaterialApp(
            title: 'Feely',
            theme: theme,
            locale: const Locale('ko'),
            debugShowCheckedModeBanner: false,
            home: const SplashThenMain(child: MainScreen()),
            routes: {
              '/settings': (context) => const SettingsScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/detail') {
                final id = settings.arguments as String?;
                if (id != null) {
                  return MaterialPageRoute(
                    builder: (context) => DiaryDetailScreen(entryId: id),
                  );
                }
              }
              if (settings.name == '/edit') {
                final id = settings.arguments as String?;
                if (id != null) {
                  return MaterialPageRoute(
                    builder: (context) => DiaryWriteScreen(entryId: id),
                  );
                }
              }
              if (settings.name == '/write') {
                final date = settings.arguments as DateTime?;
                return MaterialPageRoute(
                  builder: (context) => DiaryWriteScreen(initialDate: date),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
