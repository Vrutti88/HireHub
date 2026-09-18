import 'package:flutter_test/flutter_test.dart';
import 'package:hirehub/core/utils/application_health_calculator.dart';
import 'package:hirehub/data/seed_data.dart';

void main() {
  group('ApplicationHealthCalculator Deterministic Engine', () {
    test('Calculates four 25-point subfactors totaling 0-100', () {
      final user = SeedData.initialUser;
      final apps = SeedData.applications;

      final report = ApplicationHealthCalculator.calculate(user: user, applications: apps);

      expect(report.overallScore, greaterThanOrEqualTo(0));
      expect(report.overallScore, lessThanOrEqualTo(100));

      expect(report.profileFactorScore, inInclusiveRange(0, 25));
      expect(report.resumeFactorScore, inInclusiveRange(0, 25));
      expect(report.activityFactorScore, inInclusiveRange(0, 25));
      expect(report.conversionFactorScore, inInclusiveRange(0, 25));

      expect(report.overallScore, equals(
        report.profileFactorScore +
        report.resumeFactorScore +
        report.activityFactorScore +
        report.conversionFactorScore,
      ));

      expect(report.actionableTips.isNotEmpty, isTrue);
    });
  });
}
