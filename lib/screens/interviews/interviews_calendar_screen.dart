import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../providers/interview_provider.dart';
import '../../widgets/primary_button.dart';
import 'interview_prep_screen.dart';

class InterviewsCalendarScreen extends StatefulWidget {
  const InterviewsCalendarScreen({super.key});

  @override
  State<InterviewsCalendarScreen> createState() => _InterviewsCalendarScreenState();
}

class _InterviewsCalendarScreenState extends State<InterviewsCalendarScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 2));

  @override
  Widget build(BuildContext context) {
    final interviewProvider = context.watch<InterviewProvider>();
    final interviews = interviewProvider.interviews;
    final monthFormat = DateFormat('MMMM yyyy');
    final dayOfWeekFormat = DateFormat('E');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Interview Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const InterviewPrepScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(monthFormat.format(DateTime.now()), style: AppTypography.headlineSm),
                Text(
                  '${interviews.length} Scheduled',
                  style: AppTypography.labelSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Horizontal Calendar Strip
            SizedBox(
              height: 76,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 14,
                itemBuilder: (context, index) {
                  final date = DateTime.now().add(Duration(days: index));
                  final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;
                  final hasInterview = interviews.any((i) => i.dateTime.day == date.day && i.dateTime.month == date.month);

                  return GestureDetector(
                    onTap: () => setState(() => _selectedDate = date),
                    child: Container(
                      width: 52,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surface,
                        borderRadius: AppSpacing.roundedMd,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dayOfWeekFormat.format(date),
                            style: AppTypography.labelSm.copyWith(
                              color: isSelected ? Colors.white70 : AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date.day.toString(),
                            style: AppTypography.titleMd.copyWith(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (hasInterview) ...[
                            const SizedBox(height: 4),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.accent : AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            Text('Upcoming Sessions', style: AppTypography.headlineSm),
            const SizedBox(height: 12),

            if (interviews.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppSpacing.roundedLg,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Text('No interviews scheduled for this date.'),
                ),
              )
            else
              ...interviews.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
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
                              color: AppColors.infoBg,
                              borderRadius: AppSpacing.roundedFull,
                            ),
                            child: Text(
                              item.type.toUpperCase(),
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.info,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                item.reminderActive ? 'Reminder On' : 'Reminder Off',
                                style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary, fontSize: 11),
                              ),
                              Switch(
                                value: item.reminderActive,
                                activeThumbColor: AppColors.accent,
                                onChanged: (_) => interviewProvider.toggleReminder(item.id),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(item.roundName, style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(
                        '${item.companyName} • ${item.jobTitle}',
                        style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('EEEE, MMM dd • hh:mm a').format(item.dateTime),
                            style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      if (item.meetingLink != null) ...[
                        PrimaryButton(
                          text: 'Join Live Google Meet',
                          icon: Icons.videocam_rounded,
                          backgroundColor: AppColors.primary,
                          height: 42,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Launching meeting: ${item.meetingLink}'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                      ],

                      OutlinedButton.icon(
                        icon: const Icon(Icons.checklist_rounded, size: 16),
                        label: const Text('Open Interview Prep Checklist'),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const InterviewPrepScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
