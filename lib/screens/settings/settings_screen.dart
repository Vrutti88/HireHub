import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../providers/application_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/interview_provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/saved_jobs_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/firestore_service.dart';
import '../auth/auth_screen.dart';
import '../salary/salary_explorer_screen.dart';
import 'application_health_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings & Privacy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenMargin),
        children: [
          // Section: Recruiter Visibility & Privacy
          _buildSectionHeader('Privacy & Recruiter Visibility'),
          _buildCard([
            SwitchListTile(
              title: Text('Stealth Mode (Shield Profile)', style: AppTypography.titleSm),
              subtitle: Text(
                'Prevent current employers from viewing your active application status.',
                style: AppTypography.bodySm.copyWith(fontSize: 11),
              ),
              value: settings.stealthMode,
              activeThumbColor: AppColors.primary,
              onChanged: (v) => settings.setStealthMode(v),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.security_rounded, color: AppColors.primary),
              title: Text('Resume Privacy', style: AppTypography.bodyMd),
              subtitle: const Text('Verified recruiters only', style: TextStyle(fontSize: 11)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 20),

          // Section: Career & Compensation Tools
          _buildSectionHeader('Career & Compensation Tools'),
          _buildCard([
            ListTile(
              leading: const Icon(Icons.health_and_safety_outlined, color: AppColors.accent),
              title: Text('Application Health Score', style: AppTypography.bodyMd),
              subtitle: const Text('78/100 • View tips to improve conversion', style: TextStyle(fontSize: 11)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ApplicationHealthScreen()),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.price_change_outlined, color: AppColors.primary),
              title: Text('Salary Negotiation Explorer', style: AppTypography.bodyMd),
              subtitle: const Text('Benchmark compensation percentiles', style: TextStyle(fontSize: 11)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SalaryExplorerScreen()),
                );
              },
            ),
          ]),
          const SizedBox(height: 20),

          // Section: Notifications
          _buildSectionHeader('Notifications'),
          _buildCard([
            SwitchListTile(
              title: Text('Push Notifications', style: AppTypography.bodyMd),
              subtitle: const Text('Real-time interview alerts and shortlist updates', style: TextStyle(fontSize: 11)),
              value: settings.pushNotifications,
              activeThumbColor: AppColors.primary,
              onChanged: (v) => settings.setPushNotifications(v),
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: Text('Email Updates', style: AppTypography.bodyMd),
              subtitle: const Text('Weekly job digest and skill recommendations', style: TextStyle(fontSize: 11)),
              value: settings.emailNotifications,
              activeThumbColor: AppColors.primary,
              onChanged: (v) => settings.setEmailNotifications(v),
            ),
          ]),
          const SizedBox(height: 20),

          // Section: Account & Cloud Sync
          _buildSectionHeader('Account & Cloud Sync'),
          _buildCard([
            ListTile(
              leading: const Icon(Icons.person_outline_rounded, color: AppColors.textPrimary),
              title: Text(auth.user?.name ?? 'Candidate', style: AppTypography.bodyMd),
              subtitle: Text(auth.user?.email ?? 'No email signed in', style: const TextStyle(fontSize: 11)),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.cloud_sync_outlined, color: AppColors.primary),
              title: Text('Sync Job Board with Cloud', style: AppTypography.bodyMd),
              subtitle: const Text('Update latest positions & company data in Firestore', style: TextStyle(fontSize: 11)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () async {
                final firestoreService = FirestoreService();
                await firestoreService.syncCatalogToFirestore();
                if (!context.mounted) return;
                await context.read<JobProvider>().loadJobs();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Synced latest jobs to Cloud Firestore!'),
                    backgroundColor: AppColors.accent,
                  ),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.danger),
              title: Text('Log Out', style: AppTypography.bodyMd.copyWith(color: AppColors.danger)),
              onTap: () async {
                context.read<ApplicationProvider>().clear();
                context.read<InterviewProvider>().clear();
                context.read<NotificationProvider>().clear();
                context.read<SavedJobsProvider>().clear();
                await auth.signOut();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                  (route) => false,
                );
              },
            ),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: AppTypography.labelSm.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.roundedLg,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}
