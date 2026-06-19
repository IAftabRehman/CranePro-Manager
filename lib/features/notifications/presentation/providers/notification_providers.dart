import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/models/pending_item.dart';
import '../../data/models/notification_model.dart';

final notificationRepositoryProvider = Provider((ref) {
  return NotificationRepository();
});

final pendingWorkProvider = StreamProvider.family<List<PendingItem>, String>((ref, uid) {
  return ref.watch(notificationRepositoryProvider).listenToPendingWork(uid);
});

final notificationsStreamProvider = StreamProvider.family<List<NotificationModel>, (String, String)>((ref, arg) {
  final (uid, role) = arg;
  return ref.watch(notificationRepositoryProvider).getNotificationsStream(uid, role);
});
