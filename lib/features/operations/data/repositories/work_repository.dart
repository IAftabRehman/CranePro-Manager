import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extend_crane_services/features/quotation/data/models/quotation_model.dart';
import 'dart:developer';

class WorkRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// TASK 2: Saves a new quotation to Firestore using .add().
  Future<void> addQuotation(QuotationModel quote) async {
    try {
      await _firestore.collection('quotations').add(quote.toMap());
      log("Quotation created successfully.");
    } on FirebaseException catch (e) { // TASK 3: Catch FirebaseException
      log("Firebase Error adding quotation: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      log("Misc Error adding quotation: $e");
      rethrow;
    }
  }

  /// TASK 2: Fetches quotations for a specific operator (uid).
  Stream<List<QuotationModel>> getOperatorWork(String uid) {
    try {
      return _firestore
          .collection('quotations')
          .where('operatorId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => QuotationModel.fromMap(doc.data(), docId: doc.id))
              .toList());
    } on FirebaseException catch (e) {
      log("Firebase Error fetching operator work: ${e.code} - ${e.message}");
      return const Stream.empty();
    } catch (e) {
      log("Misc Error fetching operator work: $e");
      return const Stream.empty();
    }
  }

  /// TASK 2: Updates only the status field of a specific document.
  Future<void> updateWorkStatus(String docId, String newStatus) async {
    try {
      await _firestore.collection('quotations').doc(docId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      log("Quotation $docId status updated to $newStatus.");
    } on FirebaseException catch (e) {
      log("Firebase Error updating status: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      log("Misc Error updating status: $e");
      rethrow;
    }
  }
}
