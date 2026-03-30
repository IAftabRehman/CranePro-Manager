import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';
import 'dart:developer';

class FinanceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// TASK 2: Saves an expense to Firestore 'expenses' collection.
  Future<void> addExpense(ExpenseModel expense) async {
    try {
      await _firestore.collection('expenses').add(expense.toMap());
      log("Expense recorded successfully.");
    } on FirebaseException catch (e) {
      log("Firebase Error adding expense: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      log("Misc Error adding expense: $e");
      rethrow;
    }
  }

  /// TASK 2: Sums up all 'totalAmount' from 'quotations' collection.
  Future<double> getTotalEarnings() async {
    try {
      final snapshot = await _firestore.collection('quotations').get();
      double total = 0;
      for (var doc in snapshot.docs) {
        // Ensuring type safety with cast to Double
        total += (doc.data()['totalAmount'] as num?)?.toDouble() ?? 0.0;
      }
      return total;
    } on FirebaseException catch (e) {
      log("Firebase Error calculating earnings: ${e.code} - ${e.message}");
      return 0.0;
    } catch (e) {
      log("Misc Error calculating earnings: $e");
      return 0.0;
    }
  }

  /// TASK 2: Fetch expenses for a specific day.
  Future<List<ExpenseModel>> getDailyExpenses(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    try {
      final snapshot = await _firestore
          .collection('expenses')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      return snapshot.docs
          .map((doc) => ExpenseModel.fromMap(doc.data(), docId: doc.id))
          .toList();
    } on FirebaseException catch (e) {
      log("Firebase Error fetching daily expenses: ${e.code} - ${e.message}");
      return [];
    } catch (e) {
      log("Misc Error fetching daily expenses: $e");
      return [];
    }
  }
}
