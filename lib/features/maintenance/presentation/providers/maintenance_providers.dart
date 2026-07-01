import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/finance/data/models/expense_model.dart';
import '../../../../features/finance/data/repositories/finance_repository.dart';

/// Shows all maintenance entries (no uid filter — single-operator private app).
final operatorMaintenanceProvider = StreamProvider<List<ExpenseModel>>((ref) {
  return ref.watch(financeRepositoryProvider)
      .getRawExpensesStream()
      .map((allEntries) {
        final operatorEntries = allEntries.where((e) => e.category == 'Maintenance').toList();
        operatorEntries.sort((a, b) => b.date.compareTo(a.date));
        return operatorEntries;
      });
});

/// Provider for ALL maintenance entries (Admin view).
final allMaintenanceProvider = StreamProvider<List<ExpenseModel>>((ref) {
  return ref.watch(financeRepositoryProvider)
      .getRawExpensesStream()
      .map((allEntries) {
        final maintenanceEntries = allEntries.where((e) => e.category == 'Maintenance').toList();
        maintenanceEntries.sort((a, b) => b.date.compareTo(a.date));
        return maintenanceEntries;
      });
});

/// Provider for calculating the monthly total of maintenance expenses for the operator.
final operatorMonthlyMaintenanceTotalProvider = Provider<double>((ref) {
  final entries = ref.watch(operatorMaintenanceProvider).value ?? [];
  final now = DateTime.now();
  
  return entries
      .where((e) => e.date.year == now.year && e.date.month == now.month)
      .fold(0.0, (sum, item) => sum + item.amount);
});
