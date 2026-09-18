import 'package:flutter_test/flutter_test.dart';
import 'package:hirehub/core/utils/decision_matrix_calculator.dart';
import 'package:hirehub/data/seed_data.dart';

void main() {
  group('DecisionMatrixCalculator', () {
    test('Ranks jobs dynamically and assigns rank #1 to highest score', () {
      final user = SeedData.initialUser;
      final jobs = SeedData.jobs.take(3).toList();

      final ranked = DecisionMatrixCalculator.evaluateAndRank(
        jobs: jobs,
        user: user,
        weights: DecisionMatrixWeights.balanced,
      );

      expect(ranked.length, 3);
      expect(ranked.first.rank, 1);
      expect(ranked[0].totalScore, greaterThanOrEqualTo(ranked[1].totalScore));
      expect(ranked[1].totalScore, greaterThanOrEqualTo(ranked[2].totalScore));
    });

    test('Changing weights dynamically alters ranking preferences', () {
      final user = SeedData.initialUser;
      final jobs = SeedData.jobs.take(3).toList();

      final rankedRemote = DecisionMatrixCalculator.evaluateAndRank(
        jobs: jobs,
        user: user,
        weights: DecisionMatrixWeights.remoteFirst,
      );

      // In remote first, the Remote job (PixelCraft) should gain significant score
      final pixelcraftRemote = rankedRemote.firstWhere((r) => r.job.workMode == 'Remote');
      expect(pixelcraftRemote.remoteScore, 100.0);
    });
  });
}
