import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/app_typography.dart';
import '../core/utils/job_fit_calculator.dart';
import '../models/job_model.dart';
import '../providers/auth_provider.dart';
import '../providers/saved_jobs_provider.dart';

class JobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback onTap;
  final bool isSelectionMode;
  final bool isSelected;
  final ValueChanged<bool?>? onSelectionChanged;

  const JobCard({
    super.key,
    required this.job,
    required this.onTap,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final savedJobs = context.watch<SavedJobsProvider>();
    final isSaved = savedJobs.isSaved(job.id);

    // Calculate dynamic fit score
    final fitResult = user != null
        ? JobFitCalculator.calculate(user: user, job: job)
        : null;
    final fitScore = fitResult?.overallScore ?? 75;

    Color badgeBg;
    Color badgeText;
    if (fitScore >= 80) {
      badgeBg = AppColors.successBg;
      badgeText = AppColors.accent;
    } else if (fitScore >= 60) {
      badgeBg = AppColors.infoBg;
      badgeText = AppColors.primary;
    } else {
      badgeBg = AppColors.warningBg;
      badgeText = AppColors.warning;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.roundedLg,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: AppSpacing.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppSpacing.roundedLg,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isSelectionMode) ...[
                      Checkbox(
                        value: isSelected,
                        onChanged: onSelectionChanged,
                        activeColor: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                    ],
                    // Company Avatar
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: AppSpacing.roundedSm,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        job.companyName.isNotEmpty ? job.companyName[0] : 'C',
                        style: AppTypography.titleMd.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title and Company
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: AppTypography.titleMd.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                job.companyName,
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
                              Text(
                                job.rating.toString(),
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const Text(' • '),
                              Text(
                                job.location,
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Bookmark Button
                    IconButton(
                      icon: Icon(
                        isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: isSaved ? AppColors.primary : AppColors.textSecondary,
                        size: 22,
                      ),
                      onPressed: () => savedJobs.toggleSave(job.id),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Tags: Salary, Work Mode, Job Type
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildTag(job.formattedSalary, isHighlight: true),
                    _buildTag(job.workMode),
                    _buildTag('${job.experienceMin}–${job.experienceMax} yrs exp'),
                  ],
                ),
                const SizedBox(height: 12),

                const Divider(height: 1, color: AppColors.borderSubtle),
                const SizedBox(height: 10),

                // Bottom Row: Fit Score & Matched skills
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: AppSpacing.roundedFull,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt_rounded, size: 14, color: badgeText),
                          const SizedBox(width: 4),
                          Text(
                            '$fitScore% Fit',
                            style: AppTypography.labelSm.copyWith(
                              color: badgeText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (fitResult != null)
                      Text(
                        '${fitResult.matchedSkills.length}/${job.requiredSkills.length} skills matched',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textSecondary),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlight ? AppColors.surfaceContainerLow : AppColors.background,
        borderRadius: AppSpacing.roundedSm,
        border: Border.all(
          color: isHighlight ? AppColors.tertiaryContainer : AppColors.border,
          width: 0.8,
        ),
      ),
      child: Text(
        text,
        style: AppTypography.labelSm.copyWith(
          color: isHighlight ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }
}
