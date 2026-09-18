import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/application_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/interview_provider.dart';
import 'providers/job_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/saved_jobs_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/skill_provider.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';

import 'firebase_options.dart';
import 'data/seed_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Firebase with multiplatform options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization note: $e');
  }

  final firestoreService = FirestoreService();
  final authService = AuthService(firestoreService);

  final authProvider = AuthProvider(authService);
  final jobProvider = JobProvider(firestoreService);
  final appProvider = ApplicationProvider(firestoreService);
  final skillProvider = SkillProvider(firestoreService);
  final interviewProvider = InterviewProvider(firestoreService);
  final savedJobsProvider = SavedJobsProvider(firestoreService);
  final notifProvider = NotificationProvider(firestoreService);
  final settingsProvider = SettingsProvider();

  try {
    if (Uri.base.queryParameters.containsKey('screen')) {
      authProvider.setMockUser(SeedData.initialUser);
      appProvider.loadApplications(SeedData.initialUser.uid);
      interviewProvider.loadInterviews(SeedData.initialUser.uid);
      notifProvider.loadData(SeedData.initialUser.uid);
      savedJobsProvider.loadSavedJobs(SeedData.initialUser.uid);
    }
  } catch (_) {}

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: jobProvider),
        ChangeNotifierProvider.value(value: appProvider),
        ChangeNotifierProvider.value(value: skillProvider),
        ChangeNotifierProvider.value(value: interviewProvider),
        ChangeNotifierProvider.value(value: savedJobsProvider),
        ChangeNotifierProvider.value(value: notifProvider),
        ChangeNotifierProvider.value(value: settingsProvider),
      ],
      child: const HireHubApp(),
    ),
  );
}
