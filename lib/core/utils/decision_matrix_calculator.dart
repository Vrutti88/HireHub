import '../../models/job_model.dart';
import '../../models/user_model.dart';
import 'job_fit_calculator.dart';

class DecisionMatrixWeights {
  final double compensation; // 0.0 - 1.0
  final double remoteFlexibility; // 0.0 - 1.0
  final double companyRating; // 0.0 - 1.0
  final double careerGrowth; // 0.0 - 1.0
  final double jobFit; // 0.0 - 1.0

  const DecisionMatrixWeights({
    this.compensation = 0.25,
    this.remoteFlexibility = 0.20,
    this.companyRating = 0.15,
    this.careerGrowth = 0.20,
    this.jobFit = 0.20,
  });

  // Presets
  static const DecisionMatrixWeights balanced = DecisionMatrixWeights(
    compensation: 0.25,
    remoteFlexibility: 0.20,
    companyRating: 0.15,
    careerGrowth: 0.20,
    jobFit: 0.20,
  );

  static const DecisionMatrixWeights highCompensation = DecisionMatrixWeights(
    compensation: 0.45,
    remoteFlexibility: 0.15,
    companyRating: 0.10,
    careerGrowth: 0.15,
    jobFit: 0.15,
  );

  static const DecisionMatrixWeights remoteFirst = DecisionMatrixWeights(
    compensation: 0.20,
    remoteFlexibility: 0.45,
    companyRating: 0.10,
    careerGrowth: 0.10,
    jobFit: 0.15,
  );
}

class RankedJobDecision {
  final JobModel job;
  final double totalScore; // 0-100
  final double compensationScore;
  final double remoteScore;
  final double ratingScore;
  final double growthScore;
  final double fitScore;
  final int rank;

  const RankedJobDecision({
    required this.job,
    required this.totalScore,
    required this.compensationScore,
    required this.remoteScore,
    required this.ratingScore,
    required this.growthScore,
    required this.fitScore,
    required this.rank,
  });
}

/// Deterministic Rule-Based Job Decision Matrix
class DecisionMatrixCalculator {
  DecisionMatrixCalculator._();

  static List<RankedJobDecision> evaluateAndRank({
    required List<JobModel> jobs,
    required UserModel user,
    required DecisionMatrixWeights weights,
  }) {
    if (jobs.isEmpty) return [];

    // Find max salary among comparison jobs for relative normalization
    double maxSalary = jobs.map((j) => j.salaryMaxLPA).fold(0.0, (a, b) => a > b ? a : b);
    if (maxSalary == 0) maxSalary = 10.0;

    final scored = <RankedJobDecision>[];

    for (final job in jobs) {
      // 1. Compensation score (0-100)
      final compScore = ((job.salaryMaxLPA / maxSalary) * 100.0).clamp(30.0, 100.0);

      // 2. Remote flexibility score (0-100)
      double remoteScore = 50.0;
      if (job.workMode.toLowerCase() == 'remote') {
        remoteScore = 100.0;
      } else if (job.workMode.toLowerCase() == 'hybrid') {
        remoteScore = 80.0;
      }

      // 3. Rating score (0-100)
      final ratingScore = ((job.rating / 5.0) * 100.0).clamp(40.0, 100.0);

      // 4. Career growth score (heuristic: based on company maturity and team size)
      final growthScore = (80.0 + (job.openings > 1 ? 10.0 : 0.0)).clamp(60.0, 95.0);

      // 5. Fit score (0-100)
      final fit = JobFitCalculator.calculate(user: user, job: job);
      final fitScore = fit.overallScore.toDouble();

      // Weighted total
      final totalWeight = weights.compensation +
          weights.remoteFlexibility +
          weights.companyRating +
          weights.careerGrowth +
          weights.jobFit;

      final total = ((compScore * weights.compensation) +
              (remoteScore * weights.remoteFlexibility) +
              (ratingScore * weights.companyRating) +
              (growthScore * weights.careerGrowth) +
              (fitScore * weights.jobFit)) /
          (totalWeight > 0 ? totalWeight : 1.0);

      scored.add(
        RankedJobDecision(
          job: job,
          totalScore: double.parse(total.toStringAsFixed(1)),
          compensationScore: double.parse(compScore.toStringAsFixed(1)),
          remoteScore: double.parse(remoteScore.toStringAsFixed(1)),
          ratingScore: double.parse(ratingScore.toStringAsFixed(1)),
          growthScore: double.parse(growthScore.toStringAsFixed(1)),
          fitScore: double.parse(fitScore.toStringAsFixed(1)),
          rank: 1, // updated after sort
        ),
      );
    }

    // Sort descending by total score
    scored.sort((a, b) => b.totalScore.compareTo(a.totalScore));

    // Assign final ranks
    final ranked = <RankedJobDecision>[];
    for (int i = 0; i < scored.length; i++) {
      final s = scored[i];
      ranked.add(
        RankedJobDecision(
          job: s.job,
          totalScore: s.totalScore,
          compensationScore: s.compensationScore,
          remoteScore: s.remoteScore,
          ratingScore: s.ratingScore,
          growthScore: s.growthScore,
          fitScore: s.fitScore,
          rank: i + 1,
        ),
      );
    }

    return ranked;
  }
}
