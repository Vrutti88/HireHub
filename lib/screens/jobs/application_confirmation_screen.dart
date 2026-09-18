import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../models/application_model.dart';
import '../../widgets/primary_button.dart';
import '../main_navigation_screen.dart';

class ApplicationConfirmationScreen extends StatelessWidget {
  final ApplicationModel application;

  const ApplicationConfirmationScreen({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Success Animated Mark
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: AppColors.successBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.accent,
                  size: 56,
                ),
              ),
              const SizedBox(height: 24),

              Text('Application Submitted!', style: AppTypography.headlineLg),
              const SizedBox(height: 8),
              Text(
                'Your verified technical credentials and resume have been forwarded directly to ${application.companyName}.',
                style: AppTypography.bodyMd,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Job Summary Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppSpacing.roundedLg,
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppSpacing.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Applied Role', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(application.jobTitle, style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.w700)),
                    Text(
                      '${application.companyName} • ${application.location}',
                      style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Application ID', style: AppTypography.bodySm),
                        Text(
                          '#${application.id.substring(0, 8).toUpperCase()}',
                          style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Recruitment Pipeline Preview
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppSpacing.roundedLg,
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recruitment Pipeline', style: AppTypography.titleSm),
                    const SizedBox(height: 14),
                    _buildPipelineStep('1. Application Received', 'Resume verified', true, false),
                    _buildPipelineStep('2. Profile Screening', 'Recruiter SLA: Under 48 hours', false, true),
                    _buildPipelineStep('3. Technical Round 1', 'Interactive code & architecture review', false, false),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              PrimaryButton(
                text: 'Track in Applications Pipeline',
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const MainNavigationScreen(initialIndex: 3), // Index 3 is Applications
                    ),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainNavigationScreen(initialIndex: 0)),
                    (route) => false,
                  );
                },
                child: const Text('Back to Home Dashboard'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPipelineStep(String title, String subtitle, bool isCompleted, bool isCurrent) {
    Color dotColor = AppColors.border;
    if (isCompleted) dotColor = AppColors.accent;
    if (isCurrent) dotColor = AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Icon(
              isCompleted ? Icons.check_circle_rounded : Icons.radio_button_checked_rounded,
              size: 18,
              color: dotColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelMd.copyWith(
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                    color: isCurrent ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                Text(subtitle, style: AppTypography.bodySm.copyWith(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
