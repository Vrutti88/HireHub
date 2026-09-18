import '../../models/application_model.dart';
import '../../models/user_model.dart';

class ApplicationHealthReport {
  final int overallScore; // 0-100
  final int profileFactorScore; // out of 25
  final int resumeFactorScore; // out of 25
  final int activityFactorScore; // out of 25
  final int conversionFactorScore; // out of 25
  final List<String> actionableTips;

  const ApplicationHealthReport({
    required this.overallScore,
    required this.profileFactorScore,
    required this.resumeFactorScore,
    required this.activityFactorScore,
    required this.conversionFactorScore,
    required this.actionableTips,
  });
}

/// Deterministic Rule-Based Application Health Calculator
class ApplicationHealthCalculator {
  ApplicationHealthCalculator._();

  static ApplicationHealthReport calculate({
    required UserModel user,
    required List<ApplicationModel> applications,
  }) {
    // 1. Profile factor (max 25)
    final profileFactor = ((user.profileCompletion / 100.0) * 25.0).round();

    // 2. Resume completeness factor (max 25)
    int resumeFactor = 15;
    if (user.resumeName != null && user.resumeName!.isNotEmpty) {
      resumeFactor += 5;
    }
    if (user.skills.length >= 5) {
      resumeFactor += 5;
    }

    // 3. Activity factor (max 25)
    // Positive health if user has between 2 and 15 active applications
    int activityFactor = 10;
    if (applications.isNotEmpty) {
      activityFactor = (10 + (applications.length * 3)).clamp(10, 25);
    }

    // 4. Conversion factor (max 25)
    // Response rate heuristics: shortlisted, interview, selected
    int conversionFactor = 18;
    final interviewOrBetter = applications.where((a) =>
        a.status == 'shortlisted' ||
        a.status == 'interview' ||
        a.status == 'selected').length;
    if (applications.isNotEmpty) {
      final rate = interviewOrBetter / applications.length;
      conversionFactor = (10 + (rate * 30)).round().clamp(10, 25);
    }

    final overall = (profileFactor + resumeFactor + activityFactor + conversionFactor).clamp(0, 100);

    final tips = <String>[];
    if (user.profileCompletion < 90) {
      tips.add('Complete portfolio links & certifications to boost profile visibility (+5 pts)');
    }
    if (user.skills.length < 6) {
      tips.add('Add at least 2 more verified technical skills from your recent projects (+6 pts)');
    }
    if (applications.length < 3) {
      tips.add('Apply to at least 3 high-fit roles this week to maintain active pipeline momentum (+4 pts)');
    }
    if (tips.isEmpty) {
      tips.add('Your application profile is in the top 10% of active candidates. Keep following up on active interview rounds.');
    }

    return ApplicationHealthReport(
      overallScore: overall,
      profileFactorScore: profileFactor,
      resumeFactorScore: resumeFactor,
      activityFactorScore: activityFactor,
      conversionFactorScore: conversionFactor,
      actionableTips: tips,
    );
  }
}
