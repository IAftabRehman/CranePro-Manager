enum UserRole { operator, viewer, admin }

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final UserRole role;
  final DateTime signupDate;
  final bool isAdminApproved;
  final bool isBlocked;
  final String? rejectionReason;
  final int totalQuotations;
  final DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.signupDate,
    this.isAdminApproved = false,
    this.isBlocked = false,
    this.rejectionReason,
    this.totalQuotations = 0,
    this.lastLogin,
  });

  UserModel copyWith({
    bool? isAdminApproved,
    bool? isBlocked,
    String? rejectionReason,
    int? totalQuotations,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id,
      fullName: fullName,
      email: email,
      role: role,
      signupDate: signupDate,
      isAdminApproved: isAdminApproved ?? this.isAdminApproved,
      isBlocked: isBlocked ?? this.isBlocked,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      totalQuotations: totalQuotations ?? this.totalQuotations,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'role': role.toString().split('.').last,
      'signupDate': signupDate.toIso8601String(),
      'isAdminApproved': isAdminApproved,
      'isBlocked': isBlocked,
      'rejectionReason': rejectionReason,
      'totalQuotations': totalQuotations,
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == map['role'],
        orElse: () => UserRole.viewer,
      ),
      signupDate: DateTime.parse(map['signupDate'] ?? DateTime.now().toIso8601String()),
      isAdminApproved: map['isAdminApproved'] ?? false,
      isBlocked: map['isBlocked'] ?? false,
      rejectionReason: map['rejectionReason'],
      totalQuotations: map['totalQuotations'] ?? 0,
      lastLogin: map['lastLogin'] != null ? DateTime.parse(map['lastLogin']) : null,
    );
  }
}
