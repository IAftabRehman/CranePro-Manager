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

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                        ],
                      ),
                    ),
                  ),
                  if (maintenanceExpenses.isEmpty)
                    const SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: Text(
                            'No maintenance logs found for this period',
                            style: TextStyle(
                              color: AppTheme.deepNavyBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final e = maintenanceExpenses[index];
                            final formattedDate = DateFormat('dd MMM yyyy').format(e.date);
                            return MaintenanceTile(
                              description: e.description.isNotEmpty ? e.description : e.category,
                              date: formattedDate,
                              amount: e.amount,
                            );
                          },
                          childCount: maintenanceExpenses.length,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 40),
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
}

class MaintenanceTile extends StatelessWidget {
  final String description;
  final String date;
  final double amount;

  const MaintenanceTile({
    super.key,
    required this.description,
    required this.date,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0x66FFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x4DFFFFFF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              color: Color(0x26FF9800),
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
                    color: const Color(0x990A1931),
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
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

