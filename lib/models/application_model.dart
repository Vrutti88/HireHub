import '../core/utils/safe_parsers.dart';

class ApplicationTimelineEvent {
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isDone;

  const ApplicationTimelineEvent({
    required this.title,
    required this.description,
    required this.timestamp,
    this.isDone = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'isDone': isDone,
    };
  }

  factory ApplicationTimelineEvent.fromMap(Map<String, dynamic> map) {
    return ApplicationTimelineEvent(
      title: SafeParsers.string(map['title']),
      description: SafeParsers.string(map['description']),
      timestamp: SafeParsers.dateTime(map['timestamp']),
      isDone: SafeParsers.boolVal(map['isDone'], true),
    );
  }
}

class ApplicationModel {
  final String id;
  final String userId;
  final String jobId;
  final String jobTitle;
  final String companyId;
  final String companyName;
  final String? companyLogo;
  final String location;
  final String salaryFormatted;
  final String resumeName;
  final String coverLetter;
  final String status; // saved, applied, viewed, shortlisted, interview, selected, rejected, withdrawn
  final DateTime appliedAt;
  final DateTime updatedAt;
  final List<ApplicationTimelineEvent> timeline;
  final String? interviewId;
  final String? notes;

  const ApplicationModel({
    required this.id,
    required this.userId,
    required this.jobId,
    required this.jobTitle,
    required this.companyId,
    required this.companyName,
    this.companyLogo,
    required this.location,
    required this.salaryFormatted,
    required this.resumeName,
    this.coverLetter = '',
    required this.status,
    required this.appliedAt,
    required this.updatedAt,
    this.timeline = const [],
    this.interviewId,
    this.notes,
  });

  ApplicationModel copyWith({
    String? id,
    String? userId,
    String? jobId,
    String? jobTitle,
    String? companyId,
    String? companyName,
    String? companyLogo,
    String? location,
    String? salaryFormatted,
    String? resumeName,
    String? coverLetter,
    String? status,
    DateTime? appliedAt,
    DateTime? updatedAt,
    List<ApplicationTimelineEvent>? timeline,
    String? interviewId,
    String? notes,
  }) {
    return ApplicationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      companyLogo: companyLogo ?? this.companyLogo,
      location: location ?? this.location,
      salaryFormatted: salaryFormatted ?? this.salaryFormatted,
      resumeName: resumeName ?? this.resumeName,
      coverLetter: coverLetter ?? this.coverLetter,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      timeline: timeline ?? this.timeline,
      interviewId: interviewId ?? this.interviewId,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'jobId': jobId,
      'jobTitle': jobTitle,
      'companyId': companyId,
      'companyName': companyName,
      'companyLogo': companyLogo,
      'location': location,
      'salaryFormatted': salaryFormatted,
      'resumeName': resumeName,
      'coverLetter': coverLetter,
      'status': status,
      'appliedAt': appliedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'timeline': timeline.map((e) => e.toMap()).toList(),
      'interviewId': interviewId,
      'notes': notes,
    };
  }

  factory ApplicationModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return ApplicationModel(
      id: id ?? SafeParsers.string(map['id']),
      userId: SafeParsers.string(map['userId']),
      jobId: SafeParsers.string(map['jobId']),
      jobTitle: SafeParsers.string(map['jobTitle']),
      companyId: SafeParsers.string(map['companyId']),
      companyName: SafeParsers.string(map['companyName']),
      companyLogo: SafeParsers.nullableString(map['companyLogo']),
      location: SafeParsers.string(map['location']),
      salaryFormatted: SafeParsers.string(map['salaryFormatted']),
      resumeName: SafeParsers.string(map['resumeName']),
      coverLetter: SafeParsers.string(map['coverLetter']),
      status: SafeParsers.string(map['status'], 'applied'),
      appliedAt: SafeParsers.dateTime(map['appliedAt']),
      updatedAt: SafeParsers.dateTime(map['updatedAt']),
      timeline: (map['timeline'] as List? ?? [])
          .where((e) => e != null && e is Map)
          .map((e) => ApplicationTimelineEvent.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      interviewId: SafeParsers.nullableString(map['interviewId']),
      notes: SafeParsers.nullableString(map['notes']),
    );
  }
}
