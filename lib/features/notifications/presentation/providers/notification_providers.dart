import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/models/pending_item.dart';

final notificationRepositoryProvider = Provider((ref) {
  return NotificationRepository();
});

final pendingWorkProvider = StreamProvider.family<List<PendingItem>, String>((ref, uid) {
  return ref.watch(notificationRepositoryProvider).listenToPendingWork(uid);
});
