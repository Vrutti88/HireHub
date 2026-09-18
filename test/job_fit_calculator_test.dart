import 'package:flutter_test/flutter_test.dart';
import 'package:hirehub/core/utils/job_fit_calculator.dart';
import 'package:hirehub/data/seed_data.dart';

void main() {
  group('JobFitCalculator Deterministic Engine', () {
    test('Calculates weighted factors correctly (50/20/10/10/10)', () {
      final user = SeedData.initialUser; // Has: Flutter, Dart, Firebase, Git, State Management
      final job = SeedData.jobs.first; // TechNova: Flutter, Dart, Firebase, REST API, Git (5 req)

      final result = JobFitCalculator.calculate(user: user, job: job);

      // User has 4 of 5 required skills (Flutter, Dart, Firebase, Git). Missing: REST API
      expect(result.matchedSkills.length, 4);
      expect(result.missingSkills, contains('REST API'));

      // Overall score: 4/5 skills (40) + Exp (20) + Loc (10) + Type (10) + Edu (10) = 90
      expect(result.overallScore, equals(90));

      // Check factor breakdown
      expect(result.factorBreakdown.length, 5);
      expect(result.factorBreakdown[0].factorName, 'Core Skills');
      expect(result.factorBreakdown[0].weight, 0.50);
      expect(result.factorBreakdown[1].factorName, 'Experience Match');
      expect(result.factorBreakdown[1].weight, 0.20);
    });

    test('Simulates ROI boost when missing skill is learned', () {
      final user = SeedData.initialUser;
      final job = SeedData.jobs.first;

      final result = JobFitCalculator.calculate(user: user, job: job);
      expect(result.skillBoostSimulation.containsKey('REST API'), isTrue);

      final boostedScore = result.skillBoostSimulation['REST API']!;
      expect(boostedScore, greaterThan(result.overallScore));
    });

    test('Score dynamically changes when user acquires missing skill', () {
      final userBefore = SeedData.initialUser;
      final job = SeedData.jobs.first;

      final scoreBefore = JobFitCalculator.calculate(user: userBefore, job: job).overallScore;

      // User learns REST API
      final updatedSkills = Map<String, int>.from(userBefore.skills)..['REST API'] = 80;
      final userAfter = userBefore.copyWith(skills: updatedSkills);

      final scoreAfter = JobFitCalculator.calculate(user: userAfter, job: job).overallScore;

      expect(scoreAfter, greaterThan(scoreBefore));
    });
  });
}
