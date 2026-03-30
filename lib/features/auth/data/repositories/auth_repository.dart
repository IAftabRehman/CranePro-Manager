import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'user_repository.dart';
import 'dart:developer';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepository = UserRepository();

  /// Signs up a new user with email and password and creates their Firestore profile.
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required UserModel user,
  }) async {
    try {
      // Security Check: Ensure 'admin' role is not assignable via public signup.
      if (user.role == 'admin') {
        throw FirebaseAuthException(
          code: 'unauthorized-role',
          message: 'Admin role is not assignable via public signup.',
        );
      }

      // 1. Create user in Firebase Auth
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create correctly assigned model with Firebase UID
        final finalUser = UserModel(
          id: credential.user!.uid,
          fullName: user.fullName,
          email: user.email,
          role: user.role,
          isAdminApproved: false, // Default to false
          phoneNumber: user.phoneNumber,
          createdAt: DateTime.now(),
        );

        // 3. Call UserRepository().createUserInFirestore(user)
        await _userRepository.createUserInFirestore(finalUser);
        log("User profile initialized for UID: ${credential.user!.uid}");
      }
    } on FirebaseAuthException catch (e) {
      log("Auth Exception: ${e.code} - ${e.message}");
      // Handle Firebase Exceptions as requested
      String errorMessage = 'Signup fail ho gaya. Dobara koshish karein.';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Ye email pehle se maujood hai. Kuch aur use karein.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password bohat kamzor hai. Kam az kam 6 characters use karein.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Email address theek nahi hai.';
      } else if (e.code == 'unauthorized-role') {
        errorMessage = 'Aap admin nahi ban sakte. Ghalat role select kiya gaya hai.';
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
      String errorMessage = 'Login fail ho gaya. Login details check karein.';
      if (e.code == 'user-not-found') {
        errorMessage = 'Ye email registered nahi hai.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Password ghalat hai.';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'Aapka account disable kar diya gaya hai.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Email address theek nahi hai.';
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
