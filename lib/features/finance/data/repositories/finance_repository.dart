import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';
import '../models/commission_model.dart';
import 'package:extend_crane_services/features/quotation/data/models/quotation_model.dart';
import 'dart:developer';

class FinanceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Saves an expense to Firestore.
  Future<void> addExpense(ExpenseModel expense) async {
    try {
      if (expense.amount < 0) throw Exception('Expense amount cannot be negative');
      await _firestore.collection('expenses').doc(expense.expenseId).set(expense.toMap());
      log("Expense ${expense.expenseId} added successfully.");
    } catch (e) {
      log("Error adding expense: $e");
      rethrow;
    }
  }

  /// Fetches expenses for a specific month.
  Future<List<ExpenseModel>> getMonthlyExpenses(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    try {
      final snapshot = await _firestore
          .collection('expenses')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      return snapshot.docs
          .map((doc) => ExpenseModel.fromMap(doc.data(), docId: doc.id))
          .toList();
    } catch (e) {
      log("Error fetching monthly expenses: $e");
      return [];
    }
  }

  /// Calculates total revenue from completed quotations.
  Future<double> getTotalRevenue() async {
    try {
      final snapshot = await _firestore
          .collection('quotations')
          .where('status', isEqualTo: 'completed')
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['totalAmount'] as num?)?.toDouble() ?? 0.0;
      }
      return total;
    } catch (e) {
      log("Error calculating total revenue: $e");
      return 0.0;
    }
  }

  /// Adds a commission record.
  Future<void> addCommission(CommissionModel commission) async {
    try {
      await _firestore.collection('commissions').add(commission.toMap());
      log("Commission recorded successfully.");
    } catch (e) {
      log("Error recording commission: $e");
      rethrow;
    }
  }
}
