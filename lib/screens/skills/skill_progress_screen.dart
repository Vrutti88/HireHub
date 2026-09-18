import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/skill_provider.dart';
import '../../widgets/primary_button.dart';

class SkillProgressScreen extends StatefulWidget {
  const SkillProgressScreen({super.key});

  @override
  State<SkillProgressScreen> createState() => _SkillProgressScreenState();
}

class _SkillProgressScreenState extends State<SkillProgressScreen> {
  String? _selectedSkillToEdit;
  int _editingLevel = 75;

  void _syncAndRecalculate() {
    final skillProvider = context.read<SkillProvider>();
    final authProvider = context.read<AuthProvider>();

    if (_selectedSkillToEdit != null) {
      skillProvider.updateSkillProficiency(_selectedSkillToEdit!, _editingLevel, authProvider);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Verified Stack synchronized! All Job Fit scores recalculated.'),
        backgroundColor: AppColors.accent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final skills = user?.skills ?? {};

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Skill Progress'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
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
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.successBg,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified_rounded, color: AppColors.accent, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Verified Technical Stack', style: AppTypography.titleSm),
                            const SizedBox(height: 2),
                            Text(
                              '${skills.length} skills verified against industry benchmarks',
                              style: AppTypography.bodySm,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Text(
                    'Skills directly influence 50% of your deterministic Job Fit score. Updating your proficiency immediately unlocks higher-ranking recommendations.',
                    style: AppTypography.bodySm.copyWith(height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Skills Breakdown List
            Text('Technical Competencies', style: AppTypography.headlineSm),
            const SizedBox(height: 12),

            ...skills.entries.map((entry) {
              final skillName = entry.key;
              final level = entry.value;
              final isSelected = _selectedSkillToEdit == skillName;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppSpacing.roundedMd,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(skillName, style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.w700)),
                        Row(
                          children: [
                            Text(
                              '$level% Mastery',
                              style: AppTypography.labelMd.copyWith(
                                color: level >= 75 ? AppColors.accent : AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isSelected ? Icons.keyboard_arrow_up_rounded : Icons.edit_outlined,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedSkillToEdit = null;
                                  } else {
                                    _selectedSkillToEdit = skillName;
                                    _editingLevel = level;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: AppSpacing.roundedFull,
                      child: LinearProgressIndicator(
                        value: level / 100.0,
                        minHeight: 8,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        color: level >= 75 ? AppColors.accent : AppColors.primary,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Adjust Verified Level', style: AppTypography.labelSm),
                          Text('$_editingLevel%', style: AppTypography.labelSm.copyWith(color: AppColors.primary)),
                        ],
                      ),
                      Slider(
                        value: _editingLevel.toDouble(),
                        min: 0,
                        max: 100,
                        divisions: 20,
                        activeColor: AppColors.primary,
                        onChanged: (val) => setState(() => _editingLevel = val.round()),
                      ),
                    ],
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),

            // Sync & Recalculate Button (Stitch Screen 9 Highlight)
            PrimaryButton(
              text: 'Sync & Recalculate Job Fit Scores',
              icon: Icons.sync_rounded,
              onPressed: _syncAndRecalculate,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
