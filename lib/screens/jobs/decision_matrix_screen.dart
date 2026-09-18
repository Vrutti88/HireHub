import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/decision_matrix_calculator.dart';
import '../../models/job_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/primary_button.dart';
import 'job_details_screen.dart';

class DecisionMatrixScreen extends StatefulWidget {
  final List<JobModel> jobs;

  const DecisionMatrixScreen({super.key, required this.jobs});

  @override
  State<DecisionMatrixScreen> createState() => _DecisionMatrixScreenState();
}

class _DecisionMatrixScreenState extends State<DecisionMatrixScreen> {
  String _activePreset = 'Balanced';
  double _weightComp = 0.25;
  double _weightRemote = 0.20;
  double _weightRating = 0.15;
  double _weightGrowth = 0.20;
  double _weightFit = 0.20;

  void _applyPreset(String preset) {
    setState(() {
      _activePreset = preset;
      if (preset == 'Balanced') {
        _weightComp = 0.25;
        _weightRemote = 0.20;
        _weightRating = 0.15;
        _weightGrowth = 0.20;
        _weightFit = 0.20;
      } else if (preset == 'High Compensation') {
        _weightComp = 0.45;
        _weightRemote = 0.15;
        _weightRating = 0.10;
        _weightGrowth = 0.15;
        _weightFit = 0.15;
      } else if (preset == 'Remote First') {
        _weightComp = 0.20;
        _weightRemote = 0.45;
        _weightRating = 0.10;
        _weightGrowth = 0.10;
        _weightFit = 0.15;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Job Decision Matrix')),
        body: const Center(child: Text('Sign in to evaluate jobs.')),
      );
    }

    final weights = DecisionMatrixWeights(
      compensation: _weightComp,
      remoteFlexibility: _weightRemote,
      companyRating: _weightRating,
      careerGrowth: _weightGrowth,
      jobFit: _weightFit,
    );

    final ranked = DecisionMatrixCalculator.evaluateAndRank(
      jobs: widget.jobs,
      user: user,
      weights: weights,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Job Decision Matrix'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Evaluation Weighting Card
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
                  Text('Evaluation Presets', style: AppTypography.titleSm),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: ['Balanced', 'High Compensation', 'Remote First'].map((preset) {
                      final isSelected = _activePreset == preset;
                      return ChoiceChip(
                        label: Text(preset),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        onSelected: (_) => _applyPreset(preset),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Sliders
                  _buildWeightSlider('Compensation (${(_weightComp * 100).round()}%)', _weightComp, (v) {
                    setState(() {
                      _activePreset = 'Custom';
                      _weightComp = v;
                    });
                  }),
                  _buildWeightSlider('Remote Flexibility (${(_weightRemote * 100).round()}%)', _weightRemote, (v) {
                    setState(() {
                      _activePreset = 'Custom';
                      _weightRemote = v;
                    });
                  }),
                  _buildWeightSlider('Company Culture (${(_weightRating * 100).round()}%)', _weightRating, (v) {
                    setState(() {
                      _activePreset = 'Custom';
                      _weightRating = v;
                    });
                  }),
                  _buildWeightSlider('Job Fit Score (${(_weightFit * 100).round()}%)', _weightFit, (v) {
                    setState(() {
                      _activePreset = 'Custom';
                      _weightFit = v;
                    });
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Shortlist Evaluation & Dynamic Ranking
            Text('Shortlist Ranking (${ranked.length} Roles)', style: AppTypography.headlineSm),
            const SizedBox(height: 12),

            ...ranked.map((item) {
              final isWinner = item.rank == 1;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppSpacing.roundedLg,
                  border: Border.all(
                    color: isWinner ? AppColors.accent : AppColors.border,
                    width: isWinner ? 2.0 : 1.0,
                  ),
                  boxShadow: isWinner ? AppSpacing.elevatedShadow : AppSpacing.cardShadow,
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
                            color: isWinner ? AppColors.successBg : AppColors.surfaceContainerLow,
                            borderRadius: AppSpacing.roundedFull,
                          ),
                          child: Text(
                            isWinner ? '🏆 RANK #1 (OPTIMAL)' : 'RANK #${item.rank}',
                            style: AppTypography.labelSm.copyWith(
                              color: isWinner ? AppColors.accent : AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          '${item.totalScore} / 100',
                          style: AppTypography.metricMd.copyWith(
                            color: isWinner ? AppColors.accent : AppColors.primary,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(item.job.title, style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.w700)),
                    Text(
                      '${item.job.companyName} • ${item.job.formattedSalary}',
                      style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 14),

                    // Dimension scores
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildScoreMini('Comp', '${item.compensationScore.round()}%'),
                        _buildScoreMini('Remote', '${item.remoteScore.round()}%'),
                        _buildScoreMini('Rating', '${item.ratingScore.round()}%'),
                        _buildScoreMini('Fit', '${item.fitScore.round()}%'),
                      ],
                    ),
                    const SizedBox(height: 14),

                    PrimaryButton(
                      text: 'View Details & Apply',
                      backgroundColor: isWinner ? AppColors.primary : AppColors.surfaceContainerHigh,
                      textColor: isWinner ? Colors.white : AppColors.primary,
                      height: 38,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => JobDetailsScreen(job: item.job)),
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

  Widget _buildWeightSlider(String label, double val, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.labelSm),
          Slider(
            value: val,
            min: 0.05,
            max: 0.60,
            divisions: 11,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreMini(String label, String score) {
    return Column(
      children: [
        Text(score, style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700)),
        Text(label, style: AppTypography.labelSm.copyWith(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}
