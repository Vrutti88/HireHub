import '../core/utils/safe_parsers.dart';

class CompanyModel {
  final String id;
  final String name;
  final String? logo;
  final String location;
  final String employeeRange; // e.g. "250-500 employees"
  final double rating;
  final double cultureRating;
  final double salaryRating;
  final double managementRating;
  final double workLifeRating;
  final double growthRating;
  final String about;
  final List<String> techStack;

  const CompanyModel({
    required this.id,
    required this.name,
    this.logo,
    required this.location,
    required this.employeeRange,
    required this.rating,
    this.cultureRating = 4.3,
    this.salaryRating = 4.1,
    this.managementRating = 4.0,
    this.workLifeRating = 4.2,
    this.growthRating = 4.4,
    required this.about,
    this.techStack = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'location': location,
      'employeeRange': employeeRange,
      'rating': rating,
      'cultureRating': cultureRating,
      'salaryRating': salaryRating,
      'managementRating': managementRating,
      'workLifeRating': workLifeRating,
      'growthRating': growthRating,
      'about': about,
      'techStack': techStack,
    };
  }

  factory CompanyModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return CompanyModel(
      id: id ?? SafeParsers.string(map['id']),
      name: SafeParsers.string(map['name']),
      logo: SafeParsers.nullableString(map['logo']),
      location: SafeParsers.string(map['location']),
      employeeRange: SafeParsers.string(map['employeeRange']),
      rating: SafeParsers.doubleVal(map['rating'], 4.0),
      cultureRating: SafeParsers.doubleVal(map['cultureRating'], 4.0),
      salaryRating: SafeParsers.doubleVal(map['salaryRating'], 4.0),
      managementRating: SafeParsers.doubleVal(map['managementRating'], 4.0),
      workLifeRating: SafeParsers.doubleVal(map['workLifeRating'], 4.0),
      growthRating: SafeParsers.doubleVal(map['growthRating'], 4.0),
      about: SafeParsers.string(map['about']),
      techStack: SafeParsers.stringList(map['techStack']),
    );
  }
}
