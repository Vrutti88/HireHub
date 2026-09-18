import '../core/utils/safe_parsers.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // interview, application, offer, learning, alert
  final bool isCritical;
  final bool isRead;
  final DateTime createdAt;
  final String? routeTarget;
  final String? referenceId;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.isCritical = false,
    this.isRead = false,
    required this.createdAt,
    this.routeTarget,
    this.referenceId,
  });

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? type,
    bool? isCritical,
    bool? isRead,
    DateTime? createdAt,
    String? routeTarget,
    String? referenceId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isCritical: isCritical ?? this.isCritical,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      routeTarget: routeTarget ?? this.routeTarget,
      referenceId: referenceId ?? this.referenceId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'isCritical': isCritical,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'routeTarget': routeTarget,
      'referenceId': referenceId,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return NotificationModel(
      id: id ?? SafeParsers.string(map['id']),
      userId: SafeParsers.string(map['userId']),
      title: SafeParsers.string(map['title']),
      message: SafeParsers.string(map['message']),
      type: SafeParsers.string(map['type'], 'application'),
      isCritical: SafeParsers.boolVal(map['isCritical'], false),
      isRead: SafeParsers.boolVal(map['isRead'], false),
      createdAt: SafeParsers.dateTime(map['createdAt']),
      routeTarget: SafeParsers.nullableString(map['routeTarget']),
      referenceId: SafeParsers.nullableString(map['referenceId']),
    );
  }
}
