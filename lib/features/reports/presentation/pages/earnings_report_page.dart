import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';
import 'package:extend_crane_services/shared/global_widgets/premium_background.dart';

class EarningsReportPage extends StatefulWidget {
  const EarningsReportPage({super.key});

  @override
  State<EarningsReportPage> createState() => _EarningsReportPageState();
}

class _EarningsReportPageState extends State<EarningsReportPage> {
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

    return PremiumScaffold(
      appBar: AppBar(
        title: const Text('Earnings & Analytics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                  // Date Range Picker Header
                  _buildDateRangeHeader(theme),
                  const SizedBox(height: 24),

                  // Pie Chart Card
                  _buildPieChartCard(theme, isTablet),
                  const SizedBox(height: 24),

                  // Bar Chart Card
                  _buildBarChartCard(theme, isTablet),
                  const SizedBox(height: 24),

                  // Summary Tiles
                  _buildSummaryGrid(theme, screenWidth),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeHeader(ThemeData theme) {
    final dateStr = '${DateFormat('dd MMM').format(_fromDate)} - ${DateFormat('dd MMM').format(_toDate)}';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
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

  Widget _buildPieChartCard(ThemeData theme, bool isTablet) {
    final pieChart = AspectRatio(
      aspectRatio: 1,
      child: PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              value: 75,
              title: '75%',
              radius: 50,
              color: theme.colorScheme.primary,
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              value: 25,
              title: '25%',
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
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.05)),
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

  Widget _buildBarChartCard(ThemeData theme, bool isTablet) {
    return Card(
      elevation: 0,
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.05)),
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
                  maxY: 100,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                          return Text(days[val.toInt() % 7], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70));
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _buildBarGroup(0, 45, theme.colorScheme.primary),
                    _buildBarGroup(1, 75, theme.colorScheme.primary),
                    _buildBarGroup(2, 60, theme.colorScheme.primary),
                    _buildBarGroup(3, 90, theme.colorScheme.primary),
                    _buildBarGroup(4, 50, theme.colorScheme.primary),
                    _buildBarGroup(5, 40, theme.colorScheme.primary),
                    _buildBarGroup(6, 30, theme.colorScheme.primary),
                  ],
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

  Widget _buildSummaryGrid(ThemeData theme, double width) {
    final tiles = [
      _buildSummaryTile('Quotation Income', 'AED 35,000', Colors.white, theme),
      _buildSummaryTile('Direct Work Income', 'AED 10,000', Colors.white, theme),
      const Divider(color: Colors.white10),
      _buildSummaryTile('Partner Commission', '(-) AED 8,500', Colors.redAccent, theme),
      _buildSummaryTile('Fuel Expenses', '(-) AED 3,200', Colors.orangeAccent, theme),
      _buildSummaryTile('Maintenance Costs', '(-) AED 1,000', Colors.orangeAccent, theme),
      const Divider(color: Colors.white24, thickness: 1.5, height: 32),
      _buildSummaryTile('ESTIMATED NET PROFIT', 'AED 32,300', Colors.green, theme, isBold: true, fontSize: 22),
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
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
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
