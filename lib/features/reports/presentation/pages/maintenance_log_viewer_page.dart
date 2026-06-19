import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/features/reports/presentation/widgets/viewer_report_header.dart';
import 'package:extend_crane_services/features/finance/data/repositories/finance_repository.dart';
import 'package:intl/intl.dart';

class MaintenanceLogViewerPage extends ConsumerStatefulWidget {
  const MaintenanceLogViewerPage({super.key});

  @override
  ConsumerState<MaintenanceLogViewerPage> createState() => _MaintenanceLogViewerPageState();
}

class _MaintenanceLogViewerPageState extends ConsumerState<MaintenanceLogViewerPage> {
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.deepNavyBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.deepNavyBlue,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(allExpensesProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent.shade200,
        elevation: 5,
        shadowColor: Colors.blue,
        title: const Text(
          "Maintenance",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.lavenderBlueGradient,
        ),
        child: SafeArea(
          child: expensesAsync.when(
            data: (expenses) {
              // Filter maintenance expenses within date range
              final maintenanceExpenses = expenses.where((e) {
                final isMaintenance = e.category.toLowerCase() == 'maintenance';
                final matchesDate = e.date.isAfter(_fromDate.subtract(const Duration(seconds: 1))) &&
                    e.date.isBefore(_toDate.add(const Duration(days: 1)));
                return isMaintenance && matchesDate;
              }).toList();

              // Calculate total maintenance cost dynamically
              final totalMaintenance = maintenanceExpenses.fold<double>(0.0, (sum, item) => sum + item.amount);
              final currencyFormatter = NumberFormat.currency(symbol: 'AED ', decimalDigits: 0);

              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      children: [
                        ViewerReportHeader(
                          title: 'Maintenance Log',
                          summaryLabel: 'Total Maintenance',
                          summaryValue: currencyFormatter.format(totalMaintenance),
                          fromDate: _fromDate,
                          toDate: _toDate,
                          onSelectDateRange: _selectDateRange,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Repair & Service History',
                          style: TextStyle(
                            color: AppTheme.deepNavyBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        if (maintenanceExpenses.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text(
                                'No maintenance logs found for this period',
                                style: TextStyle(color: AppTheme.deepNavyBlue, fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                          )
                        else
                          ...maintenanceExpenses.map((e) {
                            final formattedDate = DateFormat('dd MMM yyyy').format(e.date);
                            return _buildMaintenanceTile(
                              e.description.isNotEmpty ? e.description : e.category,
                              formattedDate,
                              e.amount,
                            );
                          }),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: Colors.amber)),
            error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
          ),
        ),
      ),
    );
  }

  Widget _buildMaintenanceTile(String description, String date, double amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.build_circle_rounded, color: Colors.orange.shade900, size: 24),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    color: AppTheme.deepNavyBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    color: AppTheme.deepNavyBlue.withValues(alpha: 0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'AED ${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              color: AppTheme.deepNavyBlue,
              fontSize: 15, // TASK 4: Big Font Size
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

