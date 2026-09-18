import '../../models/job_model.dart';
import '../../models/user_model.dart';

class FitFactorScore {
  final String factorName;
  final double scorePercent; // 0-100
  final double weight; // e.g. 0.50
  final String description;

  const FitFactorScore({
    required this.factorName,
    required this.scorePercent,
    required this.weight,
    required this.description,
  });

  double get weightedContribution => (scorePercent * weight);
}

class JobFitResult {
  final int overallScore; // 0-100
  final List<FitFactorScore> factorBreakdown;
  final List<String> matchedSkills;
  final List<String> missingSkills;
  final Map<String, int> skillBoostSimulation; // missingSkill -> projected overall score if learned

  const JobFitResult({
    required this.overallScore,
    required this.factorBreakdown,
    required this.matchedSkills,
    required this.missingSkills,
    required this.skillBoostSimulation,
  });
}

/// Deterministic Rule-Based Job Fit Calculator
/// Weights:
/// - Skills: 50%
/// - Experience: 20%
/// - Location: 10%
/// - Job Type: 10%
/// - Education: 10%
class JobFitCalculator {
  JobFitCalculator._();

  static const double weightSkills = 0.50;
  static const double weightExp = 0.20;
  static const double weightLocation = 0.10;
  static const double weightJobType = 0.10;
  static const double weightEducation = 0.10;

  static JobFitResult calculate({
    required UserModel user,
    required JobModel job,
  }) {
    // 1. Skills factor (50%)
    final userSkillNames = user.skills.keys.map((s) => s.trim().toLowerCase()).toSet();
    final matched = <String>[];
    final missing = <String>[];

    for (final req in job.requiredSkills) {
      if (userSkillNames.contains(req.trim().toLowerCase())) {
        matched.add(req);
      } else {
        missing.add(req);
      }
    }

    final skillScore = job.requiredSkills.isEmpty
        ? 100.0
        : (matched.length / job.requiredSkills.length) * 100.0;

    final skillsFactor = FitFactorScore(
      factorName: 'Core Skills',
      scorePercent: skillScore,
      weight: weightSkills,
      description: '${matched.length} of ${job.requiredSkills.length} required skills verified',
    );

    // 2. Experience factor (20%)
    double expScore = 100.0;
    if (user.experienceYears < job.experienceMin) {
      final diff = job.experienceMin - user.experienceYears;
      expScore = (1.0 - (diff / (job.experienceMin + 1))) * 100.0;
      if (expScore < 30) expScore = 30;
    } else if (user.experienceYears > job.experienceMax && job.experienceMax > 0) {
      expScore = 90.0; // slightly overqualified
    } else {
      expScore = 100.0;
    }

    final expFactor = FitFactorScore(
      factorName: 'Experience Match',
      scorePercent: expScore,
      weight: weightExp,
      description: '${user.experienceYears} yrs experience (Job asks ${job.experienceMin}–${job.experienceMax} yrs)',
    );

    // 3. Location factor (10%)
    double locScore = 50.0;
    if (job.workMode.toLowerCase() == 'remote') {
      locScore = 100.0;
    } else if (job.location.toLowerCase().contains(user.location.toLowerCase()) ||
        user.location.toLowerCase().contains(job.location.toLowerCase())) {
      locScore = 100.0;
    } else if (job.workMode.toLowerCase() == 'hybrid') {
      locScore = 75.0;
    }

    final locFactor = FitFactorScore(
      factorName: 'Location & Mode',
      scorePercent: locScore,
      weight: weightLocation,
      description: '${job.location} (${job.workMode}) vs User in ${user.location}',
    );

    // 4. Job Type factor (10%)
    double jobTypeScore = 70.0;
    if (job.jobType.toLowerCase() == user.preferredJobType.toLowerCase()) {
      jobTypeScore = 100.0;
    }

    final jobTypeFactor = FitFactorScore(
      factorName: 'Employment Type',
      scorePercent: jobTypeScore,
      weight: weightJobType,
      description: '${job.jobType} matches preference',
    );

    // 5. Education factor (10%)
    double eduScore = 90.0;
    if (user.education.isNotEmpty) {
      eduScore = 100.0;
    }

    final eduFactor = FitFactorScore(
      factorName: 'Education Qualification',
      scorePercent: eduScore,
      weight: weightEducation,
      description: 'Degree credentials verified',
    );

    // Total Score
    final total = (skillsFactor.weightedContribution +
            expFactor.weightedContribution +
            locFactor.weightedContribution +
            jobTypeFactor.weightedContribution +
            eduFactor.weightedContribution)
        .round()
        .clamp(0, 100);

    // Simulated ROI if missing skills are learned
    final boostSim = <String, int>{};
    for (final m in missing) {
      final simMatchedCount = matched.length + 1;
      final simSkillScore = (simMatchedCount / job.requiredSkills.length) * 100.0;
      final simTotal = ((simSkillScore * weightSkills) +
              expFactor.weightedContribution +
              locFactor.weightedContribution +
              jobTypeFactor.weightedContribution +
              eduFactor.weightedContribution)
          .round()
          .clamp(0, 100);
      boostSim[m] = simTotal;
    }

    return JobFitResult(
      overallScore: total,
      factorBreakdown: [
        skillsFactor,
        expFactor,
        locFactor,
        jobTypeFactor,
        eduFactor,
      ],
      matchedSkills: matched,
      missingSkills: missing,
      skillBoostSimulation: boostSim,
    );
  }
}
