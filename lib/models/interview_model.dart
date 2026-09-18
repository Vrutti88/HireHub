import '../core/utils/safe_parsers.dart';

class InterviewModel {
  final String id;
  final String userId;
  final String applicationId;
  final String jobId;
  final String jobTitle;
  final String companyName;
  final String? companyLogo;
  final DateTime dateTime;
  final String type; // Online, Phone, In-person
  final String? meetingLink;
  final String? location;
  final String roundName; // e.g. "Technical Round 1", "System Design"
  final String notes;
  final bool reminderActive;
  final List<String> prepChecklist;

  const InterviewModel({
    required this.id,
    this.userId = '',
    required this.applicationId,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    this.companyLogo,
    required this.dateTime,
    this.type = 'Online',
    this.meetingLink,
    this.location,
    this.roundName = 'Technical Round 1',
    this.notes = '',
    this.reminderActive = true,
    this.prepChecklist = const [
      'Review Flutter state management patterns (Provider/Riverpod)',
      'Prepare 2 production architecture examples',
      'Test webcam and audio setup',
    ],
  });

  InterviewModel copyWith({
    String? id,
    String? userId,
    String? applicationId,
    String? jobId,
    String? jobTitle,
    String? companyName,
    String? companyLogo,
    DateTime? dateTime,
    String? type,
    String? meetingLink,
    String? location,
    String? roundName,
    String? notes,
    bool? reminderActive,
    List<String>? prepChecklist,
  }) {
    return InterviewModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      applicationId: applicationId ?? this.applicationId,
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
      companyName: companyName ?? this.companyName,
      companyLogo: companyLogo ?? this.companyLogo,
      dateTime: dateTime ?? this.dateTime,
      type: type ?? this.type,
      meetingLink: meetingLink ?? this.meetingLink,
      location: location ?? this.location,
      roundName: roundName ?? this.roundName,
      notes: notes ?? this.notes,
      reminderActive: reminderActive ?? this.reminderActive,
      prepChecklist: prepChecklist ?? this.prepChecklist,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'applicationId': applicationId,
      'jobId': jobId,
      'jobTitle': jobTitle,
      'companyName': companyName,
      'companyLogo': companyLogo,
      'dateTime': dateTime.toIso8601String(),
      'type': type,
      'meetingLink': meetingLink,
      'location': location,
      'roundName': roundName,
      'notes': notes,
      'reminderActive': reminderActive,
      'prepChecklist': prepChecklist,
    };
  }

  factory InterviewModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return InterviewModel(
      id: id ?? SafeParsers.string(map['id']),
      userId: SafeParsers.string(map['userId']),
      applicationId: SafeParsers.string(map['applicationId']),
      jobId: SafeParsers.string(map['jobId']),
      jobTitle: SafeParsers.string(map['jobTitle']),
      companyName: SafeParsers.string(map['companyName']),
      companyLogo: SafeParsers.nullableString(map['companyLogo']),
      dateTime: SafeParsers.dateTime(map['dateTime']),
      type: SafeParsers.string(map['type'], 'Online'),
      meetingLink: SafeParsers.nullableString(map['meetingLink']),
      location: SafeParsers.nullableString(map['location']),
      roundName: SafeParsers.string(map['roundName'], 'Technical Interview'),
      notes: SafeParsers.string(map['notes']),
      reminderActive: SafeParsers.boolVal(map['reminderActive'], true),
      prepChecklist: SafeParsers.stringList(map['prepChecklist']),
    );
  }
}
