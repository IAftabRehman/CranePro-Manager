import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum LogCategory {
  login(Icons.vpn_key_rounded, Colors.lightBlueAccent),
  work(Icons.precision_manufacturing_rounded, Colors.lightGreenAccent),
  maintenance(Icons.build_circle_rounded, Colors.yellow),
  cancellation(Icons.cancel_rounded, Colors.red),
  signup(Icons.person_add_alt_1_rounded, Colors.purple);

  final IconData icon;
  final Color color;
  const LogCategory(this.icon, this.color);
}

class ActivityLog {
  final String id;
  final String userName;
  final LogCategory category;
  final String message;
  final DateTime timestamp;

  const ActivityLog({
    required this.id,
    required this.userName,
    required this.category,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'category': category.name,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory ActivityLog.fromMap(Map<String, dynamic> map, {String? docId}) {
    return ActivityLog(
      id: docId ?? map['id'] ?? '',
      userName: map['userName'] ?? '',
      category: LogCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => LogCategory.work,
      ),
      message: map['message'] ?? '',
      timestamp: map['timestamp'] is Timestamp 
          ? (map['timestamp'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }
}
