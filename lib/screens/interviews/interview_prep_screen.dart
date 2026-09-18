import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../widgets/primary_button.dart';
import 'interviews_calendar_screen.dart';

class InterviewPrepScreen extends StatefulWidget {
  const InterviewPrepScreen({super.key});

  @override
  State<InterviewPrepScreen> createState() => _InterviewPrepScreenState();
}

class _InterviewPrepScreenState extends State<InterviewPrepScreen> {
  final Set<int> _checkedTasks = {0};

  final List<Map<String, String>> _questions = [
    {
      'q': 'How do you prevent memory leaks in Flutter when working with Streams and AnimationControllers?',
      'a': 'Always cancel StreamSubscription instances inside the State object\'s dispose() method or use StreamBuilder which handles subscription lifecycle automatically. For AnimationController, always invoke controller.dispose() before super.dispose().',
    },
    {
      'q': 'Explain Provider vs. Riverpod vs. BLoC. When would you strictly mandate BLoC in an enterprise Flutter codebase?',
      'a': 'Provider relies on the widget tree and InheritedWidget. Riverpod is compile-safe and independent of BuildContext. BLoC strictly decouples events and states via reactive streams, making it mandatory for high-audit enterprise apps requiring deterministic state testing and replayability.',
    },
    {
      'q': 'How do you structure an offline-first caching layer in Flutter?',
      'a': 'Implement a Repository Pattern that wraps local storage (Hive or Isar) and remote HTTP client (Dio). When fetching data, return cached records immediately while firing a background refresh and writing back to local database.',
    },
  ];

  final List<String> _checklist = [
    'Review StreamSubscription cancel patterns in dispose()',
    'Prepare 2 architectural examples using Repository Pattern',
    'Test headset and Google Meet video connection',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Interview Preparation Hub'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Intel Card
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
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: AppSpacing.roundedSm,
                        ),
                        child: const Icon(Icons.corporate_fare_rounded, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CloudMatrix Engineering Intel', style: AppTypography.titleSm),
                            Text('Logistics & Real-Time Mobility • 500+ Engineers', style: AppTypography.bodySm.copyWith(fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Text(
                    'CloudMatrix places heavy emphasis on reactive Flutter architecture, clean separation of concerns, and robust error handling for real-time driver apps.',
                    style: AppTypography.bodySm.copyWith(height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Predictive Technical Questions
            Text('Predictive Technical Questions', style: AppTypography.headlineSm),
            const SizedBox(height: 12),

            ..._questions.map((q) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppSpacing.roundedMd,
                  border: Border.all(color: AppColors.border),
                ),
                child: ExpansionTile(
                  title: Text(
                    q['q']!,
                    style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: AppSpacing.roundedSm,
                        ),
                        child: Text(
                          q['a']!,
                          style: AppTypography.bodySm.copyWith(color: AppColors.primary, height: 1.4),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),

            // Pre-Interview Checklist
            Text('Pre-Interview Checklist', style: AppTypography.headlineSm),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.roundedLg,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: _checklist.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final task = entry.value;
                  final isDone = _checkedTasks.contains(idx);

                  return CheckboxListTile(
                    value: isDone,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _checkedTasks.add(idx);
                        } else {
                          _checkedTasks.remove(idx);
                        }
                      });
                    },
                    title: Text(
                      task,
                      style: AppTypography.bodyMd.copyWith(
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        color: isDone ? AppColors.textSecondary : AppColors.textPrimary,
                      ),
                    ),
                    activeColor: AppColors.accent,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            PrimaryButton(
              text: 'View Full Interview Schedule & Calendar',
              icon: Icons.calendar_month_rounded,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const InterviewsCalendarScreen()),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
