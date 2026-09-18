import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';

enum SkillChipVariant {
  matched,
  missing,
  neutral,
  learning,
}

class SkillChip extends StatelessWidget {
  final String skillName;
  final SkillChipVariant variant;
  final VoidCallback? onTap;

  const SkillChip({
    super.key,
    required this.skillName,
    this.variant = SkillChipVariant.neutral,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color text;
    IconData? icon;

    switch (variant) {
      case SkillChipVariant.matched:
        bg = AppColors.successBg;
        border = AppColors.accent.withValues(alpha: 0.3);
        text = AppColors.accent;
        icon = Icons.check_circle_rounded;
        break;
      case SkillChipVariant.missing:
        bg = AppColors.warningBg;
        border = AppColors.warning.withValues(alpha: 0.3);
        text = AppColors.warning;
        icon = Icons.add_circle_outline_rounded;
        break;
      case SkillChipVariant.learning:
        bg = AppColors.infoBg;
        border = AppColors.info.withValues(alpha: 0.3);
        text = AppColors.info;
        icon = Icons.auto_stories_rounded;
        break;
      case SkillChipVariant.neutral:
        bg = AppColors.background;
        border = AppColors.border;
        text = AppColors.textPrimary;
        icon = null;
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(color: border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: text),
              const SizedBox(width: 4),
            ],
            Text(
              skillName,
              style: AppTypography.labelSm.copyWith(
                color: text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
