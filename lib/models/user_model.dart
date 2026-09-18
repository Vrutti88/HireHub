import '../core/utils/safe_parsers.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String targetRole;
  final int experienceYears;
  final String location;
  final double expectedSalaryLPA;
  final String preferredWorkMode; // Hybrid, Remote, On-site
  final String preferredJobType; // Full-time, Internship, Contract
  final Map<String, int> skills; // skill name -> mastery % (0-100)
  final String? resumeName;
  final String? resumeUrl;
  final List<String> education;
  final List<String> experience;
  final int profileCompletion; // 0-100
  final bool stealthMode; // recruiter visibility toggle

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.targetRole = 'Software Developer',
    this.experienceYears = 0,
    this.location = 'Mumbai',
    this.expectedSalaryLPA = 6.0,
    this.preferredWorkMode = 'Hybrid',
    this.preferredJobType = 'Full-time',
    this.skills = const {},
    this.resumeName,
    this.resumeUrl,
    this.education = const [],
    this.experience = const [],
    this.profileCompletion = 25,
    this.stealthMode = false,
  });

  /// Factory for a brand new user upon Firebase Auth sign-up
  factory UserModel.initial({
    required String uid,
    required String name,
    required String email,
  }) {
    return UserModel(
      uid: uid,
      name: name,
      email: email,
      targetRole: 'Software Developer',
      experienceYears: 0,
      location: 'Mumbai',
      expectedSalaryLPA: 6.0,
      preferredWorkMode: 'Hybrid',
      preferredJobType: 'Full-time',
      skills: {},
      education: [],
      experience: [],
      profileCompletion: 25,
      stealthMode: false,
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    String? targetRole,
    int? experienceYears,
    String? location,
    double? expectedSalaryLPA,
    String? preferredWorkMode,
    String? preferredJobType,
    Map<String, int>? skills,
    String? resumeName,
    String? resumeUrl,
    List<String>? education,
    List<String>? experience,
    int? profileCompletion,
    bool? stealthMode,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      targetRole: targetRole ?? this.targetRole,
      experienceYears: experienceYears ?? this.experienceYears,
      location: location ?? this.location,
      expectedSalaryLPA: expectedSalaryLPA ?? this.expectedSalaryLPA,
      preferredWorkMode: preferredWorkMode ?? this.preferredWorkMode,
      preferredJobType: preferredJobType ?? this.preferredJobType,
      skills: skills ?? this.skills,
      resumeName: resumeName ?? this.resumeName,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      profileCompletion: profileCompletion ?? this.profileCompletion,
      stealthMode: stealthMode ?? this.stealthMode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'targetRole': targetRole,
      'experienceYears': experienceYears,
      'location': location,
      'expectedSalaryLPA': expectedSalaryLPA,
      'preferredWorkMode': preferredWorkMode,
      'preferredJobType': preferredJobType,
      'skills': skills,
      'resumeName': resumeName,
      'resumeUrl': resumeUrl,
      'education': education,
      'experience': experience,
      'profileCompletion': profileCompletion,
      'stealthMode': stealthMode,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return UserModel(
      uid: docId ?? SafeParsers.string(map['uid']),
      name: SafeParsers.string(map['name'], 'Candidate'),
      email: SafeParsers.string(map['email']),
      photoUrl: SafeParsers.nullableString(map['photoUrl']),
      targetRole: SafeParsers.string(map['targetRole'], 'Software Developer'),
      experienceYears: SafeParsers.intVal(map['experienceYears'], 0),
      location: SafeParsers.string(map['location'], 'Mumbai'),
      expectedSalaryLPA: SafeParsers.doubleVal(map['expectedSalaryLPA'], 6.0),
      preferredWorkMode: SafeParsers.string(map['preferredWorkMode'], 'Hybrid'),
      preferredJobType: SafeParsers.string(map['preferredJobType'], 'Full-time'),
      skills: SafeParsers.stringIntMap(map['skills']),
      resumeName: SafeParsers.nullableString(map['resumeName']),
      resumeUrl: SafeParsers.nullableString(map['resumeUrl']),
      education: SafeParsers.stringList(map['education']),
      experience: SafeParsers.stringList(map['experience']),
      profileCompletion: SafeParsers.intVal(map['profileCompletion'], 25),
      stealthMode: SafeParsers.boolVal(map['stealthMode'], false),
    );
  }
}
