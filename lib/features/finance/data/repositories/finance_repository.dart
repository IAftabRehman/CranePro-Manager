import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import 'dart:developer';
import 'dart:isolate';

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
  final int pendingJob;
  final int maintenanceCount;

  OperatorStats({
    required this.totalEarnings,
    required this.totalExpenses,
    required this.netBalance,
    this.totalQuotes = 0,
    this.pendingJob = 0,
    this.maintenanceCount = 0,
  });
}

class OperatorEarningsReport {
  final double quotationIncome;
  final double directWorkIncome;
  final double maintenanceExpenses;
  final double fuelExpenses;
  final double totalExpenses;
  final double partnerCommission;
  final double netProfit;
  final List<ChartDataPoint> weeklyGrowth;

  OperatorEarningsReport({
    required this.quotationIncome,
    required this.directWorkIncome,
    required this.maintenanceExpenses,
    required this.fuelExpenses,
    required this.totalExpenses,
    required this.partnerCommission,
    required this.netProfit,
    required this.weeklyGrowth,
  });
}

class ChartDataPoint {
  final DateTime date;
  final double amount;
  ChartDataPoint(this.date, this.amount);
}

class FinanceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// TASK 1 (Step 20-13): Aggregates real-time financial data for Admin Dashboard.
  /// Optimized: Streams a single metadata document, falling back to aggregate initialization if not present.
  Stream<FinancialSummary> getFinancialSummaryStream() {
    return _firestore
        .collection('metadata')
        .doc('financials')
        .snapshots()
        .asyncMap((doc) async {
          if (!doc.exists ||
              doc.data() == null ||
              !doc.data()!.containsKey('totalRevenue') ||
              !doc.data()!.containsKey('totalExpenses')) {
            return await _initializeFinancialsMetadata();
          }

          final data = doc.data()!;
          final breakdownMap =
              (data['categoryBreakdown'] as Map<String, dynamic>?) ?? {};
          final Map<String, double> breakdown = {};
          breakdownMap.forEach((k, v) {
            breakdown[k] = (v as num).toDouble();
          });

          final revenue = (data['totalRevenue'] as num?)?.toDouble() ?? 0.0;
          final expenses = (data['totalExpenses'] as num?)?.toDouble() ?? 0.0;

          return FinancialSummary(
            totalRevenue: revenue,
            totalExpenses: expenses,
            netProfit: revenue - expenses,
            categoryBreakdown: breakdown,
          );
        });
  }

  /// Initial calculation and saving of financial metadata.
  Future<FinancialSummary> _initializeFinancialsMetadata() async {
    final quotations = await _firestore.collection('quotations').get();
    final workOrders = await _firestore.collection('work_orders').get();
    final expenses = await _firestore.collection('expenses').get();

    double totalRevenue = 0.0;
    double totalExpenses = 0.0;
    final Map<String, double> breakdown = {};

    for (var doc in quotations.docs) {
      final data = doc.data();
      final status = (data['status'] ?? 'pending').toString().toLowerCase();
      if (status == 'completed') {
        final comm = (data['commission'] as num?)?.toDouble() ?? 0.0;
        final total = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
        totalRevenue += (total - comm);
      }
    }

    for (var doc in workOrders.docs) {
      final data = doc.data();
      final status = (data['status'] ?? 'pending_approval')
          .toString()
          .toLowerCase();
      if (status == 'completed') {
        totalRevenue +=
            (data['netEarnings'] as num?)?.toDouble() ??
            (data['totalPrice'] as num?)?.toDouble() ??
            0.0;
      }
    }

    for (var doc in expenses.docs) {
      final data = doc.data();
      final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
      final category = data['category']?.toString() ?? 'Other';

      totalExpenses += amount;
      breakdown[category] = (breakdown[category] ?? 0.0) + amount;
    }

    final summary = FinancialSummary(
      totalRevenue: totalRevenue,
      totalExpenses: totalExpenses,
      netProfit: totalRevenue - totalExpenses,
      categoryBreakdown: breakdown,
    );

    await _firestore.collection('metadata').doc('financials').set({
      'totalRevenue': totalRevenue,
      'totalExpenses': totalExpenses,
      'categoryBreakdown': breakdown,
      'initializedAt': FieldValue.serverTimestamp(),
    });

    return summary;
  }

  /// TASK 2: Saves an expense to Firestore 'expenses' collection.
  Future<void> addExpense(ExpenseModel expense) async {
    await FirebaseCrashlytics.instance.log(
      "Action: addExpense - Category: ${expense.category}",
    );
    try {
      await _firestore.collection('expenses').add(expense.toMap());

      // Incremental update for financial summary metadata
      await _firestore.collection('metadata').doc('financials').set({
        'totalExpenses': FieldValue.increment(expense.amount),
        'categoryBreakdown.${expense.category}': FieldValue.increment(
          expense.amount,
        ),
      }, SetOptions(merge: true));

      await FirebaseAnalytics.instance.logEvent(
        name: 'expense_added',
        parameters: {'category': expense.category, 'amount': expense.amount},
      );
      log("Expense recorded successfully.");
    } on FirebaseException catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'Firebase failed to add expense',
      );
      log("Firebase Error adding expense: ${e.code} - ${e.message}");
      rethrow;
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'Misc failure adding expense',
      );
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
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ExpenseModel.fromMap(doc.data(), docId: doc.id))
              .toList(),
        );
  }

  /// Optimized: Real-time stream of recent expenses with limit for dashboard view.
  Stream<List<ExpenseModel>> getRecentExpensesStream(int limit) {
    return _firestore
        .collection('expenses')
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ExpenseModel.fromMap(doc.data(), docId: doc.id))
              .toList(),
        );
  }

  /// TASK 2: Sums up all 'totalAmount' from 'quotations' and 'work_orders' collection.
  Future<double> getTotalEarnings() async {
    try {
      final snapshot = await _firestore.collection('quotations').get();
      final snapshot2 = await _firestore.collection('work_orders').get();
      double total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final status = (data['status'] ?? 'pending').toString().toLowerCase();
        if (status == 'completed') {
          final comm = (data['commission'] as num?)?.toDouble() ?? 0.0;
          final t = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
          total += (t - comm);
        }
      }
      for (var doc in snapshot2.docs) {
        final data = doc.data();
        final status = (data['status'] ?? 'pending_approval')
            .toString()
            .toLowerCase();
        if (status == 'completed') {
          total +=
              (data['netEarnings'] as num?)?.toDouble() ??
              (data['totalPrice'] as num?)?.toDouble() ??
              0.0;
        }
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

        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ExpenseModel.fromMap(doc.data(), docId: doc.id))
              .toList(),
        );
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
  /// Combines quotations, work orders (Earnings) and Expenses for real-time dashboard.
  Stream<OperatorStats> getOperatorStatsStream(String uid) {
    final revenueStream = _firestore
        .collection('quotations')

        .snapshots();

    final workStream = _firestore
        .collection('work_orders')

        .snapshots();

    final expenseStream = _firestore
        .collection('expenses')

        .snapshots();

    return Rx.combineLatest3<
      QuerySnapshot,
      QuerySnapshot,
      QuerySnapshot,
      List<List<Map<String, dynamic>>>
    >(revenueStream, workStream, expenseStream, (
      revenueSnap,
      workSnap,
      expenseSnap,
    ) {
      return [
        revenueSnap.docs.map((d) => d.data() as Map<String, dynamic>).toList(),
        workSnap.docs.map((d) => d.data() as Map<String, dynamic>).toList(),
        expenseSnap.docs.map((d) => d.data() as Map<String, dynamic>).toList(),
      ];
    }).asyncMap((dataLists) async {
      return await Isolate.run(() {
        final revenueDocs = dataLists[0];
        final workDocs = dataLists[1];
        final expenseDocs = dataLists[2];

        double revenue = 0.0;
        double expenses = 0.0;
        int pendingJob = 0;
        int maintenanceCount = 0;
        int totalJobs = revenueDocs.length + workDocs.length;

        for (var data in revenueDocs) {
          final status = (data['status'] ?? 'pending').toString().toLowerCase();

          // Earnings are counted only when the job is completed
          if (status == 'completed') {
            final comm = (data['commission'] as num?)?.toDouble() ?? 0.0;
            final total = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
            revenue += (total - comm);
          }

          if (status == 'pending' || status == 'in progress') {
            pendingJob++;
          }
        }

        for (var data in workDocs) {
          final status = (data['status'] ?? 'pending_approval')
              .toString()
              .toLowerCase();

          if (status == 'completed') {
            revenue +=
                (data['netEarnings'] as num?)?.toDouble() ??
                (data['totalPrice'] as num?)?.toDouble() ??
                0.0;
          }

          if (status == 'pending_approval' || status == 'in progress') {
            pendingJob++;
          }
        }

        for (var data in expenseDocs) {
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
          totalQuotes: totalJobs,
          pendingJob: pendingJob,
          maintenanceCount: maintenanceCount,
        );
      });
    });
  }

  /// TASK 1: Stream of mixed recent activity (Last 5 jobs/expenses).
  Stream<List<dynamic>> getOperatorRecentActivity(String uid) {
    final quotationStream = _firestore
        .collection('quotations')

        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots();

    final workStream = _firestore
        .collection('work_orders')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots();

    final expenseStream = _firestore
        .collection('expenses')

        .orderBy('date', descending: true)
        .limit(5)
        .snapshots();

    return Rx.combineLatest3<
      QuerySnapshot,
      QuerySnapshot,
      QuerySnapshot,
      List<List<Map<String, dynamic>?>>
    >(quotationStream, workStream, expenseStream, (
      quoteSnap,
      workSnap,
      expenseSnap,
    ) {
      return [
        quoteSnap.docs.map((d) => d.data() as Map<String, dynamic>?).toList(),
        workSnap.docs.map((d) => d.data() as Map<String, dynamic>?).toList(),
        expenseSnap.docs.map((d) => d.data() as Map<String, dynamic>?).toList(),
      ];
    }).asyncMap((dataLists) async {
      return await Isolate.run(() {
        final quoteDocs = dataLists[0];
        final workDocs = dataLists[1];
        final expenseDocs = dataLists[2];

        final list = <dynamic>[];
        for (var data in quoteDocs) {
          if (data == null) continue;

          final status = (data['status'] ?? 'pending').toString().toLowerCase();
          // Only show completed jobs as positive income/activity on dashboard
          if (status != 'completed') continue;

          final createdAt = data['createdAt'];
          final comm = (data['commission'] as num?)?.toDouble() ?? 0.0;
          final total = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
          list.add({
            'type': 'job',
            'description': data['clientName'] ?? 'Crane Job (Quote)',
            'amount': (total - comm),
            'date': createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
          });
        }
        for (var data in workDocs) {
          if (data == null) continue;

          final status = (data['status'] ?? 'pending_approval')
              .toString()
              .toLowerCase();
          if (status != 'completed') continue;

          final createdAt = data['createdAt'];
          list.add({
            'type': 'job',
            'description': data['clientName'] ?? 'Direct Work',
            'amount':
                (data['netEarnings'] as num?)?.toDouble() ??
                (data['totalPrice'] as num?)?.toDouble() ??
                0.0,
            'date': createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
          });
        }
        for (var data in expenseDocs) {
          if (data == null) continue;

          final date = data['date'];
          list.add({
            'type': 'expense',
            'description': data['description'] ?? 'Expense',
            'amount': (data['amount'] as num?)?.toDouble() ?? 0.0,
            'date': date is Timestamp ? date.toDate() : DateTime.now(),
          });
        }
        list.sort(
          (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
        );
        return list.take(5).toList();
      });
    });
  }

  /// TASK 4 (Step 20-3): Raw stream of all expenses (Full bypass).
  /// This version has NO index requirements. Sorting and filtering must happen in Dart.
  Stream<List<ExpenseModel>> getRawExpensesStream() {
    return _firestore
        .collection('expenses')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ExpenseModel.fromMap(doc.data(), docId: doc.id))
              .toList(),
        );
  }

  /// TASK 4 (Step 20-3): Stream of personal expenses (Operator view).
  /// This version avoids composite index requirements for flexible filtering.
  Stream<List<ExpenseModel>> getOperatorExpensesStream(String uid) {
    return _firestore
        .collection('expenses')

        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ExpenseModel.fromMap(doc.data(), docId: doc.id))
              .toList(),
        );
  }

  /// TASK 4 (Step 20-3): Stream of ALL expenses (Admin view).
  /// This version avoids composite index requirements for flexible filtering.
  Stream<List<ExpenseModel>> getAllExpensesStreamIndexFree() {
    return _firestore
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ExpenseModel.fromMap(doc.data(), docId: doc.id))
              .toList(),
        );
  }

  /// NEW: Stream specifically for the Earnings & Analytics Page.
  /// Combines all financial factors filtered by operator and date range.
  Stream<OperatorEarningsReport> getOperatorDetailedReport(
    String uid,
    DateTime start,
    DateTime end,
  ) {
    final quoteStream = _firestore
        .collection('quotations')

        .where('status', isEqualTo: 'completed')
        .where('updatedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('updatedAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .snapshots();

    final workStream = _firestore
        .collection('work_orders')

        .snapshots();

    final expenseStream = _firestore
        .collection('expenses')

        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .snapshots();

    return Rx.combineLatest3<
      QuerySnapshot,
      QuerySnapshot,
      QuerySnapshot,
      List<List<Map<String, dynamic>>>
    >(quoteStream, workStream, expenseStream, (
      quoteSnap,
      workSnap,
      expenseSnap,
    ) {
      return [
        quoteSnap.docs.map((d) => d.data() as Map<String, dynamic>).toList(),
        workSnap.docs.map((d) => d.data() as Map<String, dynamic>).toList(),
        expenseSnap.docs.map((d) => d.data() as Map<String, dynamic>).toList(),
      ];
    }).asyncMap((dataLists) async {
      return await Isolate.run(() {
        final quoteDocs = dataLists[0];
        final workDocs = dataLists[1];
        final expenseDocs = dataLists[2];

        double quoteIncome = 0.0;
        double workIncome = 0.0;
        double maintenance = 0.0;
        double fuel = 0.0;
        double otherExpenses = 0.0;

        // Grouping for weekly chart (last 7 days of growth)
        final Map<String, double> dayTotals = {};

        // 1. Process Quotations
        for (var data in quoteDocs) {
          final comm = (data['commission'] as num?)?.toDouble() ?? 0.0;
          final total = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
          final amount = (total - comm);
          final date =
              (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now();

          if (date.isAfter(start) && date.isBefore(end)) {
            quoteIncome += amount;
            final key = DateFormat('yyyy-MM-dd').format(date);
            dayTotals[key] = (dayTotals[key] ?? 0.0) + amount;
          }
        }

        // 2. Process Work Orders
        for (var data in workDocs) {
          final status = (data['status'] ?? 'pending_approval')
              .toString()
              .toLowerCase();
          final amount =
              (data['netEarnings'] as num?)?.toDouble() ??
              (data['totalPrice'] as num?)?.toDouble() ??
              0.0;
          final date =
              (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now();

          if (status == 'completed' &&
              date.isAfter(start) &&
              date.isBefore(end)) {
            workIncome += amount;
            final key = DateFormat('yyyy-MM-dd').format(date);
            dayTotals[key] = (dayTotals[key] ?? 0.0) + amount;
          }
        }

        // 3. Process Expenses
        for (var data in expenseDocs) {
          final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
          final date = (data['date'] as Timestamp?)?.toDate() ?? DateTime.now();
          final category = (data['category'] ?? '').toString();

          if (date.isAfter(start) && date.isBefore(end)) {
            if (category == 'Maintenance') {
              maintenance += amount;
            } else if (category == 'Fuel') {
              fuel += amount;
            } else {
              otherExpenses += amount;
            }
          }
        }

        final totalIncome = quoteIncome + workIncome;
        final partnerComm =
            workIncome *
            0.15; // 15% Partner Commission only on Direct Work Income
        final totalExp = maintenance + fuel + otherExpenses + partnerComm;

        // Build 7-day chart data
        final List<ChartDataPoint> growthPoints = [];
        for (int i = 6; i >= 0; i--) {
          final d = DateTime.now().subtract(Duration(days: i));
          final key = DateFormat('yyyy-MM-dd').format(d);
          growthPoints.add(ChartDataPoint(d, dayTotals[key] ?? 0.0));
        }

        return OperatorEarningsReport(
          quotationIncome: quoteIncome,
          directWorkIncome: workIncome,
          maintenanceExpenses: maintenance,
          fuelExpenses: fuel,
          totalExpenses: totalExp,
          partnerCommission: partnerComm,
          netProfit: totalIncome - totalExp,
          weeklyGrowth: growthPoints,
        );
      });
    });
  }
}

final financeRepositoryProvider = Provider((ref) => FinanceRepository());

final financialSummaryProvider = StreamProvider<FinancialSummary>((ref) {
  return ref.watch(financeRepositoryProvider).getFinancialSummaryStream();
});

final allExpensesProvider = StreamProvider<List<ExpenseModel>>((ref) {
  return ref.watch(financeRepositoryProvider).getAllExpensesStream();
});

final recentExpensesProvider = StreamProvider.family<List<ExpenseModel>, int>((
  ref,
  limit,
) {
  return ref.watch(financeRepositoryProvider).getRecentExpensesStream(limit);
});

final operatorStatsProvider = StreamProvider.family<OperatorStats, String>((
  ref,
  uid,
) {
  return ref.watch(financeRepositoryProvider).getOperatorStatsStream(uid);
});

final operatorRecentActivityProvider =
    StreamProvider.family<List<dynamic>, String>((ref, uid) {
      return ref
          .watch(financeRepositoryProvider)
          .getOperatorRecentActivity(uid);
    });

final operatorDetailedReportProvider =
    StreamProvider.family<
      OperatorEarningsReport,
      ({String uid, DateTime start, DateTime end})
    >((ref, arg) {
      return ref
          .watch(financeRepositoryProvider)
          .getOperatorDetailedReport(arg.uid, arg.start, arg.end);
    });
