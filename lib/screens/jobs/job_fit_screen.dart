import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/job_fit_calculator.dart';
import '../../core/utils/skill_gap_analyzer.dart';
import '../../models/job_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/fit_factor_bar.dart';
import '../../widgets/fit_score_gauge.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/skill_chip.dart';
import '../skills/skill_development_screen.dart';

class JobFitScreen extends StatelessWidget {
  final JobModel job;

  const JobFitScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Job Fit Analysis')),
        body: const Center(child: Text('Please sign in to view fit score.')),
      );
    }

    final fitResult = JobFitCalculator.calculate(user: user, job: job);
    final skillGaps = SkillGapAnalyzer.analyze(user: user, job: job);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Job Fit & Skill Gap Analysis'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Score Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.roundedLg,
                border: Border.all(color: AppColors.border),
                boxShadow: AppSpacing.cardShadow,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      FitScoreGauge(score: fitResult.overallScore, size: 90, strokeWidth: 9),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.title,
                              style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              job.companyName,
                              style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: fitResult.overallScore >= 80 ? AppColors.successBg : AppColors.infoBg,
                                borderRadius: AppSpacing.roundedFull,
                              ),
                              child: Text(
                                fitResult.overallScore >= 80
                                    ? 'High Candidate Match'
                                    : 'Good Match • Skill Boost Possible',
                                style: AppTypography.labelSm.copyWith(
                                  color: fitResult.overallScore >= 80 ? AppColors.accent : AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Skill Gap ROI Simulation Banner (Stitch Screen 7 Highlight)
            if (fitResult.missingSkills.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF12355B), Color(0xFF0F3057)],
                  ),
                  borderRadius: AppSpacing.roundedLg,
                  boxShadow: AppSpacing.elevatedShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_graph_rounded, color: AppColors.accent, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'SKILL GAP ROI PROJECTION',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Closing the ${fitResult.missingSkills.first} gap increases your score to ${fitResult.skillBoostSimulation[fitResult.missingSkills.first] ?? (fitResult.overallScore + 12)}%.',
                      style: AppTypography.titleSm.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      text: 'Start Learning ${fitResult.missingSkills.first}',
                      backgroundColor: AppColors.accent,
                      height: 40,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SkillDevelopmentScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 5-Factor Weighted Breakdown
            Text('Weighted Factor Breakdown', style: AppTypography.headlineSm),
            const SizedBox(height: 6),
            Text(
              'Deterministic rule-based formula evaluated across 5 dimensions:',
              style: AppTypography.bodySm,
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.roundedLg,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: fitResult.factorBreakdown.map((f) => FitFactorBar(factor: f)).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Matched Skills Section
            Text('Verified Matching Skills (${fitResult.matchedSkills.length})', style: AppTypography.headlineSm),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: fitResult.matchedSkills.map((s) {
                return SkillChip(
                  skillName: s,
                  variant: SkillChipVariant.matched,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Missing Skills & Gaps
            if (skillGaps.isNotEmpty) ...[
              Text('Skill Gaps to Address (${skillGaps.length})', style: AppTypography.headlineSm),
              const SizedBox(height: 10),
              ...skillGaps.map((gap) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppSpacing.roundedMd,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: AppColors.warningBg,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.school_rounded, color: AppColors.warning, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(gap.skillName, style: AppTypography.titleSm),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.dangerBg,
                                    borderRadius: AppSpacing.roundedSm,
                                  ),
                                  child: Text(
                                    gap.priority,
                                    style: AppTypography.labelSm.copyWith(
                                      color: AppColors.danger,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '+${gap.projectedFitBoostPercent}% fit score boost when mastered',
                              style: AppTypography.bodySm.copyWith(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SkillDevelopmentScreen()),
                          );
                        },
                        child: const Text('Learn'),
                      ),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
