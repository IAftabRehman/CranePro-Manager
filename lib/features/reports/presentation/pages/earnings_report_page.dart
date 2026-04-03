import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';
import 'package:extend_crane_services/shared/global_widgets/premium_background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:extend_crane_services/features/auth/presentation/controllers/login_notifier.dart';
import 'package:extend_crane_services/features/finance/data/repositories/finance_repository.dart';

class EarningsReportPage extends ConsumerStatefulWidget {
  const EarningsReportPage({super.key});

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
    final theme = Theme.of(context);
    final isTablet = Responsive.isTablet(context);
    final screenWidth = Responsive.screenWidth(context);
    final userAsync = ref.watch(currentUserProvider);

    return PremiumScaffold(
      appBar: AppBar(
        title: const Text('Earnings & Analytics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: userAsync.when(
          data: (user) {
            if (user == null) return const Center(child: Text('User session not found.'));
            
            final reportAsync = ref.watch(operatorDetailedReportProvider((uid: user.id, start: _fromDate, end: _toDate)));

            return reportAsync.when(
              data: (report) => SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.scale(context, 16).clamp(16.0, 32.0),
                  vertical: 24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildDateRangeHeader(theme),
                        const SizedBox(height: 24),
                        _buildPieChartCard(theme, isTablet, report),
                        const SizedBox(height: 24),
                        _buildBarChartCard(theme, isTablet, report),
                        const SizedBox(height: 24),
                        _buildSummaryGrid(theme, screenWidth, report),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.amber)),
              error: (err, stack) => Center(child: Text('Error loading report: $err', style: const TextStyle(color: Colors.redAccent))),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Auth error: $err')),
        ),
      ),
    );
  }

  Widget _buildDateRangeHeader(ThemeData theme) {
    final dateStr = '${DateFormat('dd MMM').format(_fromDate)} - ${DateFormat('dd MMM').format(_toDate)}';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
          TextButton.icon(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Change'),
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.secondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartCard(ThemeData theme, bool isTablet, OperatorEarningsReport report) {
    final grossTotal = report.quotationIncome + report.directWorkIncome;
    final commissionPercent = grossTotal > 0 ? (report.partnerCommission / grossTotal) * 100 : 0.0;
    final netPercent = grossTotal > 0 ? (report.netProfit / grossTotal) * 100 : 100.0;

    final pieChart = AspectRatio(
      aspectRatio: 1,
      child: PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              value: netPercent,
              title: '${netPercent.toStringAsFixed(0)}%',
              radius: 50,
              color: theme.colorScheme.primary,
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              value: commissionPercent,
              title: '${commissionPercent.toStringAsFixed(0)}%',
              radius: 50,
              color: theme.colorScheme.secondary,
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
        _buildLegendItem('Net Profit', theme.colorScheme.primary, theme),
        const SizedBox(height: 12),
        _buildLegendItem('Commission Paid', theme.colorScheme.secondary, theme),
      ],
    );

    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Earnings Distribution', style: theme.textTheme.displayLarge?.copyWith(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildLegendItem(String label, Color color, ThemeData theme) {
    return Row(
      children: [
        Container(width: 16, height: 16, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 12),
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.white70)),
      ],
    );
  }

  Widget _buildBarChartCard(ThemeData theme, bool isTablet, OperatorEarningsReport report) {
    // Determine max Y for scaling
    double maxAmount = 100.0;
    for (var p in report.weeklyGrowth) {
      if (p.amount > maxAmount) maxAmount = p.amount;
    }

    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weekly Growth Analysis', style: theme.textTheme.displayLarge?.copyWith(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
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
                          if (val.toInt() < 0 || val.toInt() >= report.weeklyGrowth.length) return const SizedBox.shrink();
                          final date = report.weeklyGrowth[val.toInt()].date;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(DateFormat('E').format(date).substring(0, 1), 
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70)),
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
                    return _buildBarGroup(entry.key, entry.value.amount, theme.colorScheme.primary);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }

  Widget _buildSummaryGrid(ThemeData theme, double width, OperatorEarningsReport report) {
    final tiles = [
      _buildSummaryTile('Quotation Income', 'AED ${report.quotationIncome.toStringAsFixed(0)}', Colors.white, theme),
      _buildSummaryTile('Direct Work Income', 'AED ${report.directWorkIncome.toStringAsFixed(0)}', Colors.white, theme),
      const Divider(color: Colors.white10),
      _buildSummaryTile('Partner Commission', '(-) AED ${report.partnerCommission.toStringAsFixed(0)}', Colors.redAccent, theme),
      _buildSummaryTile('Fuel Expenses', '(-) AED ${report.fuelExpenses.toStringAsFixed(0)}', Colors.orangeAccent, theme),
      _buildSummaryTile('Maintenance Costs', '(-) AED ${report.maintenanceExpenses.toStringAsFixed(0)}', Colors.orangeAccent, theme),
      const Divider(color: Colors.white24, thickness: 1.5, height: 32),
      _buildSummaryTile('ESTIMATED NET PROFIT', 'AED ${report.netProfit.toStringAsFixed(0)}', Colors.green, theme, isBold: true, fontSize: 22),
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

    return Column(children: tiles.map((t) => Padding(padding: const EdgeInsets.only(bottom: 12), child: t)).toList());
  }

  Widget _buildSummaryTile(String label, String value, Color color, ThemeData theme, {bool isBold = false, double fontSize = 16}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
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

