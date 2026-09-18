import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../models/learning_resource_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/skill_provider.dart';
import '../../widgets/primary_button.dart';
import 'skill_progress_screen.dart';

class SkillDevelopmentScreen extends StatelessWidget {
  const SkillDevelopmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final skillProvider = context.watch<SkillProvider>();
    final authProvider = context.watch<AuthProvider>();
    final resources = skillProvider.currentResources;
    final completedCount = resources.where((r) => r.isCompleted).length;
    final total = resources.length;
    final progressFraction = total > 0 ? completedCount / total : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Skill Development Path'),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights_rounded),
            tooltip: 'My Skill Progress',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SkillProgressScreen()),
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
            // Header Banner
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.infoBg,
                          borderRadius: AppSpacing.roundedFull,
                        ),
                        child: Text(
                          'CURATED ROADMAP',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.info,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$completedCount of $total Completed',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('Learn REST API for Flutter', style: AppTypography.headlineSm),
                  const SizedBox(height: 4),
                  Text(
                    'Essential integration protocol powering mobile data synchronization, authentication, and live feeds.',
                    style: AppTypography.bodySm,
                  ),
                  const SizedBox(height: 14),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: AppSpacing.roundedFull,
                    child: LinearProgressIndicator(
                      value: progressFraction,
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceContainerHigh,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Why Learn This Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.successBg,
                borderRadius: AppSpacing.roundedMd,
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.trending_up_rounded, color: AppColors.accent, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Why learn REST API?', style: AppTypography.titleSm.copyWith(color: AppColors.accent)),
                        const SizedBox(height: 2),
                        Text(
                          'Closing this skill gap boosts your average Job Fit by +12% across 14 matching roles.',
                          style: AppTypography.bodySm.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Roadmap Steps List
            Text('Curated Learning Modules', style: AppTypography.headlineSm),
            const SizedBox(height: 12),

            ...resources.map((res) {
              return _buildResourceCard(context, res, skillProvider, authProvider);
            }),
            const SizedBox(height: 20),

            PrimaryButton(
              text: 'View My Skill Progress & Tech Stack',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SkillProgressScreen()),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceCard(
    BuildContext context,
    LearningResourceModel res,
    SkillProvider skillProvider,
    AuthProvider authProvider,
  ) {
    IconData typeIcon;
    switch (res.type.toLowerCase()) {
      case 'video':
        typeIcon = Icons.play_circle_outline_rounded;
        break;
      case 'article':
        typeIcon = Icons.article_outlined;
        break;
      case 'practice project':
        typeIcon = Icons.code_rounded;
        break;
      case 'documentation':
      default:
        typeIcon = Icons.menu_book_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.roundedLg,
        border: Border.all(
          color: res.isCompleted ? AppColors.accent.withValues(alpha: 0.4) : AppColors.border,
          width: res.isCompleted ? 1.5 : 1.0,
        ),
        boxShadow: AppSpacing.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: AppSpacing.roundedSm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(typeIcon, size: 12, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      res.type.toUpperCase(),
                      style: AppTypography.labelSm.copyWith(fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '• ${res.duration}',
                style: AppTypography.bodySm.copyWith(fontSize: 11),
              ),
              const Spacer(),
              // Checkbox Toggle
              IconButton(
                icon: Icon(
                  res.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: res.isCompleted ? AppColors.accent : AppColors.textSecondary,
                  size: 24,
                ),
                onPressed: () => skillProvider.toggleResource(res.id, authProvider),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(res.title, style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(res.description, style: AppTypography.bodySm),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Provider: ${res.provider}',
                style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => skillProvider.toggleResource(res.id, authProvider),
                child: Text(
                  res.isCompleted ? 'Mark Incomplete' : 'Mark as Completed',
                  style: TextStyle(
                    color: res.isCompleted ? AppColors.textSecondary : AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
