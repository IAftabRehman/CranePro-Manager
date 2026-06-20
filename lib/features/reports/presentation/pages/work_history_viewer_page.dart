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
                if (q.commission > 0.0) {
                  totalProfit += q.commission;
                } else {
                  final isOwnCrane = !q.serviceType.toLowerCase().contains('commission') &&
                      !q.serviceType.toLowerCase().contains('outsourced') &&
                      !q.serviceType.toLowerCase().contains('partner');
                  final deduction = isOwnCrane ? q.totalAmount * 0.10 : q.totalAmount * 0.85;
                  totalProfit += (q.totalAmount - deduction);
                }
              }

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
                        ],
                      ),
                    ),
                  ),
                  if (completedQuotations.isEmpty)
                    const SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: Text(
                            'No completed jobs found for this period',
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
                            final q = completedQuotations[index];
                            final isOwnCrane = !q.serviceType.toLowerCase().contains('commission') &&
                                !q.serviceType.toLowerCase().contains('outsourced') &&
                                !q.serviceType.toLowerCase().contains('partner');
                            final deduction = q.commission > 0.0
                                ? (q.totalAmount - q.commission)
                                : (isOwnCrane ? q.totalAmount * 0.10 : q.totalAmount * 0.85);
                            final deductionLabel = isOwnCrane ? 'Fuel Cost' : 'Outsourced Cost';

                            return HistoryCard(
                              isOwnCrane: isOwnCrane,
                              client: q.clientName,
                              location: q.siteLocation,
                              total: q.totalAmount,
                              deduction: deduction,
                              deductionLabel: deductionLabel,
                            );
                          },
                          childCount: completedQuotations.length,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 40),
                  ),
                ],
              );
            },
            loading: () => const RepaintBoundary(
              child: Center(child: CircularProgressIndicator(color: Colors.amber)),
            ),
            error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
          ),
        ),
      ),
    );
  }
}

class HistoryCard extends StatelessWidget {
  final bool isOwnCrane;
  final String client;
  final String location;
  final double total;
  final double deduction;
  final String deductionLabel;

  const HistoryCard({
    super.key,
    required this.isOwnCrane,
    required this.client,
    required this.location,
    required this.total,
    required this.deduction,
    required this.deductionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final net = total - deduction;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: const BoxDecoration(
        color: Color(0x59FFFFFF),
        borderRadius: BorderRadius.all(Radius.circular(10)),
        border: Border(
          top: BorderSide(color: Color(0x66FFFFFF)),
          bottom: BorderSide(color: Color(0x66FFFFFF)),
          left: BorderSide(color: Color(0x66FFFFFF)),
          right: BorderSide(color: Color(0x66FFFFFF)),
        ),
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
                      decoration: const BoxDecoration(
                        color: Color(0x1A0A1931),
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
                            style: const TextStyle(
                              color: Color(0xB20A1931),
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
                        CalculationCol(
                          label: isOwnCrane ? 'Gross Total' : 'Total Quotation',
                          value: 'AED ${total.toStringAsFixed(0)}',
                        ),
                        CalculationCol(
                          label: deductionLabel,
                          value: '(-) AED ${deduction.toStringAsFixed(0)}',
                          isDeduction: true,
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Divider(color: Colors.yellow, thickness: 0.5),
                    ),
                    CalculationCol(
                      label: isOwnCrane ? 'Total PROFIT' : 'Total COMMISSION',
                      value: 'AED ${net.toStringAsFixed(0)}',
                      isNet: true,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CalculationCol extends StatelessWidget {
  final String label;
  final String value;
  final bool isDeduction;
  final bool isNet;

  const CalculationCol({
    super.key,
    required this.label,
    required this.value,
    this.isDeduction = false,
    this.isNet = false,
  });

  @override
  Widget build(BuildContext context) {
    Color valColor = AppTheme.deepNavyBlue;
    if (isDeduction) valColor = Colors.orange.shade900;
    if (isNet) valColor = Colors.green.shade900;

    return Column(
      crossAxisAlignment: isNet ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: const Color(0x990A1931),
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

