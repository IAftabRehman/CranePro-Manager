import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../quotation/data/models/quotation_model.dart';
import '../../../quotation/data/repositories/quotation_repository.dart';
import '../../../finance/data/models/expense_model.dart';
import '../../../finance/data/repositories/finance_repository.dart';

final reportSearchQueryProvider = StateProvider<String>((ref) => '');

final reportDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

final reportStatusFilterProvider = StateProvider<String>((ref) => 'All');

final filteredQuotationsProvider = Provider<AsyncValue<List<QuotationModel>>>((ref) {
  final quotationsAsync = ref.watch(allQuotationsProvider);
  final query = ref.watch(reportSearchQueryProvider).toLowerCase();
  final dateRange = ref.watch(reportDateRangeProvider);
  final status = ref.watch(reportStatusFilterProvider);

  return quotationsAsync.whenData((list) {
    return list.where((q) {
      // 1. Search Query (Client Name or Service Type/Crane Number)
      final matchesQuery = q.clientName.toLowerCase().contains(query) ||
          q.serviceType.toLowerCase().contains(query);

      // 2. Date Range
      bool matchesDate = true;
      if (dateRange != null) {
        matchesDate = q.workDate.isAfter(dateRange.start.subtract(const Duration(seconds: 1))) &&
            q.workDate.isBefore(dateRange.end.add(const Duration(days: 1)));
      }

      // 3. Status Filter
      bool matchesStatus = true;
      if (status != 'All') {
        matchesStatus = q.status.toLowerCase() == status.toLowerCase();
      }

      return matchesQuery && matchesDate && matchesStatus;
    }).toList();
  });
});

final filteredExpensesProvider = Provider<AsyncValue<List<ExpenseModel>>>((ref) {
  final expensesAsync = ref.watch(allExpensesProvider);
  final query = ref.watch(reportSearchQueryProvider).toLowerCase();
  final dateRange = ref.watch(reportDateRangeProvider);

  return expensesAsync.whenData((list) {
    return list.where((e) {
      // 1. Search Query (Category or Description)
      final matchesQuery = e.category.toLowerCase().contains(query) ||
          e.description.toLowerCase().contains(query);

      // 2. Date Range
      bool matchesDate = true;
      if (dateRange != null) {
        matchesDate = e.date.isAfter(dateRange.start.subtract(const Duration(seconds: 1))) &&
            e.date.isBefore(dateRange.end.add(const Duration(days: 1)));
      }

      return matchesQuery && matchesDate;
    }).toList();
  });
});
