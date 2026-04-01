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
  final Map<String, double> categoryBreakdown;

  FinancialSummary({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netProfit,
    this.categoryBreakdown = const {},
  });
}

class OperatorStats {
  final double totalEarnings;
  final double totalExpenses;
  final double netBalance;
  final int totalQuotes;
  final int activeJobs;
  final int maintenanceCount;

  OperatorStats({
    required this.totalEarnings,
    required this.totalExpenses,
    required this.netBalance,
    this.totalQuotes = 0,
    this.activeJobs = 0,
    this.maintenanceCount = 0,
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
        final Map<String, double> breakdown = {};

        for (var doc in revenueSnap.docs) {
          final data = doc.data() as Map<String, dynamic>;
          revenue += (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
        }

        for (var doc in expenseSnap.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
          final category = data['category']?.toString() ?? 'Other';
          
          expenses += amount;
          breakdown[category] = (breakdown[category] ?? 0.0) + amount;
        }

        return FinancialSummary(
          totalRevenue: revenue,
          totalExpenses: expenses,
          netProfit: revenue - expenses,
          categoryBreakdown: breakdown,
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

  /// TASK 1: Implement personal analytics for Operator.
  /// Combines quotations (Earnings) and Expenses for real-time dashboard.
  Stream<OperatorStats> getOperatorStatsStream(String uid) {
    final revenueStream = _firestore
        .collection('quotations')
        .where('operatorId', isEqualTo: uid)
        .snapshots();

    final expenseStream = _firestore
        .collection('expenses')
        .where('operatorId', isEqualTo: uid)
        .snapshots();

    return Rx.combineLatest2<QuerySnapshot, QuerySnapshot, OperatorStats>(
      revenueStream,
      expenseStream,
      (revenueSnap, expenseSnap) {
        double revenue = 0.0;
        double expenses = 0.0;
        int activeJobs = 0;
        int maintenanceCount = 0;

        for (var doc in revenueSnap.docs) {
          final data = doc.data() as Map<String, dynamic>;
          revenue += (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
          
          final status = (data['status'] ?? 'pending').toString().toLowerCase();
          if (status == 'pending' || status == 'in progress') {
            activeJobs++;
          }
        }

        for (var doc in expenseSnap.docs) {
          final data = doc.data() as Map<String, dynamic>;
          expenses += (data['amount'] as num?)?.toDouble() ?? 0.0;
          
          final category = (data['category'] ?? 'Other').toString();
          if (category == 'Maintenance') {
            maintenanceCount++;
          }
        }

        return OperatorStats(
          totalEarnings: revenue,
          totalExpenses: expenses,
          netBalance: revenue - expenses,
          totalQuotes: revenueSnap.docs.length,
          activeJobs: activeJobs,
          maintenanceCount: maintenanceCount,
        );
      },
    );
  }

  /// TASK 1: Stream of mixed recent activity (Last 5 jobs/expenses).
  Stream<List<dynamic>> getOperatorRecentActivity(String uid) {
    final quotationStream = _firestore
        .collection('quotations')
        .where('operatorId', isEqualTo: uid)
        .snapshots();
        
    final expenseStream = _firestore
        .collection('expenses')
        .where('operatorId', isEqualTo: uid)
        .snapshots();

    return Rx.combineLatest2<QuerySnapshot, QuerySnapshot, List<dynamic>>(
      quotationStream,
      expenseStream,
      (quoteSnap, expenseSnap) {
        final list = <dynamic>[];
        for (var doc in quoteSnap.docs) {
           final data = doc.data() as Map<String, dynamic>?;
           if (data == null) continue;
           
           final createdAt = data['createdAt'];
           list.add({
             'type': 'job',
             'description': data['clientName'] ?? 'Crane Job',
             'amount': (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
             'date': createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
           });
        }
        for (var doc in expenseSnap.docs) {
           final data = doc.data() as Map<String, dynamic>?;
           if (data == null) continue;

           final date = data['date'];
           list.add({
             'type': 'expense',
             'description': data['description'] ?? 'Expense',
             'amount': (data['amount'] as num?)?.toDouble() ?? 0.0,
             'date': date is Timestamp ? date.toDate() : DateTime.now(),
           });
        }
        list.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
        return list.take(5).toList();
      },
    );
  }

  /// TASK 4 (Step 20-3): Raw stream of all expenses (Full bypass).
  /// This version has NO index requirements. Sorting and filtering must happen in Dart.
  Stream<List<ExpenseModel>> getRawExpensesStream() {
    return _firestore
        .collection('expenses')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExpenseModel.fromMap(doc.data(), docId: doc.id))
            .toList());
  }

  /// TASK 4 (Step 20-3): Stream of personal expenses (Operator view).
  /// This version avoids composite index requirements for flexible filtering.
  Stream<List<ExpenseModel>> getOperatorExpensesStream(String uid) {
    return _firestore
        .collection('expenses')
        .where('operatorId', isEqualTo: uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExpenseModel.fromMap(doc.data(), docId: doc.id))
            .toList());
  }

  /// TASK 4 (Step 20-3): Stream of ALL expenses (Admin view).
  /// This version avoids composite index requirements for flexible filtering.
  Stream<List<ExpenseModel>> getAllExpensesStreamIndexFree() {
    return _firestore
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExpenseModel.fromMap(doc.data(), docId: doc.id))
            .toList());
  }
}

final financeRepositoryProvider = Provider((ref) => FinanceRepository());

final financialSummaryProvider = StreamProvider<FinancialSummary>((ref) {
  return ref.watch(financeRepositoryProvider).getFinancialSummaryStream();
});

final allExpensesProvider = StreamProvider<List<ExpenseModel>>((ref) {
  return ref.watch(financeRepositoryProvider).getAllExpensesStream();
});

final operatorStatsProvider = StreamProvider.family<OperatorStats, String>((ref, uid) {
  return ref.watch(financeRepositoryProvider).getOperatorStatsStream(uid);
});

final operatorRecentActivityProvider = StreamProvider.family<List<dynamic>, String>((ref, uid) {
  return ref.watch(financeRepositoryProvider).getOperatorRecentActivity(uid);
});
