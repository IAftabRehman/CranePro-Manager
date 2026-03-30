import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import 'dart:developer';

final authRepositoryProvider = Provider((ref) => AuthRepository());
final userRepositoryProvider = Provider((ref) => UserRepository());

/// Stream of current FirebaseAuth user.
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Future provider for the current user's profile.
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return null;
  return ref.watch(userRepositoryProvider).getCurrentUser(user.uid);
});

class LoginNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  LoginNotifier(this._authRepository) : super(const AsyncValue.data(null));

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      final user = await _authRepository.signInWithEmail(email, password);

      // Approval & Block Guards
      if (user.isBlocked) {
        await _authRepository.signOut();
        throw Exception("Your account is blocked. Contact Admin.");
      }

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      log("Login Error: $e");
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> logout() async {
    await _authRepository.signOut();
  }
}

final loginProvider = StateNotifierProvider<LoginNotifier, AsyncValue<void>>((ref) {
  return LoginNotifier(ref.watch(authRepositoryProvider));
});
