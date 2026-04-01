import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/controllers/login_notifier.dart';
import '../../../../features/finance/data/models/expense_model.dart';
import '../../../../features/finance/data/repositories/finance_repository.dart';

/// Provider for the maintenance entries of the current logged-in operator.
/// This uses 100% in-memory logic to avoid Firestore composite index requirements.
final operatorMaintenanceProvider = StreamProvider<List<ExpenseModel>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  
  return userAsync.when(
    data: (user) {
      if (user == null) return const Stream.empty();

      return ref.watch(financeRepositoryProvider)
          .getRawExpensesStream()
          .map((allEntries) {
            // Filter by Operator & Category in memory
            final operatorEntries = allEntries.where((e) => 
               e.operatorId == user.id && e.category == 'Maintenance'
            ).toList();
            
            // Sort by Date (Descending) in memory
            operatorEntries.sort((a, b) => b.date.compareTo(a.date));
            return operatorEntries;
          });
    },
    loading: () => const Stream.empty(),
    error: (err, stack) => Stream.error(err, stack),
  );
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
