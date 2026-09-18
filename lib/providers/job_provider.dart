import 'package:flutter/material.dart';
import '../core/utils/job_fit_calculator.dart';
import '../models/job_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class JobFilterOptions {
  final String? searchQuery;
  final String? category; // All, Best Fit, Remote, Mobile, Frontend, Backend, AI/ML, Cloud/DevOps, Design, High Pay
  final String? location;
  final String? workMode; // Any, Remote, Hybrid, On-site
  final String? jobType; // Any, Full-time, Internship, Contract
  final double? minSalary;
  final int? maxExp;
  final String? sortBy; // relevance, newest, salary_high, rating

  const JobFilterOptions({
    this.searchQuery = '',
    this.category = 'All',
    this.location = 'Any',
    this.workMode = 'Any',
    this.jobType = 'Any',
    this.minSalary = 0,
    this.maxExp = 10,
    this.sortBy = 'relevance',
  });

  // Safe convenience aliases
  String get safeCategory => (category != null && category!.isNotEmpty) ? category! : 'All';
  String get safeLocation => (location != null && location!.isNotEmpty) ? location! : 'Any';
  String get safeWorkMode => (workMode != null && workMode!.isNotEmpty) ? workMode! : 'Any';
  String get safeJobType => (jobType != null && jobType!.isNotEmpty) ? jobType! : 'Any';
  String get safeSortBy => (sortBy != null && sortBy!.isNotEmpty) ? sortBy! : 'relevance';
  String get safeSearchQuery => searchQuery ?? '';
  double get safeMinSalary => minSalary ?? 0.0;
  int get safeMaxExp => maxExp ?? 10;

  JobFilterOptions copyWith({
    String? searchQuery,
    String? category,
    String? location,
    String? workMode,
    String? jobType,
    double? minSalary,
    int? maxExp,
    String? sortBy,
  }) {
    return JobFilterOptions(
      searchQuery: searchQuery ?? safeSearchQuery,
      category: category ?? safeCategory,
      location: location ?? safeLocation,
      workMode: workMode ?? safeWorkMode,
      jobType: jobType ?? safeJobType,
      minSalary: minSalary ?? safeMinSalary,
      maxExp: maxExp ?? safeMaxExp,
      sortBy: sortBy ?? safeSortBy,
    );
  }

  bool get hasActiveCustomFilters =>
      safeCategory != 'All' ||
      safeWorkMode != 'Any' ||
      safeLocation != 'Any' ||
      safeJobType != 'Any' ||
      safeMinSalary > 0 ||
      safeSearchQuery.trim().isNotEmpty;
}

class JobProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  List<JobModel> _jobs = [];
  bool _isLoading = false;
  JobFilterOptions _filters = const JobFilterOptions();

  JobProvider(this._firestoreService) {
    loadJobs();
  }

  List<JobModel> get allJobs => _jobs;
  bool get isLoading => _isLoading;
  JobFilterOptions get filters {
    if (_filters.category == null ||
        _filters.location == null ||
        _filters.workMode == null ||
        _filters.jobType == null ||
        _filters.sortBy == null ||
        _filters.searchQuery == null) {
      _filters = const JobFilterOptions();
    }
    return _filters;
  }

  Future<void> loadJobs() async {
    _isLoading = true;
    notifyListeners();
    _jobs = await _firestoreService.getJobs();
    _isLoading = false;
    notifyListeners();
  }

  void updateFilters(JobFilterOptions newFilters) {
    _filters = newFilters;
    notifyListeners();
  }

  void setCategory(String category) {
    _filters = _filters.copyWith(category: category);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _filters = _filters.copyWith(searchQuery: query);
    notifyListeners();
  }

  void resetFilters() {
    _filters = const JobFilterOptions();
    notifyListeners();
  }

  List<JobModel> getFilteredJobs(UserModel user) {
    var result = List<JobModel>.from(_jobs);
    final f = filters;

    // Search query
    if (f.safeSearchQuery.trim().isNotEmpty) {
      final q = f.safeSearchQuery.trim().toLowerCase();
      result = result.where((j) {
        return j.title.toLowerCase().contains(q) ||
            j.companyName.toLowerCase().contains(q) ||
            j.location.toLowerCase().contains(q) ||
            j.requiredSkills.any((s) => s.toLowerCase().contains(q)) ||
            j.preferredSkills.any((s) => s.toLowerCase().contains(q));
      }).toList();
    }

    // Category quick-filter
    final cat = f.safeCategory;
    if (cat != 'All') {
      switch (cat) {
        case 'Best Fit':
        case 'Top Match':
          result = result.where((j) {
            final fit = JobFitCalculator.calculate(user: user, job: j).overallScore;
            return fit >= 80;
          }).toList();
          break;
        case 'Remote':
          result = result.where((j) => j.workMode.toLowerCase() == 'remote').toList();
          break;
        case 'Mobile':
          result = result.where((j) {
            final t = j.title.toLowerCase();
            return t.contains('mobile') ||
                t.contains('flutter') ||
                t.contains('ios') ||
                t.contains('android') ||
                t.contains('swift') ||
                t.contains('kotlin');
          }).toList();
          break;
        case 'Frontend':
          result = result.where((j) {
            final t = j.title.toLowerCase();
            return t.contains('frontend') ||
                t.contains('web') ||
                t.contains('react') ||
                t.contains('ui/ux') ||
                j.requiredSkills.any((s) => ['React', 'TypeScript', 'Tailwind', 'Next.js'].contains(s));
          }).toList();
          break;
        case 'Backend':
          result = result.where((j) {
            final t = j.title.toLowerCase();
            return t.contains('backend') ||
                t.contains('golang') ||
                t.contains('go ') ||
                t.contains('python') ||
                t.contains('node') ||
                j.requiredSkills.any((s) => ['Golang', 'Python', 'Node.js', 'REST API', 'Docker'].contains(s));
          }).toList();
          break;
        case 'AI / ML':
        case 'AI/ML':
          result = result.where((j) {
            final t = j.title.toLowerCase();
            return t.contains('ai') ||
                t.contains('machine learning') ||
                t.contains('analyst') ||
                t.contains('vision') ||
                j.requiredSkills.contains('Machine Learning');
          }).toList();
          break;
        case 'Cloud / DevOps':
        case 'Cloud/DevOps':
          result = result.where((j) {
            final t = j.title.toLowerCase();
            return t.contains('devops') ||
                t.contains('cloud') ||
                t.contains('sre') ||
                t.contains('kubernetes') ||
                j.requiredSkills.any((s) => ['Kubernetes', 'AWS', 'Docker'].contains(s));
          }).toList();
          break;
        case 'Design':
          result = result.where((j) {
            final t = j.title.toLowerCase();
            return t.contains('designer') ||
                t.contains('design') ||
                j.requiredSkills.contains('Figma');
          }).toList();
          break;
        case 'High Pay':
          result = result.where((j) => j.salaryMinLPA >= 20.0).toList();
          break;
        default:
          break;
      }
    }

    // Work Mode
    if (f.safeWorkMode != 'Any') {
      result = result.where((j) => j.workMode.toLowerCase() == f.safeWorkMode.toLowerCase()).toList();
    }

    // Job Type
    if (f.safeJobType != 'Any') {
      result = result.where((j) => j.jobType.toLowerCase() == f.safeJobType.toLowerCase()).toList();
    }

    // Location
    if (f.safeLocation != 'Any') {
      result = result.where((j) => j.location.toLowerCase().contains(f.safeLocation.toLowerCase())).toList();
    }

    // Min Salary
    if (f.safeMinSalary > 0) {
      result = result.where((j) => j.salaryMaxLPA >= f.safeMinSalary).toList();
    }

    // Sorting
    switch (f.safeSortBy) {
      case 'newest':
        result.sort((a, b) => b.datePosted.compareTo(a.datePosted));
        break;
      case 'salary_high':
        result.sort((a, b) => b.salaryMaxLPA.compareTo(a.salaryMaxLPA));
        break;
      case 'rating':
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'fit_score':
      case 'relevance':
      default:
        // Default ranking: combination of fit score and recency
        result.sort((a, b) {
          final fitA = JobFitCalculator.calculate(user: user, job: a).overallScore;
          final fitB = JobFitCalculator.calculate(user: user, job: b).overallScore;
          final fitCompare = fitB.compareTo(fitA);
          if (fitCompare != 0) return fitCompare;
          return b.datePosted.compareTo(a.datePosted);
        });
        break;
    }

    return result;
  }
}
