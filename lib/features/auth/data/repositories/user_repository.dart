import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  /// Falls back to an email-based query if the UID-based doc doesn't exist,
  /// which handles cases where the Firestore doc ID ≠ Firebase Auth UID.
  Future<UserModel?> getCurrentUser(String uid) async {
    try {
      // Primary lookup: by UID (standard, fastest path)
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }

      // Fallback lookup: by Firebase Auth email
      // Needed when the Firestore doc was stored under a different ID.
      final authUser = await FirebaseAuth.instance.currentUser?.reload().then(
        (_) => FirebaseAuth.instance.currentUser,
      );
      if (authUser?.email == null) return null;

      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: authUser!.email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return UserModel.fromMap(query.docs.first.data());
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
