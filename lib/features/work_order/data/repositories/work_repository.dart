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
        createdAt: workOrder.createdAt,
      );

      await docRef.set(updatedWorkOrder.toMap());
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Work Order Creation Failed');
      rethrow;
    }
  }

  /// Returns a stream of work orders sorted by creation date.
  Stream<List<WorkOrderModel>> getWorkOrdersStream() {
    return _firestore
        .collection('work_orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => WorkOrderModel.fromMap(doc.data(), docId: doc.id))
              .toList();
        });
  }
}

final workRepositoryProvider = Provider((ref) => WorkRepository());
