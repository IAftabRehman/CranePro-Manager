import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/admin_repository.dart';

final adminRepositoryProvider = Provider((ref) => AdminRepository());

final usersStreamProvider = StreamProvider((ref) {
  return ref.watch(adminRepositoryProvider).getUsersStream();
});
