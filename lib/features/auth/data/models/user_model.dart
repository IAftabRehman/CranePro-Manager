import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, operator, viewer }

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String role; // 'admin', 'operator', 'viewer'
  final bool isAdminApproved;
  final bool isBlocked;
  final String? rejectionReason;
  final String? fcmToken;
  final DateTime? createdAt;
  final String? phoneNumber;
  final int totalQuotations;
  final DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.isAdminApproved = false,
    this.isBlocked = false,
    this.rejectionReason,
    this.fcmToken,
    this.createdAt,
    this.phoneNumber,
    this.totalQuotations = 0,
    this.lastLogin,
  });

  UserModel copyWith({
    String? fullName,
    String? email,
    String? role,
    bool? isAdminApproved,
    bool? isBlocked,
    String? rejectionReason,
    String? fcmToken,
    DateTime? createdAt,
    String? phoneNumber,
    int? totalQuotations,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      isAdminApproved: isAdminApproved ?? this.isAdminApproved,
      isBlocked: isBlocked ?? this.isBlocked,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      totalQuotations: totalQuotations ?? this.totalQuotations,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'role': role,
      'isAdminApproved': isAdminApproved,
      'isBlocked': isBlocked,
      'rejectionReason': rejectionReason,
      'fcmToken': fcmToken,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'phoneNumber': phoneNumber,
      'totalQuotations': totalQuotations,
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'viewer',
      isAdminApproved: map['isAdminApproved'] ?? false,
      isBlocked: map['isBlocked'] ?? false,
      rejectionReason: map['rejectionReason'],
      fcmToken: map['fcmToken'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      phoneNumber: map['phoneNumber'],
      totalQuotations: map['totalQuotations'] ?? 0,
      lastLogin: (map['lastLogin'] as Timestamp?)?.toDate(),
    );
  }
}
