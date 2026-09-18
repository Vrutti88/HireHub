import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/job_fit_calculator.dart';
import '../../models/job_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/primary_button.dart';
import 'decision_matrix_screen.dart';

class JobComparisonScreen extends StatelessWidget {
  final List<JobModel> jobs;

  const JobComparisonScreen({super.key, required this.jobs});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Side-by-Side Comparison'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.analytics_rounded, size: 18),
            label: const Text('Decision Matrix'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => DecisionMatrixScreen(jobs: jobs)),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column Headers: Roles
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCell('Attributes'),
                  ...jobs.map((job) => _buildJobTitleCell(job)),
                ],
              ),
              const Divider(),

              // Row 1: Compensation
              _buildComparisonRow(
                'Compensation',
                jobs.map((j) => j.formattedSalary).toList(),
                isHighlight: true,
              ),

              // Row 2: Deterministic Fit Score
              _buildComparisonRow(
                'Job Fit Score',
                jobs.map((j) {
                  final score = user != null
                      ? JobFitCalculator.calculate(user: user, job: j).overallScore
                      : 75;
                  return '$score% Match';
                }).toList(),
                isHighlight: true,
              ),

              // Row 3: Work Mode
              _buildComparisonRow(
                'Work Mode',
                jobs.map((j) => '${j.workMode} (${j.location})').toList(),
              ),

              // Row 4: Experience Required
              _buildComparisonRow(
                'Experience Req.',
                jobs.map((j) => '${j.experienceMin}–${j.experienceMax} years').toList(),
              ),

              // Row 5: Company Rating
              _buildComparisonRow(
                'Company Rating',
                jobs.map((j) => '★ ${j.rating} / 5.0').toList(),
              ),

              // Row 6: Required Skills Count
              _buildComparisonRow(
                'Key Skills',
                jobs.map((j) => j.requiredSkills.take(3).join(', ')).toList(),
              ),

              // Row 7: Benefits
              _buildComparisonRow(
                'Top Benefit',
                jobs.map((j) => j.benefits.isNotEmpty ? j.benefits.first : 'Standard Benefits').toList(),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: 400,
                child: PrimaryButton(
                  text: 'Evaluate in Decision Matrix',
                  icon: Icons.calculate_rounded,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => DecisionMatrixScreen(jobs: jobs)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildJobTitleCell(JobModel job) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(left: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.title,
            style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.w700),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            job.companyName,
            style: AppTypography.bodySm.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, List<String> values, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildHeaderCell(label),
          ...values.map((val) {
            return Container(
              width: 200,
              margin: const EdgeInsets.only(left: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isHighlight ? AppColors.surfaceContainerLow : AppColors.surface,
                borderRadius: AppSpacing.roundedSm,
                border: Border.all(
                  color: isHighlight ? AppColors.tertiaryContainer : AppColors.border,
                ),
              ),
              child: Text(
                val,
                style: AppTypography.bodySm.copyWith(
                  fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
                  color: isHighlight ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
