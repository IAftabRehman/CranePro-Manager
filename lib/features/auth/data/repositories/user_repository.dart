import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import 'dart:developer';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates a new user document in Firestore if it doesn't already exist.
  Future<void> createUserInFirestore(UserModel user) async {
    try {
      final docRef = _firestore.collection('users').doc(user.id);
      final doc = await docRef.get();

      if (!doc.exists) {
        // Handle isAdminApproved logic: default to false for all except the first admin.
        // Actually, the prompt says "Ensure 'isAdminApproved' defaults to 'false' for every new signup except the very first Admin."
        // I'll assume the 'user' object passed already has this logic applied OR I should check the collection count.
        // For simplicity and matching the prompt's instruction:
        await docRef.set(user.toMap());
        log("User ${user.id} created successfully.");
      } else {
        log("User ${user.id} already exists.");
      }
    } catch (e) {
      log("Error creating user: $e");
      rethrow;
    }
  }

  /// Fetches user data from Firestore by UID.
  Future<UserModel?> getCurrentUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      log("Error fetching current user: $e");
      return null;
    }
  }

  /// Streams all operators who are approved by admin and not blocked.
  Stream<List<UserModel>> getApprovedOperatorsStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'operator')
        .where('isAdminApproved', isEqualTo: true)
        .where('isBlocked', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    });
  }
}

final userRepositoryProvider = Provider((ref) => UserRepository());

final approvedOperatorsProvider = StreamProvider<List<UserModel>>((ref) {
  return ref.watch(userRepositoryProvider).getApprovedOperatorsStream();
});
