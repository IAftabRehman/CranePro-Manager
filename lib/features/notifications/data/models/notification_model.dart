import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final String? targetRole; // 'admin', 'viewer', 'operator'
  final String? targetUserId;
  final List<String> readBy;
  final List<String> dismissedBy;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.targetRole,
    this.targetUserId,
    this.readBy = const [],
    this.dismissedBy = const [],
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? createdAt,
    String? targetRole,
    String? targetUserId,
    List<String>? readBy,
    List<String>? dismissedBy,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      targetRole: targetRole ?? this.targetRole,
      targetUserId: targetUserId ?? this.targetUserId,
      readBy: readBy ?? this.readBy,
      dismissedBy: dismissedBy ?? this.dismissedBy,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'createdAt': Timestamp.fromDate(createdAt),
      'targetRole': targetRole,
      'targetUserId': targetUserId,
      'readBy': readBy,
      'dismissedBy': dismissedBy,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String docId) {
    return NotificationModel(
      id: docId,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      targetRole: map['targetRole'],
      targetUserId: map['targetUserId'],
      readBy: List<String>.from(map['readBy'] ?? []),
      dismissedBy: List<String>.from(map['dismissedBy'] ?? []),
    );
  }
}
