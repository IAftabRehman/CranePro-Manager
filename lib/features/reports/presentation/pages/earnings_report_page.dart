import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';
import 'package:extend_crane_services/shared/global_widgets/premium_background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:extend_crane_services/features/finance/data/repositories/finance_repository.dart';

class EarningsReportPage extends ConsumerStatefulWidget {
  final bool isEmbedded;
  const EarningsReportPage({super.key, this.isEmbedded = false});

  @override
  ConsumerState<EarningsReportPage> createState() => _EarningsReportPageState();
}

class _EarningsReportPageState extends ConsumerState<EarningsReportPage> {
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();

  Future<void> _selectDateRange() async {
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.secondary,
              onPrimary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      setState(() {
        _fromDate = pickedRange.start;
        _toDate = pickedRange.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
    final screenWidth = Responsive.screenWidth(context);
    // No Firebase Auth — fetch all records (single-operator private app)
    const String userId = '';

    return PremiumScaffold(
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              title: const Text(
                'Earnings & Analytics',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
      body: SafeArea(
          child: Consumer(
                builder: (context, ref, child) {
                  final reportAsync = ref.watch(
                    operatorDetailedReportProvider((uid: userId, start: _fromDate, end: _toDate)),
                  );

                  return reportAsync.when(
                    data: (report) => SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.scale(context, 16).clamp(16.0, 32.0),
                        vertical: 15,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1000),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Extracted Date Range Header component
                              EarningsDateRangeHeader(
                                fromDate: _fromDate,
                                toDate: _toDate,
                                onSelect: _selectDateRange,
                              ),
                              const SizedBox(height: 15),
                              
                              // Extracted Pie Chart Card
                              EarningsPieChartCard(
                                isTablet: isTablet,
                                report: report,
                              ),
                              const SizedBox(height: 15),
                              
                              // Extracted Bar Chart Card
                              EarningsBarChartCard(
                                isTablet: isTablet,
                                report: report,
                              ),
                              const SizedBox(height: 15),
                              
                              // Extracted Summary Grid
                              EarningsSummaryGrid(
                                width: screenWidth,
                                report: report,
                              ),
                              const SizedBox(height: 15),
                            ],
                          ),
                        ),
                      ),
                    ),
                    loading: () => const RepaintBoundary(
                      child: Center(child: CircularProgressIndicator(color: Colors.amber)),
                    ),
                    error: (err, stack) => Center(
                      child: Text(
                        'Error loading report: $err',
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

// Extracted date range header widget
class EarningsDateRangeHeader extends StatelessWidget {
  final DateTime fromDate;
  final DateTime toDate;
  final VoidCallback onSelect;

  const EarningsDateRangeHeader({
    super.key,
    required this.fromDate,
    required this.toDate,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = '${DateFormat('dd MMM').format(fromDate)} - ${DateFormat('dd MMM').format(toDate)}';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x80FFFFFF)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: theme.colorScheme.secondary, size: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Report Range', style: theme.textTheme.labelSmall?.copyWith(color: Colors.white60)),
                  Text(dateStr, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ],
          ),
          TextButton(
            onPressed: onSelect,
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.secondary),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}

// Extracted and optimized Pie Chart section card
class EarningsPieChartCard extends StatelessWidget {
  final bool isTablet;
  final OperatorEarningsReport report;

  const EarningsPieChartCard({
    super.key,
    required this.isTablet,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grossTotal = report.quotationIncome + report.directWorkIncome;
    final commissionPercent = grossTotal > 0 ? (report.partnerCommission / grossTotal) * 100 : 0.0;
    final maintenancePercent = grossTotal > 0 ? (report.maintenanceExpenses / grossTotal) * 100 : 0.0;
    
    // Calculate remainder for Net Profit to ensure they reflect proportion of gross
    final netPercent = grossTotal > 0 ? (report.netProfit / grossTotal) * 100 : 100.0;

    final pieChart = AspectRatio(
      aspectRatio: 1,
      child: PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 50,
          sections: [
            PieChartSectionData(
              value: netPercent,
              title: '${netPercent.toStringAsFixed(0)}%',
              radius: 50,
              color: Colors.green,
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              value: commissionPercent,
              title: '${commissionPercent.toStringAsFixed(0)}%',
              radius: 50,
              color: Colors.purple,
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              value: maintenancePercent,
              title: '${maintenancePercent.toStringAsFixed(0)}%',
              radius: 50,
              color: Colors.redAccent,
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );

    final legend = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LegendItem(label: 'Net Profit', color: Colors.green),
        const SizedBox(height: 12),
        _LegendItem(label: 'Commission Paid', color: Colors.purple),
        const SizedBox(height: 12),
        _LegendItem(label: 'Maintenance', color: Colors.redAccent),
      ],
    );

    return Card(
      elevation: 0,
      color: const Color(0x0DFFFFFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0x80FFFFFF)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Earnings Distribution',
              style: theme.textTheme.displayLarge?.copyWith(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            isTablet
                ? Row(
                    children: [
                      Expanded(flex: 2, child: pieChart),
                      const SizedBox(width: 48),
                      Expanded(flex: 3, child: legend),
                    ],
                  )
                : Column(
                    children: [
                      SizedBox(height: 200, child: pieChart),
                      const SizedBox(height: 32),
                      legend,
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

// Sub-component represent single legend tile with const constructor
class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

// Extracted and optimized Weekly Bar Chart Card
class EarningsBarChartCard extends StatelessWidget {
  final bool isTablet;
  final OperatorEarningsReport report;

  const EarningsBarChartCard({
    super.key,
    required this.isTablet,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double maxAmount = 100.0;
    for (var p in report.weeklyGrowth) {
      if (p.amount > maxAmount) maxAmount = p.amount;
    }

    return Card(
      color: const Color(0x0DFFFFFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0x80FFFFFF)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Growth Analysis',
              style: theme.textTheme.displayLarge?.copyWith(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            AspectRatio(
              aspectRatio: isTablet ? 2.5 : 1.7,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxAmount * 1.2, // Padding at top
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => Colors.black87,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          'AED ${rod.toY.toStringAsFixed(0)}',
                          const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          if (val.toInt() < 0 || val.toInt() >= report.weeklyGrowth.length) {
                            return const SizedBox.shrink();
                          }
                          final date = report.weeklyGrowth[val.toInt()].date;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('E').format(date).substring(0, 1),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: report.weeklyGrowth.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.amount,
                          color: Colors.green,
                          width: 16,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extracted Financial Summary Grid layout
class EarningsSummaryGrid extends StatelessWidget {
  final double width;
  final OperatorEarningsReport report;

  const EarningsSummaryGrid({
    super.key,
    required this.width,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final tiles = [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: EarningsSummaryTile(
              label: 'Quotation Income',
              value: 'AED ${report.quotationIncome.toStringAsFixed(0)}',
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: EarningsSummaryTile(
              label: 'Direct Work Income',
              value: 'AED ${report.directWorkIncome.toStringAsFixed(0)}',
              color: Colors.white,
            ),
          ),
        ],
      ),
      const Divider(color: Colors.white10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: EarningsSummaryTile(
              label: 'Partner Commission',
              value: '(-) AED ${report.partnerCommission.toStringAsFixed(0)}',
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: EarningsSummaryTile(
              label: 'Maintenance Costs',
              value: '(-) AED ${report.maintenanceExpenses.toStringAsFixed(0)}',
              color: Colors.orangeAccent,
            ),
          ),
        ],
      ),
      const Divider(color: Colors.white24, thickness: 1.5, height: 20),
      EarningsSummaryTile(
        label: 'Estimated Net Profit',
        value: 'AED ${report.netProfit.toStringAsFixed(0)}',
        color: Colors.green,
        isBold: true,
        fontSize: 22,
      ),
    ];

    if (width > 600) {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 2.5,
        children: tiles,
      );
    }

    return Column(
      children: tiles
          .map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: t,
              ))
          .toList(),
    );
  }
}

// Unified tile widget with const constructor
class EarningsSummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isBold;
  final double fontSize;

  const EarningsSummaryTile({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: theme.textTheme.displayLarge?.copyWith(
                color: color,
                fontSize: fontSize,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
