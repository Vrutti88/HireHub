import 'package:flutter_test/flutter_test.dart';
import 'package:hirehub/core/utils/safe_parsers.dart';
import 'package:hirehub/models/job_model.dart';
import 'package:hirehub/providers/job_provider.dart';

void main() {
  group('SafeParsers Unit Tests', () {
    test('SafeParsers handles null and malformed lists without throwing TypeError', () {
      final listWithNulls = [null, 'Dart', null, 'Flutter', 123];
      final parsed = SafeParsers.stringList(listWithNulls);

      expect(parsed, equals(['Dart', 'Flutter', '123']));
      expect(SafeParsers.stringList(null), isEmpty);
      expect(SafeParsers.string(null, 'default'), equals('default'));
      expect(SafeParsers.doubleVal(null, 5.0), equals(5.0));
      expect(SafeParsers.doubleVal('18.5'), equals(18.5));
      expect(SafeParsers.intVal(null, 10), equals(10));
      expect(SafeParsers.intVal('42'), equals(42));
    });

    test('JobModel.fromMap safely parses null and dynamic fields', () {
      final jobMap = <String, dynamic>{
        'id': 'test-1',
        'title': 'Flutter Dev',
        'companyName': 'Acme',
        'requiredSkills': [null, 'Flutter', null],
        'preferredSkills': null,
        'datePosted': '2026-09-15T00:00:00Z',
        'applicationDeadline': null,
      };

      final job = JobModel.fromMap(jobMap);
      expect(job.title, equals('Flutter Dev'));
      expect(job.requiredSkills, equals(['Flutter']));
      expect(job.preferredSkills, isEmpty);
      expect(job.workMode, equals('Hybrid'));
      expect(job.salaryMinLPA, equals(0.0));
    });

    test('JobFilterOptions safe getters return defaults properly', () {
      const filters = JobFilterOptions();

      expect(filters.safeCategory, equals('All'));
      expect(filters.safeLocation, equals('Any'));
      expect(filters.safeWorkMode, equals('Any'));
      expect(filters.safeJobType, equals('Any'));
      expect(filters.safeSortBy, equals('relevance'));
      expect(filters.safeSearchQuery, equals(''));
      expect(filters.hasActiveCustomFilters, isFalse);

      final updated = filters.copyWith(category: 'Mobile', minSalary: 15.0);
      expect(updated.safeCategory, equals('Mobile'));
      expect(updated.hasActiveCustomFilters, isTrue);
    });
  });
}
