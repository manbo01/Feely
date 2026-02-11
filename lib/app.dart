import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/diary_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/diary_detail_screen.dart';
import 'screens/diary_write_screen.dart';
import 'screens/main_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';

class FeelyApp extends StatelessWidget {
  const FeelyApp({super.key});

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
              theme: ThemeData.light(),
              debugShowCheckedModeBanner: false,
              home: const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }
          final theme = AppThemeData.forTheme(settingsProvider.settings.theme);
          return MaterialApp(
            title: 'Feely',
            theme: theme,
            locale: const Locale('ko'),
            debugShowCheckedModeBanner: false,
            home: const MainScreen(),
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
