import '../core/utils/safe_parsers.dart';

class SkillModel {
  final String id;
  final String name;
  final String category; // Frontend, Backend, Database, Mobile, Core
  final String importance; // Critical, High, Medium
  final String requiredLevel; // Beginner, Intermediate, Advanced
  final String description;
  final int averageSalaryBoostPercent;

  const SkillModel({
    required this.id,
    required this.name,
    required this.category,
    this.importance = 'High',
    this.requiredLevel = 'Intermediate',
    required this.description,
    this.averageSalaryBoostPercent = 12,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'importance': importance,
      'requiredLevel': requiredLevel,
      'description': description,
      'averageSalaryBoostPercent': averageSalaryBoostPercent,
    };
  }

  factory SkillModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return SkillModel(
      id: id ?? SafeParsers.string(map['id']),
      name: SafeParsers.string(map['name']),
      category: SafeParsers.string(map['category'], 'Core'),
      importance: SafeParsers.string(map['importance'], 'High'),
      requiredLevel: SafeParsers.string(map['requiredLevel'], 'Intermediate'),
      description: SafeParsers.string(map['description']),
      averageSalaryBoostPercent: SafeParsers.intVal(map['averageSalaryBoostPercent'], 10),
    );
  }
}
