import 'package:flutter_test/flutter_test.dart';
import 'package:hirehub/core/utils/skill_gap_analyzer.dart';
import 'package:hirehub/data/seed_data.dart';

void main() {
  group('SkillGapAnalyzer Deterministic Engine', () {
    test('Correctly identifies missing required skills as skill gaps', () {
      final user = SeedData.initialUser; // Has Flutter, Dart, Firebase, Git, State Management
      final job = SeedData.jobs.first; // TechNova: Flutter, Dart, Firebase, REST API, Git

      final gaps = SkillGapAnalyzer.analyze(user: user, job: job);

      // REST API is missing from user
      expect(gaps.any((g) => g.skillName == 'REST API'), isTrue);
      final restGap = gaps.firstWhere((g) => g.skillName == 'REST API');
      expect(restGap.currentProficiency, 0);
      expect(restGap.targetProficiency, 80);
      expect(restGap.projectedFitBoostPercent, greaterThan(0));
    });

    test('Returns empty gaps list when user meets all proficiencies', () {
      final user = SeedData.initialUser.copyWith(
        skills: {
          'Flutter': 90,
          'Dart': 85,
          'Firebase': 80,
          'REST API': 85,
          'Git': 85,
        },
      );
      final job = SeedData.jobs.first;

      final gaps = SkillGapAnalyzer.analyze(user: user, job: job);
      expect(gaps.isEmpty, isTrue);
    });
  });
}
