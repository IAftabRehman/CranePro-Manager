import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../../../auth/data/models/user_model.dart';

class AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns a real-time stream of all users from the 'users' collection.
  Stream<List<UserModel>> getUsersStream() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    });
  }

  /// Approves a user by setting isAdminApproved to true.
  Future<void> approveUser(String userId) async {
    await FirebaseCrashlytics.instance.log("Action: approveUser - UID: $userId");
    await _firestore.collection('users').doc(userId).update({
      'isAdminApproved': true,
      'rejectionReason': FieldValue.delete(),
    });
  }

  /// Rejects a user with a specific reason.
  Future<void> rejectUser(String userId, String reason) async {
    await _firestore.collection('users').doc(userId).update({
      'isAdminApproved': false,
      'rejectionReason': reason,
    });
  }

  /// Toggles the block status of a user.
  Future<void> toggleBlockUser(String uid, bool blockStatus) async {
    await _firestore.collection('users').doc(uid).update({
      'isBlocked': blockStatus,
    });
  }

  /// Updates user status, approval, and role in a single operation.
  Future<void> updateUserStatus(String uid, bool isApproved, String role) async {
    await FirebaseCrashlytics.instance.log("Action: updateUserStatus - UID: $uid, Approved: $isApproved, Role: $role");
    await _firestore.collection('users').doc(uid).update({
      'isAdminApproved': isApproved,
      'role': role,
      'rejectionReason': isApproved ? FieldValue.delete() : null,
    });

    if (isApproved) {
      await FirebaseAnalytics.instance.logEvent(
        name: 'admin_approved_user',
        parameters: {
          'user_id': uid,
          'assigned_role': role,
        },
      );
    }
  }
}
