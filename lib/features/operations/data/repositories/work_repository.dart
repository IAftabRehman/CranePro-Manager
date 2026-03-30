import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../quotation/data/models/quotation_model.dart';

class WorkRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'quotations';

  /// Adds a new quotation to Firestore.
  /// Uses .add() to generate a unique document ID.
  Future<void> addQuotation(QuotationModel quote) async {
    try {
      await _firestore.collection(_collection).add(quote.toMap());
    } catch (e) {
      throw Exception('Failed to add quotation: $e');
    }
  }

  /// Streams quotations for a specific operator, ordered by creation date.
  Stream<List<QuotationModel>> getOperatorWork(String uid) {
    return _firestore
        .collection(_collection)
        .where('operatorId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return QuotationModel.fromMap(doc.data(), docId: doc.id);
      }).toList();
    });
  }

  /// Updates the status of a specific quotation.
  Future<void> updateQuotationStatus(String docId, String status) async {
    try {
      await _firestore.collection(_collection).doc(docId).update({
        'status': status,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update quotation status: $e');
    }
  }
}
