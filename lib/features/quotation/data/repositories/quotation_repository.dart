import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../models/quotation_model.dart';

class QuotationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates a new quotation in Firestore.
  Future<void> createQuotation(QuotationModel quotation) async {
    await FirebaseCrashlytics.instance.log("Action: createQuotation for Client: ${quotation.clientName}");
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

      // Write notification triggers for admin and viewer roles
      try {
        String operatorName = "Operator";
        final opDoc = await _firestore.collection('users').doc(quotation.operatorId).get();
        if (opDoc.exists) {
          operatorName = opDoc.data()?['fullName'] ?? "Operator";
        }

        final title = "New Quotation Generated";
        final body = "$operatorName generated a new pending quotation of AED ${quotation.totalAmount} for ${quotation.clientName} at ${quotation.siteLocation}.";
        final now = DateTime.now();

        await _firestore.collection('notifications').add({
          'title': title,
          'body': body,
          'createdAt': Timestamp.fromDate(now),
          'targetRole': 'admin',
          'readBy': [],
          'dismissedBy': [],
        });

        await _firestore.collection('notifications').add({
          'title': title,
          'body': body,
          'createdAt': Timestamp.fromDate(now),
          'targetRole': 'viewer',
          'readBy': [],
          'dismissedBy': [],
        });
      } catch (notifErr) {
        FirebaseCrashlytics.instance.log("Failed to write creation notification: $notifErr");
      }
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Failed to create quotation');
      rethrow;
    }
  }

  /// Fetches all quotations for a specific operator.
  /// Ordered by createdAt descending.
  Stream<List<QuotationModel>> getOperatorQuotations(String uid) {
    return _firestore
        .collection('quotations')
        .where('operatorId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return QuotationModel.fromMap(
          doc.data(),
          docId: doc.id,
        );
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
      return list.where((q) => 
        q.clientName.toLowerCase().contains(query.toLowerCase()) ||
        q.serviceType.toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }

  /// TASK 1 (Step 20-16): Fetch records within a specific date range.
  Stream<List<QuotationModel>> getQuotationsByDate(DateTime start, DateTime end) {
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
        .where('operatorId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      final quotations = snapshot.docs.map((doc) => QuotationModel.fromMap(doc.data(), docId: doc.id)).toList();
      quotations.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      for (final q in quotations) {
        if (q.shouldShowAlert) {
          return q;
        }
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
      final commission = (data['commission'] as num?)?.toDouble() ?? (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
      final operatorId = data['operatorId'] ?? '';

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

      // Trigger status update notifications
      if (oldStatus != newStatus) {
        try {
          String operatorName = "Operator";
          final opDoc = await _firestore.collection('users').doc(operatorId).get();
          if (opDoc.exists) {
            operatorName = opDoc.data()?['fullName'] ?? "Operator";
          }

          final clientName = data['clientName'] ?? 'N/A';
          final siteLocation = data['siteLocation'] ?? 'N/A';
          final title = newStatus == 'completed' ? 'Project Completed' : 'Project Status Update';
          final body = "$operatorName marked the quotation for $clientName at $siteLocation as $newStatus.";
          final now = DateTime.now();

          await _firestore.collection('notifications').add({
            'title': title,
            'body': body,
            'createdAt': Timestamp.fromDate(now),
            'targetRole': 'admin',
            'readBy': [],
            'dismissedBy': [],
          });

          await _firestore.collection('notifications').add({
            'title': title,
            'body': body,
            'createdAt': Timestamp.fromDate(now),
            'targetRole': 'viewer',
            'readBy': [],
            'dismissedBy': [],
          });
        } catch (notifErr) {
          FirebaseCrashlytics.instance.log("Failed to write status notification: $notifErr");
        }
      }
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Failed to update quotation status');
      rethrow;
    }
  }
}

final quotationRepositoryProvider = Provider((ref) => QuotationRepository());

final firstPendingQuotationProvider = StreamProvider.family<QuotationModel?, String>((ref, uid) {
  return ref.watch(quotationRepositoryProvider).watchFirstPendingQuotation(uid);
});

final allQuotationsProvider = StreamProvider<List<QuotationModel>>((ref) {
  return ref.watch(quotationRepositoryProvider).getAllQuotationsStream();
});
