import '../core/utils/safe_parsers.dart';

class JobModel {
  final String id;
  final String title;
  final String companyId;
  final String companyName;
  final String? companyLogo;
  final String location;
  final String workMode; // Hybrid, Remote, On-site
  final String jobType; // Full-time, Internship, Contract
  final double salaryMinLPA;
  final double salaryMaxLPA;
  final int experienceMin;
  final int experienceMax;
  final List<String> requiredSkills;
  final List<String> preferredSkills;
  final String description;
  final List<String> responsibilities;
  final List<String> benefits;
  final DateTime datePosted;
  final DateTime? applicationDeadline;
  final int openings;
  final double rating;
  final String educationRequired;

  const JobModel({
    required this.id,
    required this.title,
    required this.companyId,
    required this.companyName,
    this.companyLogo,
    required this.location,
    required this.workMode,
    required this.jobType,
    required this.salaryMinLPA,
    required this.salaryMaxLPA,
    required this.experienceMin,
    required this.experienceMax,
    required this.requiredSkills,
    this.preferredSkills = const [],
    required this.description,
    this.responsibilities = const [],
    this.benefits = const [],
    required this.datePosted,
    this.applicationDeadline,
    this.openings = 1,
    this.rating = 4.2,
    this.educationRequired = 'Bachelor\'s in Computer Science or related field',
  });

  String get formattedSalary => '₹${salaryMinLPA.toStringAsFixed(0)}–${salaryMaxLPA.toStringAsFixed(0)} LPA';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'companyId': companyId,
      'companyName': companyName,
      'companyLogo': companyLogo,
      'location': location,
      'workMode': workMode,
      'jobType': jobType,
      'salaryMinLPA': salaryMinLPA,
      'salaryMaxLPA': salaryMaxLPA,
      'experienceMin': experienceMin,
      'experienceMax': experienceMax,
      'requiredSkills': requiredSkills,
      'preferredSkills': preferredSkills,
      'description': description,
      'responsibilities': responsibilities,
      'benefits': benefits,
      'datePosted': datePosted.toIso8601String(),
      'applicationDeadline': applicationDeadline?.toIso8601String(),
      'openings': openings,
      'rating': rating,
      'educationRequired': educationRequired,
    };
  }

  factory JobModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return JobModel(
      id: id ?? SafeParsers.string(map['id']),
      title: SafeParsers.string(map['title']),
      companyId: SafeParsers.string(map['companyId']),
      companyName: SafeParsers.string(map['companyName']),
      companyLogo: SafeParsers.nullableString(map['companyLogo']),
      location: SafeParsers.string(map['location']),
      workMode: SafeParsers.string(map['workMode'], 'Hybrid'),
      jobType: SafeParsers.string(map['jobType'], 'Full-time'),
      salaryMinLPA: SafeParsers.doubleVal(map['salaryMinLPA'], 0.0),
      salaryMaxLPA: SafeParsers.doubleVal(map['salaryMaxLPA'], 0.0),
      experienceMin: SafeParsers.intVal(map['experienceMin'], 0),
      experienceMax: SafeParsers.intVal(map['experienceMax'], 5),
      requiredSkills: SafeParsers.stringList(map['requiredSkills']),
      preferredSkills: SafeParsers.stringList(map['preferredSkills']),
      description: SafeParsers.string(map['description']),
      responsibilities: SafeParsers.stringList(map['responsibilities']),
      benefits: SafeParsers.stringList(map['benefits']),
      datePosted: SafeParsers.dateTime(map['datePosted']),
      applicationDeadline: SafeParsers.nullableDateTime(map['applicationDeadline']),
      openings: SafeParsers.intVal(map['openings'], 1),
      rating: SafeParsers.doubleVal(map['rating'], 4.0),
      educationRequired: SafeParsers.string(map['educationRequired'], 'Bachelor\'s degree'),
    );
  }
}
