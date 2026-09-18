import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/app_typography.dart';
import '../core/utils/job_fit_calculator.dart';

class FitFactorBar extends StatelessWidget {
  final FitFactorScore factor;

  const FitFactorBar({super.key, required this.factor});

  Color get barColor {
    if (factor.scorePercent >= 80) return AppColors.accent;
    if (factor.scorePercent >= 60) return AppColors.primary;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                factor.factorName,
                style: AppTypography.labelMd.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${factor.scorePercent.round()}% (${(factor.weight * 100).toInt()}% wt)',
                style: AppTypography.labelSm.copyWith(
                  color: barColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: AppSpacing.roundedFull,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: factor.scorePercent / 100.0),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutQuad,
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  color: barColor,
                );
              },
            ),
          ),
          const SizedBox(height: 2),
          Text(
            factor.description,
            style: AppTypography.bodySm.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
