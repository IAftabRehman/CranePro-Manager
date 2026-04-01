import 'package:cloud_firestore/cloud_firestore.dart';

enum AuditAction { edit, delete }

class AuditEntry {
  final String id;
  final String userName;
  final String targetType; // e.g., 'Quotation', 'Maintenance'
  final String targetName; // e.g., 'Client Name' or 'Site Name'
  final AuditAction action;
  final Map<String, String> beforeValues;
  final Map<String, String> afterValues;
  final DateTime timestamp;
  final bool isDeleted;

  const AuditEntry({
    required this.id,
    required this.userName,
    required this.targetType,
    required this.targetName,
    required this.action,
    required this.beforeValues,
    required this.afterValues,
    required this.timestamp,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'targetType': targetType,
      'targetName': targetName,
      'action': action.name,
      'beforeValues': beforeValues,
      'afterValues': afterValues,
      'timestamp': Timestamp.fromDate(timestamp),
      'isDeleted': isDeleted,
    };
  }

  factory AuditEntry.fromMap(Map<String, dynamic> map, {String? docId}) {
    return AuditEntry(
      id: docId ?? map['id'] ?? '',
      userName: map['userName'] ?? '',
      targetType: map['targetType'] ?? '',
      targetName: map['targetName'] ?? '',
      action: AuditAction.values.firstWhere(
        (e) => e.name == map['action'],
        orElse: () => AuditAction.edit,
      ),
      beforeValues: Map<String, String>.from(map['beforeValues'] ?? {}),
      afterValues: Map<String, String>.from(map['afterValues'] ?? {}),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isDeleted: map['isDeleted'] ?? false,
    );
  }
}
