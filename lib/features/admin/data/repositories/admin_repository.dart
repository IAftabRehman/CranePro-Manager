import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/data/models/user_model.dart';

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
  Future<void> toggleBlockUser(String userId, bool isBlocked) async {
    await _firestore.collection('users').doc(userId).update({
      'isBlocked': isBlocked,
    });
  }
}
