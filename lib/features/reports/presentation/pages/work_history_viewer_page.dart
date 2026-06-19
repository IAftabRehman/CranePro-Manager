import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/features/reports/presentation/widgets/viewer_report_header.dart';
import 'package:extend_crane_services/features/reports/presentation/pages/work_entry_details_page.dart';
import 'package:extend_crane_services/features/quotation/data/repositories/quotation_repository.dart';
import 'package:intl/intl.dart';

class WorkHistoryViewerPage extends ConsumerStatefulWidget {
  const WorkHistoryViewerPage({super.key});

  @override
  ConsumerState<WorkHistoryViewerPage> createState() => _WorkHistoryViewerPageState();
}

class _WorkHistoryViewerPageState extends ConsumerState<WorkHistoryViewerPage> {
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 7));
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
    final quotationsAsync = ref.watch(allQuotationsProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent.shade200,
        elevation: 5,
        shadowColor: Colors.blue,
        title: const Text(
          "Work Report",
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
          child: quotationsAsync.when(
            data: (quotations) {
              // Filter completed quotations within date range
              final completedQuotations = quotations.where((q) {
                final isCompleted = q.status.toLowerCase() == 'completed';
                final matchesDate = q.workDate.isAfter(_fromDate.subtract(const Duration(seconds: 1))) &&
                    q.workDate.isBefore(_toDate.add(const Duration(days: 1)));
                return isCompleted && matchesDate;
              }).toList();

              // Calculate total profit dynamically
              double totalProfit = 0.0;
              for (final q in completedQuotations) {
                final isOwnCrane = !q.serviceType.toLowerCase().contains('commission') &&
                    !q.serviceType.toLowerCase().contains('outsourced') &&
                    !q.serviceType.toLowerCase().contains('partner');
                final deduction = isOwnCrane ? q.totalAmount * 0.10 : q.totalAmount * 0.85;
                totalProfit += (q.totalAmount - deduction);
              }

              final currencyFormatter = NumberFormat.currency(symbol: 'AED ', decimalDigits: 0);

              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      children: [
                        ViewerReportHeader(
                          title: 'Work History',
                          summaryLabel: 'Total Profit for',
                          summaryValue: currencyFormatter.format(totalProfit),
                          fromDate: _fromDate,
                          toDate: _toDate,
                          onSelectDateRange: _selectDateRange,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Detailed Transactions',
                          style: TextStyle(
                            color: AppTheme.deepNavyBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        if (completedQuotations.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text(
                                'No completed jobs found for this period',
                                style: TextStyle(color: AppTheme.deepNavyBlue, fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                          )
                        else
                          ...completedQuotations.map((q) {
                            final isOwnCrane = !q.serviceType.toLowerCase().contains('commission') &&
                                !q.serviceType.toLowerCase().contains('outsourced') &&
                                !q.serviceType.toLowerCase().contains('partner');
                            final deduction = isOwnCrane ? q.totalAmount * 0.10 : q.totalAmount * 0.85;
                            final deductionLabel = isOwnCrane ? 'Fuel Cost' : 'Outsourced Cost';

                            return _buildHistoryCard(
                              context,
                              isOwnCrane: isOwnCrane,
                              client: q.clientName,
                              location: q.siteLocation,
                              total: q.totalAmount,
                              deduction: deduction,
                              deductionLabel: deductionLabel,
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

  Widget _buildHistoryCard(
    BuildContext context, {
    required bool isOwnCrane,
    required String client,
    required String location,
    required double total,
    required double deduction,
    required String deductionLabel,
  }) {
    final net = total - deduction;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WorkEntryDetailsPage(
                  isOwnCrane: isOwnCrane,
                  client: client,
                  location: location,
                  total: total,
                  deduction: deduction,
                  deductionLabel: deductionLabel,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.deepNavyBlue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isOwnCrane ? Icons.person : Icons.handshake,
                        color: AppTheme.deepNavyBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            client.toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.deepNavyBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            location,
                            style: TextStyle(
                              color: AppTheme.deepNavyBlue.withValues(alpha: 0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppTheme.deepNavyBlue),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: Colors.white, thickness: 1),
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCalculationCol(isOwnCrane ? 'Gross Total' : 'Total Quotation', 'AED ${total.toStringAsFixed(0)}'),
                        _buildCalculationCol(deductionLabel, '(-) AED ${deduction.toStringAsFixed(0)}', isDeduction: true),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Divider(color: Colors.yellow, thickness: 0.5),
                    ),

                    _buildCalculationCol(isOwnCrane ? 'Total PROFIT' : 'Total COMMISSION', 'AED ${net.toStringAsFixed(0)}', isNet: true),
                  ],
                )

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalculationCol(String label, String value, {bool isDeduction = false, bool isNet = false}) {
    Color valColor = AppTheme.deepNavyBlue;
    if (isDeduction) valColor = Colors.orange.shade900;
    if (isNet) valColor = Colors.green.shade900;
    
    return Column(
      crossAxisAlignment: isNet ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: AppTheme.deepNavyBlue.withValues(alpha: 0.6),
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valColor,
            fontSize: isNet ? 18 : 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

