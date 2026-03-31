import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'user_repository.dart';
import 'dart:developer';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepository = UserRepository();

  /// Signs up a new user with email and password and creates their Firestore profile.
  /// TASK 1 Implementation: Exact 3-step flow.
  Future<void> signUp(String email, String password, UserModel user) async {
    try {
      // 1. Create user in Firebase Auth
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // 2. Use the returned User.uid to set 'user.id'
        final finalUser = user.copyWith(
          id: credential.user!.uid,
          isAdminApproved: false,
          createdAt: DateTime.now(),
        );

        // 3. Call FirebaseFirestore.instance.collection('users').doc(user.id).set(user.toMap())
        await FirebaseFirestore.instance
            .collection('users')
            .doc(finalUser.id)
            .set(finalUser.toMap());
        
        log("User profile initialized for UID: ${credential.user!.uid}");
      }
    } on FirebaseAuthException catch (e) {
      log("Auth Exception: ${e.code} - ${e.message}");
      String errorMessage = 'SignUp is failed, please try again.';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'This email is already Used in SignUp, Use another email';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password is week, make it strong';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Email is not a correct formate';
      }
      throw Exception(errorMessage);
    } catch (e) {
      log("Misc Exception: $e");
      rethrow;
    }
  }

  /// Signs in a user with email and password and returns their profile.
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final userModel = await _userRepository.getCurrentUser(credential.user!.uid);
        if (userModel == null) {
          throw Exception("User profile not found in database.");
        }
        return userModel;
      } else {
        throw Exception("Authentication failed.");
      }
    } on FirebaseAuthException catch (e) {
      log("Auth Exception: ${e.code} - ${e.message}");
      String errorMessage = 'Login is failed, please check your email and password are correct.';
      if (e.code == 'user-not-found') {
        errorMessage = 'Ye email is not register, firstly go to signUp and create account.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Password is wrong.';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'This account is block by Admin please contact "+92 332 3220916".';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Email address is not correct';
      }
      throw Exception(errorMessage);
    } catch (e) {
      log("Misc Exception: $e");
      rethrow;
    }
  }


  /// Signs out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
