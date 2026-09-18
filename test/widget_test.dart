import 'package:flutter_test/flutter_test.dart';
import 'package:hirehub/app.dart';
import 'package:hirehub/providers/application_provider.dart';
import 'package:hirehub/providers/auth_provider.dart';
import 'package:hirehub/providers/interview_provider.dart';
import 'package:hirehub/providers/job_provider.dart';
import 'package:hirehub/providers/notification_provider.dart';
import 'package:hirehub/providers/saved_jobs_provider.dart';
import 'package:hirehub/providers/settings_provider.dart';
import 'package:hirehub/providers/skill_provider.dart';
import 'package:hirehub/services/auth_service.dart';
import 'package:hirehub/services/firestore_service.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('HireHub App launches to Splash Screen with brand title', (WidgetTester tester) async {
    final firestoreService = FirestoreService();
    final authService = AuthService(firestoreService);

    await tester.pumpWidget(
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

    // Verify HireHub logo text and tagline on splash screen
    expect(find.text('HireHub'), findsOneWidget);
    expect(find.text('Find Jobs. Build Skills. Grow Your Career.'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2500));
  });
}
