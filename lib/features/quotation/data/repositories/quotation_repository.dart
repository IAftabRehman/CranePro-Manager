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
      
      await FirebaseAnalytics.instance.logEvent(
        name: 'quotation_created',
        parameters: {
          'client_name': quotation.clientName,
          'total_amount': quotation.totalAmount,
        },
      );
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
}

final quotationRepositoryProvider = Provider((ref) => QuotationRepository());

final allQuotationsProvider = StreamProvider<List<QuotationModel>>((ref) {
  return ref.watch(quotationRepositoryProvider).getAllQuotationsStream();
});
