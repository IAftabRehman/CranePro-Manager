import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import '../models/pending_item.dart';
import '../models/notification_model.dart';
import '../../../quotation/data/models/quotation_model.dart';
import '../../../work_order/data/models/work_order_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository([FirebaseFirestore? firestore]) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Creates a new notification document in Firestore.
  Future<void> sendNotification({
    required String title,
    required String body,
    String? targetRole,
    String? targetUserId,
  }) async {
    final notification = NotificationModel(
      id: '',
      title: title,
      body: body,
      createdAt: DateTime.now(),
      targetRole: targetRole,
      targetUserId: targetUserId,
    );
    await _firestore.collection('notifications').add(notification.toMap());
  }

  /// Streams notifications relevant to a user based on their ID and role.
  Stream<List<NotificationModel>> getNotificationsStream(String userId, String role) {
    return _firestore
        .collection('notifications')
        .where(Filter.or(
          Filter('targetUserId', isEqualTo: userId),
          Filter('targetRole', isEqualTo: role),
        ))
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
              .where((notification) => !notification.dismissedBy.contains(userId))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  /// Marks a specific notification as read by a user.
  Future<void> markAsRead(String notificationId, String userId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'readBy': FieldValue.arrayUnion([userId]),
    });
  }

  /// Marks all notifications in a list as read by a user.
  Future<void> markAllAsRead(List<String> notificationIds, String userId) async {
    final batch = _firestore.batch();
    for (var id in notificationIds) {
      batch.update(_firestore.collection('notifications').doc(id), {
        'readBy': FieldValue.arrayUnion([userId]),
      });
    }
    await batch.commit();
  }

  /// Dismisses a specific notification for a user (hides it from their stream).
  Future<void> dismissNotification(String notificationId, String userId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'dismissedBy': FieldValue.arrayUnion([userId]),
    });
  }

  Stream<List<PendingItem>> listenToPendingWork(String uid) {
    // 1. Quotations Stream
    final quotationStream = _firestore
        .collection('quotations')
        .where('operatorId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
          final items = <PendingItem>[];
          for (var doc in snapshot.docs) {
            final data = doc.data();
            final q = QuotationModel.fromMap(data, docId: doc.id);
            items.add(PendingItem(
              id: doc.id,
              clientName: q.clientName,
              location: q.siteLocation,
              totalPrice: q.totalAmount - q.commission,
              type: 'quotation',
              createdAt: q.createdAt,
              originalModel: q,
            ));
          }
          return items;
        });

    // 2. Work Orders Stream
    final workOrderStream = _firestore
        .collection('work_orders')
        .where('operatorId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending_approval')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              final model = WorkOrderModel.fromMap(data, docId: doc.id);
              return PendingItem(
                id: doc.id,
                clientName: data['clientName'] ?? 'N/A',
                location: data['siteLocation'] ?? 'N/A',
                totalPrice: (data['netEarnings'] as num?)?.toDouble() ?? (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
                type: 'work_order',
                createdAt: (data['createdAt'] is Timestamp) 
                    ? (data['createdAt'] as Timestamp).toDate() 
                    : DateTime.now(),
                originalModel: model,
              );
            }).toList());

    // 3. Merge Streams using RxDart
    return Rx.combineLatest2<List<PendingItem>, List<PendingItem>, List<PendingItem>>(
      quotationStream,
      workOrderStream,
      (quotes, workOrders) {
        final combined = [...quotes, ...workOrders];
        combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return combined;
      },
    );
  }
}
