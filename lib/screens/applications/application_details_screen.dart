import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../models/application_model.dart';
import '../../providers/application_provider.dart';
import '../../widgets/primary_button.dart';
import '../interviews/interview_prep_screen.dart';
import '../interviews/interviews_calendar_screen.dart';

class ApplicationDetailsScreen extends StatelessWidget {
  final ApplicationModel application;

  const ApplicationDetailsScreen({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Application Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status & Header Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.roundedLg,
                border: Border.all(color: AppColors.border),
                boxShadow: AppSpacing.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: application.status == 'interview'
                              ? AppColors.infoBg
                              : AppColors.successBg,
                          borderRadius: AppSpacing.roundedFull,
                        ),
                        child: Text(
                          application.status.toUpperCase(),
                          style: AppTypography.labelSm.copyWith(
                            color: application.status == 'interview'
                                ? AppColors.info
                                : AppColors.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        'ID #${application.id.substring(0, 8).toUpperCase()}',
                        style: AppTypography.bodySm.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(application.jobTitle, style: AppTypography.headlineSm),
                  Text(
                    '${application.companyName} • ${application.location}',
                    style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Compensation', style: AppTypography.bodySm),
                      Text(application.salaryFormatted, style: AppTypography.labelMd.copyWith(color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Timeline Section
            Text('Recruitment Timeline', style: AppTypography.headlineSm),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.roundedLg,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: application.timeline.map((event) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2.0),
                          child: Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(event.title, style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text(event.description, style: AppTypography.bodySm),
                              const SizedBox(height: 4),
                              Text(
                                dateFormat.format(event.timestamp),
                                style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Cover Letter & Pitch
            if (application.coverLetter.isNotEmpty) ...[
              Text('Submitted Candidate Pitch', style: AppTypography.headlineSm),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppSpacing.roundedMd,
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  application.coverLetter,
                  style: AppTypography.bodyMd.copyWith(height: 1.4),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Action Buttons
            if (application.status == 'interview') ...[
              PrimaryButton(
                text: 'View Interview Prep Questions (Screen 15)',
                icon: Icons.question_answer_outlined,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const InterviewPrepScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_month_rounded),
                label: const Text('View Calendar & Schedule (Screen 16)'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const InterviewsCalendarScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],

            OutlinedButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Withdraw Application?'),
                    content: const Text('Are you sure you want to withdraw this application? This action cannot be undone.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Withdraw'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  await context.read<ApplicationProvider>().updateStatus(application.id, 'withdrawn');
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
              child: const Text('Withdraw Application', style: TextStyle(color: AppColors.danger)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
