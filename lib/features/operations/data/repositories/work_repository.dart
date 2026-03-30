import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extend_crane_services/features/quotation/data/models/quotation_model.dart';
import 'dart:developer';

class WorkRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Saves a new quotation to Firestore.
  Future<void> createNewQuotation(QuotationModel quote) async {
    try {
      await _firestore.collection('quotations').doc(quote.quotationId).set(quote.toMap());
      log("Quotation ${quote.quotationId} created successfully.");
    } catch (e) {
      log("Error creating quotation: $e");
      rethrow;
    }
  }

  /// Fetches quotations for a specific operator.
  Stream<List<QuotationModel>> getQuotationsByOperator(String operatorId) {
    return _firestore
        .collection('quotations')
        .where('operatorId', isEqualTo: operatorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QuotationModel.fromMap(doc.data(), docId: doc.id))
            .toList());
  }

  /// Fetches all quotations (for Admin).
  Stream<List<QuotationModel>> getAllQuotations() {
    return _firestore
        .collection('quotations')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QuotationModel.fromMap(doc.data(), docId: doc.id))
            .toList());
  }
}
