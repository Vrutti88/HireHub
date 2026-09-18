import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/settings_provider.dart';
import 'screens/splash/splash_screen.dart';

class HireHubApp extends StatelessWidget {
  const HireHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      title: 'HireHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: settings.themeMode,
      home: const SplashScreen(),
    );
  }
}
