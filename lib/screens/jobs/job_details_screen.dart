import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/job_fit_calculator.dart';
import '../../data/seed_data.dart';
import '../../models/company_model.dart';
import '../../models/job_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/saved_jobs_provider.dart';
import '../../widgets/fit_score_gauge.dart';
import '../../widgets/job_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/skill_chip.dart';
import '../settings/report_job_dialog.dart';
import '../skills/skill_development_screen.dart';
import 'apply_job_screen.dart';
import 'job_fit_screen.dart';

class JobDetailsScreen extends StatelessWidget {
  final JobModel job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final savedJobs = context.watch<SavedJobsProvider>();
    final jobProvider = context.watch<JobProvider>();
    final isSaved = savedJobs.isSaved(job.id);

    // Record view in recently viewed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      savedJobs.recordView(job.id);
    });

    final fitResult = user != null
        ? JobFitCalculator.calculate(user: user, job: job)
        : null;
    final fitScore = fitResult?.overallScore ?? 75;

    // Company info lookup
    CompanyModel? company;
    try {
      company = SeedData.companies.firstWhere((c) => c.id == job.companyId);
    } catch (_) {}

    // Find similar jobs in the same or overlapping stack
    final similarJobs = jobProvider.allJobs.where((j) {
      if (j.id == job.id) return false;
      return j.companyId == job.companyId ||
          j.workMode == job.workMode ||
          j.requiredSkills.any((s) => job.requiredSkills.contains(s));
    }).take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(job.companyName, style: AppTypography.titleMd),
        actions: [
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: isSaved ? AppColors.primary : AppColors.textPrimary,
            ),
            onPressed: () => savedJobs.toggleSave(job.id),
          ),
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'report') {
                showDialog(
                  context: context,
                  builder: (_) => ReportJobDialog(job: job),
                );
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'share', child: Text('Share Job')),
              const PopupMenuItem(value: 'report', child: Text('Report Job Violation')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Company Header
            Text(job.title, style: AppTypography.headlineLg),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(job.companyName, style: AppTypography.titleSm.copyWith(color: AppColors.primary)),
                const SizedBox(width: 6),
                const Icon(Icons.star_rounded, size: 16, color: AppColors.warning),
                Text(job.rating.toString(), style: AppTypography.labelSm),
                const Text(' • '),
                Text(job.location, style: AppTypography.bodySm),
              ],
            ),
            const SizedBox(height: 16),

            // Key Attributes Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoPill(Icons.currency_rupee_rounded, job.formattedSalary, isPrimary: true),
                _buildInfoPill(Icons.work_outline_rounded, job.workMode),
                _buildInfoPill(Icons.badge_outlined, job.jobType),
                _buildInfoPill(Icons.timeline_rounded, '${job.experienceMin}–${job.experienceMax} Yrs Exp'),
              ],
            ),
            const SizedBox(height: 20),

            // Job Fit & Skill Gap Card (Interactive Stitch Component)
            Container(
              padding: const EdgeInsets.all(16),
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
                      FitScoreGauge(score: fitScore, size: 70),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Deterministic Job Fit', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                            const SizedBox(height: 2),
                            Text('$fitScore% Profile Match', style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(
                              fitResult != null
                                  ? '${fitResult.matchedSkills.length} of ${job.requiredSkills.length} required skills verified'
                                  : 'Calculated from 5 weighted profile dimensions',
                              style: AppTypography.bodySm.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => JobFitScreen(job: job)),
                      );
                    },
                    icon: const Icon(Icons.analytics_outlined, size: 16),
                    label: const Text('Analyze Factor Breakdown & Skill Gap →'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // About the Role
            Text('About the Role', style: AppTypography.headlineSm),
            const SizedBox(height: 8),
            Text(
              job.description,
              style: AppTypography.bodyMd.copyWith(height: 1.5),
            ),
            const SizedBox(height: 20),

            // Responsibilities
            Text('Key Responsibilities', style: AppTypography.headlineSm),
            const SizedBox(height: 8),
            ...job.responsibilities.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 6.0),
                        child: Icon(Icons.circle, size: 6, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(r, style: AppTypography.bodyMd),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 20),

            // Skills Breakdown (Matched vs Missing)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Required Technical Skills', style: AppTypography.headlineSm),
                Text(
                  'Tap to Learn',
                  style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: job.requiredSkills.map((s) {
                final isMatched = fitResult?.matchedSkills.contains(s) ?? true;
                return SkillChip(
                  skillName: s,
                  variant: isMatched ? SkillChipVariant.matched : SkillChipVariant.missing,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SkillDevelopmentScreen()),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Benefits
            if (job.benefits.isNotEmpty) ...[
              Text('Perks & Benefits', style: AppTypography.headlineSm),
              const SizedBox(height: 8),
              ...job.benefits.map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_rounded, size: 16, color: AppColors.accent),
                        const SizedBox(width: 8),
                        Text(b, style: AppTypography.bodyMd),
                      ],
                    ),
                  )),
              const SizedBox(height: 20),
            ],

            // Company Culture & Overview Card
            if (company != null) ...[
              Text('About ${company.name}', style: AppTypography.headlineSm),
              const SizedBox(height: 8),
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
                    Text(
                      company.about,
                      style: AppTypography.bodySm.copyWith(height: 1.4, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCompanyMetric('Company Size', company.employeeRange),
                        _buildCompanyMetric('Location', company.location.split(',').first),
                        _buildCompanyMetric('Rating', '★ ${company.rating} / 5.0'),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text('Workplace Ratings', style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    _buildRatingBar('Culture & Values', company.cultureRating),
                    const SizedBox(height: 6),
                    _buildRatingBar('Salary & Benefits', company.salaryRating),
                    const SizedBox(height: 6),
                    _buildRatingBar('Work-Life Balance', company.workLifeRating),
                    const SizedBox(height: 6),
                    _buildRatingBar('Career Growth', company.growthRating),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Similar Open Positions Section
            if (similarJobs.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Similar Open Roles', style: AppTypography.headlineSm),
                  Text('${similarJobs.length} matches', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 12),
              ...similarJobs.map((simJob) {
                return JobCard(
                  job: simJob,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => JobDetailsScreen(job: simJob)),
                    );
                  },
                );
              }),
            ],

            const SizedBox(height: 80), // bottom padding for sticky bar
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: AppSpacing.bottomNavShadow,
          border: const Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => JobFitScreen(job: job)),
                  );
                },
                child: Text('Fit ($fitScore%)'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: PrimaryButton(
                text: 'Apply Now',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ApplyJobScreen(job: job)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPill(IconData icon, String label, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.surfaceContainerLow : AppColors.surface,
        borderRadius: AppSpacing.roundedSm,
        border: Border.all(
          color: isPrimary ? AppColors.tertiaryContainer : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isPrimary ? AppColors.primary : AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: isPrimary ? AppColors.primary : AppColors.textPrimary,
              fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildRatingBar(String label, double rating) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: AppTypography.bodySm.copyWith(fontSize: 12)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: AppSpacing.roundedFull,
            child: LinearProgressIndicator(
              value: (rating / 5.0).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 24,
          child: Text(
            rating.toStringAsFixed(1),
            style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w700, fontSize: 11),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
