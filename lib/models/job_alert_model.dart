import '../core/utils/safe_parsers.dart';

class JobAlertModel {
  final String id;
  final String userId;
  final String title;
  final String keywords;
  final String location;
  final double minSalaryLPA;
  final String workMode;
  final String frequency; // Daily, Weekly
  final bool isActive;
  final DateTime createdAt;

  const JobAlertModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.keywords,
    this.location = 'Any',
    this.minSalaryLPA = 6.0,
    this.workMode = 'Any',
    this.frequency = 'Daily',
    this.isActive = true,
    required this.createdAt,
  });

  JobAlertModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? keywords,
    String? location,
    double? minSalaryLPA,
    String? workMode,
    String? frequency,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return JobAlertModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      keywords: keywords ?? this.keywords,
      location: location ?? this.location,
      minSalaryLPA: minSalaryLPA ?? this.minSalaryLPA,
      workMode: workMode ?? this.workMode,
      frequency: frequency ?? this.frequency,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'keywords': keywords,
      'location': location,
      'minSalaryLPA': minSalaryLPA,
      'workMode': workMode,
      'frequency': frequency,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory JobAlertModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return JobAlertModel(
      id: id ?? SafeParsers.string(map['id']),
      userId: SafeParsers.string(map['userId']),
      title: SafeParsers.string(map['title'], 'Job Alert'),
      keywords: SafeParsers.string(map['keywords']),
      location: SafeParsers.string(map['location'], 'Any'),
      minSalaryLPA: SafeParsers.doubleVal(map['minSalaryLPA'], 6.0),
      workMode: SafeParsers.string(map['workMode'], 'Any'),
      frequency: SafeParsers.string(map['frequency'], 'Daily'),
      isActive: SafeParsers.boolVal(map['isActive'], true),
      createdAt: SafeParsers.dateTime(map['createdAt']),
    );
  }
}
