import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../models/work_order_model.dart';

class WorkRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Saves a new work order to the 'work_orders' collection.
  /// Status is automatically 'pending_approval' from the model.
  Future<void> createWorkOrder(WorkOrderModel workOrder) async {
    try {
      final docRef = _firestore.collection('work_orders').doc();
      
      // Ensure ID and workOrderId are set if not provided
      final updatedWorkOrder = WorkOrderModel(
        id: docRef.id,
        workOrderId: workOrder.workOrderId.isEmpty 
            ? 'WO-${DateTime.now().millisecondsSinceEpoch}' 
            : workOrder.workOrderId,
        operatorId: workOrder.operatorId,
        operatorName: workOrder.operatorName,
        clientName: workOrder.clientName,
        siteLocation: workOrder.siteLocation,
        status: workOrder.status,
        totalPrice: workOrder.totalPrice,
        workCommission: workOrder.workCommission,
        netEarnings: workOrder.netEarnings,
        createdAt: workOrder.createdAt,
      );

      await docRef.set(updatedWorkOrder.toMap());
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Work Order Creation Failed');
      rethrow;
    }
  }

  /// Updates an existing work order.
  Future<void> updateWorkOrder(WorkOrderModel workOrder) async {
    try {
      final workOrderMap = workOrder.toMap();
      workOrderMap['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('work_orders').doc(workOrder.id).update(workOrderMap);
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Failed to update work order');
      rethrow;
    }
  }

  /// Returns a stream of work orders sorted by creation date.
  Stream<List<WorkOrderModel>> getWorkOrdersStream() {
    return _firestore
        .collection('work_orders')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => WorkOrderModel.fromMap(doc.data(), docId: doc.id))
              .toList();
        });
  }

  /// NEW: Update the status of a specific work order document.
  Future<void> updateWorkOrderStatus(String docId, String status) async {
    try {
      await _firestore.collection('work_orders').doc(docId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Failed to update work order status');
      rethrow;
    }
  }

  /// NEW: Complete a work order and set the paymentStatus ('received' or 'pending').
  Future<void> completeWithPayment(String docId, String paymentStatus) async {
    try {
      await _firestore.collection('work_orders').doc(docId).update({
        'status': 'completed',
        'paymentStatus': paymentStatus, // 'received' or 'pending'
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Failed to complete work order with payment');
      rethrow;
    }
  }

  /// NEW: Update only the paymentStatus field of a work order.
  Future<void> updatePaymentStatus(String docId, String paymentStatus) async {
    try {
      await _firestore.collection('work_orders').doc(docId).update({
        'paymentStatus': paymentStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Failed to update payment status');
      rethrow;
    }
  }

  /// NEW: Deletes a work order and deducts its value from financials if it was completed.
  Future<void> deleteWorkOrder(String docId) async {
    try {
      final doc = await _firestore.collection('work_orders').doc(docId).get();
      if (!doc.exists) return;
      final data = doc.data()!;
      final status = (data['status'] ?? 'pending_approval').toString().toLowerCase();
      final amount = (data['netEarnings'] as num?)?.toDouble() ?? (data['totalPrice'] as num?)?.toDouble() ?? 0.0;

      // Deduct from financials if completed
      if (status == 'completed') {
        await _firestore.collection('metadata').doc('financials').set({
          'totalRevenue': FieldValue.increment(-amount),
        }, SetOptions(merge: true));
      }

      await _firestore.collection('work_orders').doc(docId).delete();
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Failed to delete work order');
      rethrow;
    }
  }
}

final workRepositoryProvider = Provider((ref) => WorkRepository());

final allWorkOrdersProvider = StreamProvider<List<WorkOrderModel>>((ref) {
  return ref.watch(workRepositoryProvider).getWorkOrdersStream();
});
