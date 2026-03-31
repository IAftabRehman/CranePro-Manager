import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:rxdart/rxdart.dart';
import '../models/expense_model.dart';
import 'dart:developer';

class FinancialSummary {
  final double totalRevenue;
  final double totalExpenses;
  final double netProfit;

  FinancialSummary({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netProfit,
  });
}

class FinanceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// TASK 1 (Step 20-13): Aggregates real-time financial data for Admin Dashboard.
  Stream<FinancialSummary> getFinancialSummaryStream() {
    final revenueStream = _firestore.collection('quotations').snapshots();
    final expenseStream = _firestore.collection('expenses').snapshots();

    return Rx.combineLatest2<QuerySnapshot, QuerySnapshot, FinancialSummary>(
      revenueStream,
      expenseStream,
      (revenueSnap, expenseSnap) {
        double revenue = 0.0;
        double expenses = 0.0;

        for (var doc in revenueSnap.docs) {
          final data = doc.data() as Map<String, dynamic>;
          revenue += (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
        }

        for (var doc in expenseSnap.docs) {
          final data = doc.data() as Map<String, dynamic>;
          expenses += (data['amount'] as num?)?.toDouble() ?? 0.0;
        }

        return FinancialSummary(
          totalRevenue: revenue,
          totalExpenses: expenses,
          netProfit: revenue - expenses,
        );
      },
    );
  }

  /// TASK 2: Saves an expense to Firestore 'expenses' collection.
  Future<void> addExpense(ExpenseModel expense) async {
    await FirebaseCrashlytics.instance.log("Action: addExpense - Category: ${expense.category}");
    try {
      await _firestore.collection('expenses').add(expense.toMap());
      
      await FirebaseAnalytics.instance.logEvent(
        name: 'expense_added',
        parameters: {
          'category': expense.category,
          'amount': expense.amount,
        },
      );
      log("Expense recorded successfully.");
    } on FirebaseException catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Firebase failed to add expense');
      log("Firebase Error adding expense: ${e.code} - ${e.message}");
      rethrow;
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Misc failure adding expense');
      log("Misc Error adding expense: $e");
      rethrow;
    }
  }

  /// TASK 3: Real-time stream of all expenses for Admin oversight.
  Stream<List<ExpenseModel>> getAllExpensesStream() {
    return _firestore
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExpenseModel.fromMap(doc.data(), docId: doc.id))
            .toList());
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

  /// TASK 1 (Step 20-14): Real-time stream of personal expenses for an operator.
  Stream<List<ExpenseModel>> getMyExpenses(String uid) {
    return _firestore
        .collection('expenses')
        .where('operatorId', isEqualTo: uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExpenseModel.fromMap(doc.data(), docId: doc.id))
            .toList());
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

final financeRepositoryProvider = Provider((ref) => FinanceRepository());

final financialSummaryProvider = StreamProvider<FinancialSummary>((ref) {
  return ref.watch(financeRepositoryProvider).getFinancialSummaryStream();
});

final allExpensesProvider = StreamProvider<List<ExpenseModel>>((ref) {
  return ref.watch(financeRepositoryProvider).getAllExpensesStream();
});
