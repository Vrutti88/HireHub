import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/app_typography.dart';
import '../models/application_model.dart';

class ApplicationCard extends StatelessWidget {
  final ApplicationModel application;
  final VoidCallback onTap;

  const ApplicationCard({
    super.key,
    required this.application,
    required this.onTap,
  });

  Color get statusBgColor {
    switch (application.status.toLowerCase()) {
      case 'interview':
        return AppColors.infoBg;
      case 'shortlisted':
      case 'selected':
        return AppColors.successBg;
      case 'rejected':
      case 'withdrawn':
        return AppColors.dangerBg;
      case 'applied':
      case 'viewed':
      default:
        return AppColors.surfaceContainer;
    }
  }

  Color get statusTextColor {
    switch (application.status.toLowerCase()) {
      case 'interview':
        return AppColors.info;
      case 'shortlisted':
      case 'selected':
        return AppColors.success;
      case 'rejected':
      case 'withdrawn':
        return AppColors.danger;
      case 'applied':
      case 'viewed':
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.roundedLg,
        border: Border.all(color: AppColors.border, width: 1),
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
                // Top Row: Status badge & Applied date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: AppSpacing.roundedFull,
                      ),
                      child: Text(
                        application.status.toUpperCase(),
                        style: AppTypography.labelSm.copyWith(
                          color: statusTextColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Text(
                      'Applied ${dateFormat.format(application.appliedAt)}',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Job Title & Company
                Text(
                  application.jobTitle,
                  style: AppTypography.titleMd.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${application.companyName} • ${application.location}',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),

                // Salary tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: AppSpacing.roundedSm,
                    border: Border.all(color: AppColors.border, width: 0.8),
                  ),
                  child: Text(
                    application.salaryFormatted,
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                const Divider(height: 1, color: AppColors.borderSubtle),
                const SizedBox(height: 10),

                // Pipeline summary / Next action
                Row(
                  children: [
                    Icon(
                      application.status == 'interview'
                          ? Icons.event_available_rounded
                          : Icons.timeline_rounded,
                      size: 16,
                      color: statusTextColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        application.status == 'interview'
                            ? 'Interview Round Active • View prep questions'
                            : (application.timeline.isNotEmpty
                                ? application.timeline.last.title
                                : 'Application under review'),
                        style: AppTypography.bodySm.copyWith(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
}
