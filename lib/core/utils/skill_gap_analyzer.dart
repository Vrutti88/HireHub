import '../../models/job_model.dart';
import '../../models/user_model.dart';

class SkillGapItem {
  final String skillName;
  final int currentProficiency; // 0-100
  final int targetProficiency; // 0-100
  final String priority; // Critical, High, Medium
  final int projectedFitBoostPercent;
  final String recommendedAction;

  const SkillGapItem({
    required this.skillName,
    required this.currentProficiency,
    required this.targetProficiency,
    required this.priority,
    required this.projectedFitBoostPercent,
    required this.recommendedAction,
  });
}

/// Deterministic Rule-Based Skill Gap Analyzer
class SkillGapAnalyzer {
  SkillGapAnalyzer._();

  static List<SkillGapItem> analyze({
    required UserModel user,
    required JobModel job,
  }) {
    final gaps = <SkillGapItem>[];
    final userSkillNames = user.skills.keys.map((s) => s.trim().toLowerCase()).toSet();

    for (int i = 0; i < job.requiredSkills.length; i++) {
      final reqSkill = job.requiredSkills[i];
      final lower = reqSkill.trim().toLowerCase();

      final currentLevel = userSkillNames.contains(lower)
          ? (user.skills[reqSkill] ?? user.skills[user.skills.keys.firstWhere((k) => k.toLowerCase() == lower, orElse: () => '')] ?? 70)
          : 0;

      // If current proficiency is below 75%, it's a gap
      if (currentLevel < 75) {
        String priority = 'Medium';
        if (i == 0 || i == 1) {
          priority = 'Critical';
        } else if (i == 2 || i == 3) {
          priority = 'High';
        }

        // Projected boost calculation: Skills are 50% of fit score.
        // Closing 1 skill out of N required skills boosts score by approx (1/N)*50%
        final boost = job.requiredSkills.isNotEmpty
            ? ((1.0 / job.requiredSkills.length) * 50.0).round().clamp(5, 20)
            : 10;

        gaps.add(
          SkillGapItem(
            skillName: reqSkill,
            currentProficiency: currentLevel,
            targetProficiency: 80,
            priority: priority,
            projectedFitBoostPercent: boost,
            recommendedAction: currentLevel == 0 ? 'Start Learning Roadmap' : 'Complete Practice Modules',
          ),
        );
      }
    }

    return gaps;
  }
}
