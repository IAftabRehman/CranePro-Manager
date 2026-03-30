import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:state_notifier/state_notifier.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import 'dart:developer';

final authRepositoryProvider = Provider((ref) => AuthRepository());

class SignupNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  SignupNotifier(this._authRepository) : super(const AsyncValue.data(null));

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required String role,
  }) async {
    state = const AsyncValue.loading();

    try {
      final user = UserModel(
        id: '', // Will be set in AuthRepository after credential
        fullName: fullName,
        email: email,
        role: role,
        phoneNumber: phoneNumber,
        isAdminApproved: false, // Default to false
      );

      await _authRepository.signUpWithEmail(
        email: email,
        password: password,
        user: user,
      );

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      log("Signup Error: $e");
      state = AsyncValue.error(e, stack);
    }
  }
}

final signupProvider = StateNotifierProvider<SignupNotifier, AsyncValue<void>>((ref) {
  return SignupNotifier(ref.watch(authRepositoryProvider));
});
