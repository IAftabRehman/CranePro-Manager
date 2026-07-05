import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extend_crane_services/features/work_order/data/repositories/work_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../models/quotation_model.dart';

class QuotationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates a new quotation in Firestore.
  Future<void> createQuotation(QuotationModel quotation) async {
    await FirebaseCrashlytics.instance.log(
      "Action: createQuotation for Client: ${quotation.clientName}",
    );
    try {
      final quotationMap = quotation.toMap();
      // Overriding createdAt with Server Timestamp for backend consistency
      quotationMap['createdAt'] = FieldValue.serverTimestamp();
      quotationMap['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('quotations').add(quotationMap);

      // Incremental update for financial summary metadata (only if completed)
      if (quotation.status.toLowerCase() == 'completed') {
        await _firestore.collection('metadata').doc('financials').set({
          'totalRevenue': FieldValue.increment(quotation.commission),
        }, SetOptions(merge: true));
      }

      await FirebaseAnalytics.instance.logEvent(
        name: 'quotation_created',
        parameters: {
          'client_name': quotation.clientName,
          'total_amount': quotation.totalAmount,
        },
      );
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'Failed to create quotation',
      );
      rethrow;
    }
  }

  /// Updates an existing quotation.
  Future<void> updateQuotation(QuotationModel quotation) async {
    try {
      final quotationMap = quotation.toMap();
      quotationMap['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore
          .collection('quotations')
          .doc(quotation.id)
          .update(quotationMap);
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'Failed to update quotation',
      );
      rethrow;
    }
  }

  /// Fetches all quotations for a specific operator.
  /// Ordered by createdAt descending.
  Stream<List<QuotationModel>> getOperatorQuotations(String uid) {
    return _firestore
        .collection('quotations')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return QuotationModel.fromMap(doc.data(), docId: doc.id);
          }).toList();
        });
  }

  /// TASK 1 (Step 20-14): Alias for fetching personal quotations.
  Stream<List<QuotationModel>> getMyQuotations(String uid) =>
      getOperatorQuotations(uid);

  /// TASK 1 (Step 20-16): Admin stream to fetch all quotations.
  Stream<List<QuotationModel>> getAllQuotationsStream() {
    return _firestore
        .collection('quotations')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return QuotationModel.fromMap(doc.data(), docId: doc.id);
          }).toList();
        });
  }

  /// TASK 1 (Step 20-16): Filter quotations locally or via query (Search).
  Stream<List<QuotationModel>> searchQuotations(String query) {
    return getAllQuotationsStream().map((list) {
      return list
          .where(
            (q) =>
                q.clientName.toLowerCase().contains(query.toLowerCase()) ||
                q.serviceType.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  /// TASK 1 (Step 20-16): Fetch records within a specific date range.
  Stream<List<QuotationModel>> getQuotationsByDate(
    DateTime start,
    DateTime end,
  ) {
    return _firestore
        .collection('quotations')
        .where('workDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('workDate', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return QuotationModel.fromMap(doc.data(), docId: doc.id);
          }).toList();
        });
  }

  /// NEW: Fetches the first (oldest) pending quotation to force user action.
  Stream<QuotationModel?> watchFirstPendingQuotation(String uid) {
    return _firestore
        .collection('quotations')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
          final quotations = snapshot.docs
              .map((doc) => QuotationModel.fromMap(doc.data(), docId: doc.id))
              .toList();
          quotations.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          for (final q in quotations) {
            return q;
          }
          return null;
        });
  }

  /// NEW: Update the status of a specific quotation document.
  Future<void> updateQuotationStatus(String docId, String status) async {
    try {
      final doc = await _firestore.collection('quotations').doc(docId).get();
      if (!doc.exists) return;
      final data = doc.data()!;
      final oldStatus = (data['status'] ?? 'pending').toString().toLowerCase();
      final commission =
          (data['commission'] as num?)?.toDouble() ??
          (data['totalAmount'] as num?)?.toDouble() ??
          0.0;

      await _firestore.collection('quotations').doc(docId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final newStatus = status.toLowerCase();
      if (oldStatus != 'completed' && newStatus == 'completed') {
        await _firestore.collection('metadata').doc('financials').set({
          'totalRevenue': FieldValue.increment(commission),
        }, SetOptions(merge: true));
      } else if (oldStatus == 'completed' && newStatus != 'completed') {
        await _firestore.collection('metadata').doc('financials').set({
          'totalRevenue': FieldValue.increment(-commission),
        }, SetOptions(merge: true));
      }
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'Failed to update quotation status',
      );
      rethrow;
    }
  }

  /// NEW: Deletes a quotation and deducts its value from financials if it was completed.
  Future<void> deleteQuotation(String docId) async {
    try {
      final doc = await _firestore.collection('quotations').doc(docId).get();
      if (!doc.exists) return;
      final data = doc.data()!;
      final status = (data['status'] ?? 'pending').toString().toLowerCase();
      final commission =
          (data['commission'] as num?)?.toDouble() ??
          (data['totalAmount'] as num?)?.toDouble() ??
          0.0;

      // Deduct from financials if completed
      if (status == 'completed') {
        await _firestore.collection('metadata').doc('financials').set({
          'totalRevenue': FieldValue.increment(-commission),
        }, SetOptions(merge: true));
      }

      await _firestore.collection('quotations').doc(docId).delete();
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'Failed to delete quotation',
      );
      rethrow;
    }
  }
}

final quotationRepositoryProvider = Provider((ref) => QuotationRepository());

final firstPendingQuotationProvider =
    StreamProvider.family<QuotationModel?, String>((ref, uid) {
      return ref
          .watch(quotationRepositoryProvider)
          .watchFirstPendingQuotation(uid);
    });

final allQuotationsProvider = StreamProvider<List<QuotationModel>>((ref) {
  return ref.watch(quotationRepositoryProvider).getAllQuotationsStream();
});

class PendingTask {
  final String id;
  final String type; // 'Quotation' or 'Direct Work'
  final String clientName;
  final String siteLocation;
  final double price;
  final DateTime createdAt;

  PendingTask({
    required this.id,
    required this.type,
    required this.clientName,
    required this.siteLocation,
    required this.price,
    required this.createdAt,
  });
}

final firstPendingTaskProvider = Provider<PendingTask?>((ref) {
  final quotationsAsync = ref.watch(allQuotationsProvider);
  final workOrdersAsync = ref.watch(allWorkOrdersProvider);

  return quotationsAsync.maybeWhen(
    data: (quotations) {
      return workOrdersAsync.maybeWhen(
        data: (workOrders) {
          final List<PendingTask> pending = [];

          for (final q in quotations) {
            if (q.status.toLowerCase() == 'pending') {
              pending.add(
                PendingTask(
                  id: q.id,
                  type: 'Quotation',
                  clientName: q.clientName,
                  siteLocation: q.siteLocation,
                  price: q.totalAmount,
                  createdAt: q.createdAt,
                ),
              );
            }
          }

          for (final w in workOrders) {
            if (w.status.toLowerCase() == 'pending_approval') {
              pending.add(
                PendingTask(
                  id: w.id,
                  type: 'Direct Work',
                  clientName: w.clientName,
                  siteLocation: w.siteLocation,
                  price: w.totalPrice,
                  createdAt: w.createdAt,
                ),
              );
            }
          }

          if (pending.isEmpty) return null;

          // Sort by createdAt ascending (oldest first)
          pending.sort((a, b) => a.createdAt.compareTo(b.createdAt));

          return pending.first;
        },
        orElse: () => null,
      );
    },
    orElse: () => null,
  );
});
