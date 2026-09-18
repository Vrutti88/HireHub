import '../core/utils/safe_parsers.dart';

class LearningResourceModel {
  final String id;
  final String skillId;
  final String skillName;
  final String title;
  final String type; // Video, Article, Documentation, Project, Course
  final String duration; // e.g. "25 mins", "1.5 hours"
  final String provider; // e.g. "Flutter Official", "Dart Docs", "FreeCodeCamp"
  final String url;
  final String description;
  final bool isCompleted;
  final int orderIndex;

  const LearningResourceModel({
    required this.id,
    required this.skillId,
    required this.skillName,
    required this.title,
    required this.type,
    required this.duration,
    required this.provider,
    required this.url,
    required this.description,
    this.isCompleted = false,
    this.orderIndex = 0,
  });

  LearningResourceModel copyWith({
    String? id,
    String? skillId,
    String? skillName,
    String? title,
    String? type,
    String? duration,
    String? provider,
    String? url,
    String? description,
    bool? isCompleted,
    int? orderIndex,
  }) {
    return LearningResourceModel(
      id: id ?? this.id,
      skillId: skillId ?? this.skillId,
      skillName: skillName ?? this.skillName,
      title: title ?? this.title,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      provider: provider ?? this.provider,
      url: url ?? this.url,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'skillId': skillId,
      'skillName': skillName,
      'title': title,
      'type': type,
      'duration': duration,
      'provider': provider,
      'url': url,
      'description': description,
      'isCompleted': isCompleted,
      'orderIndex': orderIndex,
    };
  }

  factory LearningResourceModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return LearningResourceModel(
      id: id ?? SafeParsers.string(map['id']),
      skillId: SafeParsers.string(map['skillId']),
      skillName: SafeParsers.string(map['skillName']),
      title: SafeParsers.string(map['title']),
      type: SafeParsers.string(map['type'], 'Article'),
      duration: SafeParsers.string(map['duration'], '15 mins'),
      provider: SafeParsers.string(map['provider'], 'Community'),
      url: SafeParsers.string(map['url']),
      description: SafeParsers.string(map['description']),
      isCompleted: SafeParsers.boolVal(map['isCompleted'], false),
      orderIndex: SafeParsers.intVal(map['orderIndex'], 0),
    );
  }
}
