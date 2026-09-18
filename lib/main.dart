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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProvider(create: (_) => JobProvider(firestoreService)),
        ChangeNotifierProvider(create: (_) => ApplicationProvider(firestoreService)),
        ChangeNotifierProvider(create: (_) => SkillProvider(firestoreService)),
        ChangeNotifierProvider(create: (_) => InterviewProvider(firestoreService)),
        ChangeNotifierProvider(create: (_) => SavedJobsProvider(firestoreService)),
        ChangeNotifierProvider(create: (_) => NotificationProvider(firestoreService)),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const HireHubApp(),
    ),
  );
}
