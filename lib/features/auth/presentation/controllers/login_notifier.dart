import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/user_repository.dart';

export '../../data/repositories/user_repository.dart';

final userRepositoryProvider = Provider((ref) => UserRepository());

/// Stub: No Firebase Auth. Returns null for all user lookups.
/// This keeps downstream files that reference currentUserProvider compiling
/// without requiring a logged-in user.
final currentUserProvider = FutureProvider<dynamic>((ref) async => null);
