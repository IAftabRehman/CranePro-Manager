import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import '../models/pending_item.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository([FirebaseFirestore? firestore]) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<PendingItem>> listenToPendingWork(String uid) {
    // 1. Quotations Stream
    final quotationStream = _firestore
        .collection('quotations')
        .where('operatorId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return PendingItem(
                id: doc.id,
                clientName: data['clientName'] ?? 'N/A',
                location: data['siteLocation'] ?? 'N/A',
                totalPrice: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
                type: 'quotation',
                createdAt: (data['createdAt'] is Timestamp) 
                    ? (data['createdAt'] as Timestamp).toDate() 
                    : DateTime.now(),
              );
            }).toList());

    // 2. Work Orders Stream
    final workOrderStream = _firestore
        .collection('work_orders')
        .where('operatorId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return PendingItem(
                id: doc.id,
                clientName: data['clientName'] ?? 'N/A',
                location: data['siteLocation'] ?? 'N/A',
                totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
                type: 'work_order',
                createdAt: (data['createdAt'] is Timestamp) 
                    ? (data['createdAt'] as Timestamp).toDate() 
                    : DateTime.now(),
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
