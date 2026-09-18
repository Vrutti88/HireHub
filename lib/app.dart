import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/seed_data.dart';
import 'providers/settings_provider.dart';
import 'screens/interviews/interview_prep_screen.dart';
import 'screens/jobs/decision_matrix_screen.dart';
import 'screens/jobs/job_details_screen.dart';
import 'screens/jobs/job_fit_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/salary/salary_explorer_screen.dart';
import 'screens/settings/application_health_screen.dart';
import 'screens/splash/splash_screen.dart';

class HireHubApp extends StatelessWidget {
  const HireHubApp({super.key});

  Widget _resolveHome() {
    try {
      final screen = Uri.base.queryParameters['screen'];
      if (screen != null) {
        switch (screen) {
          case 'home':
            return const MainNavigationScreen(initialIndex: 0);
          case 'search':
            return const MainNavigationScreen(initialIndex: 1);
          case 'saved':
            return const MainNavigationScreen(initialIndex: 2);
          case 'applications':
            return const MainNavigationScreen(initialIndex: 3);
          case 'profile':
            return const MainNavigationScreen(initialIndex: 4);
          case 'job_details':
            return JobDetailsScreen(job: SeedData.jobs.first);
          case 'job_fit':
            return JobFitScreen(job: SeedData.jobs.first);
          case 'decision_matrix':
            return DecisionMatrixScreen(jobs: SeedData.jobs.take(3).toList());
          case 'health':
            return const ApplicationHealthScreen();
          case 'salary':
            return const SalaryExplorerScreen();
          case 'prep':
            return const InterviewPrepScreen();
        }
      }
    } catch (_) {}
    return const SplashScreen();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      title: 'HireHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: settings.themeMode,
      home: _resolveHome(),
    );
  }
}
