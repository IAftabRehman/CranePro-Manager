import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';
import 'package:extend_crane_services/shared/global_widgets/premium_background.dart';

enum ExpenseFilter { week, month, year, custom }

class ExpenseAnalysisPage extends StatefulWidget {
  const ExpenseAnalysisPage({super.key});

  @override
  State<ExpenseAnalysisPage> createState() => _ExpenseAnalysisPageState();
}

class _ExpenseAnalysisPageState extends State<ExpenseAnalysisPage> {
  ExpenseFilter _selectedFilter = ExpenseFilter.month;

  final Map<String, double> _categoryData = {
    'Fuel': 45.0,
    'Maintenance': 25.0,
    'Salaries': 20.0,
    'Others': 10.0,
  };

  final Map<String, Color> _categoryColors = {
    'Fuel': Colors.blueAccent,
    'Maintenance': Colors.orangeAccent,
    'Salaries': Colors.greenAccent,
    'Others': Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = Responsive.isTablet(context);
    final screenWidth = Responsive.screenWidth(context);
    final screenHeight = Responsive.screenHeight(context);

    return PremiumScaffold(
      appBar: AppBar(
        title: const Text('Expense Analysis', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                   // Filter Chips
                  _buildFilterChips(theme),
                  SizedBox(height: screenHeight * 0.03),

                  // Donut Chart Card
                  _buildDonutChartCard(theme, isTablet, screenWidth),
                  SizedBox(height: screenHeight * 0.03),

                  // Trend Line Chart Card
                  _buildTrendLineCard(theme, isTablet, screenHeight),
                  SizedBox(height: screenHeight * 0.03),

                  // Categorized List Breakdown
                  _buildCategorizedBreakdown(theme, isTablet),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ExpenseFilter.values.map((filter) {
        final isSelected = _selectedFilter == filter;
        return ChoiceChip(
          label: Text(
            filter.name[0].toUpperCase() + filter.name.substring(1),
            style: TextStyle(
              color: isSelected ? Colors.white : theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) setState(() => _selectedFilter = filter);
          },
          selectedColor: theme.colorScheme.secondary,
          backgroundColor: Colors.white.withValues(alpha: 0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? theme.colorScheme.secondary : Colors.white12,
            ),
          ),
          showCheckmark: false,
        );
      }).toList(),
    );
  }

  Widget _buildDonutChartCard(ThemeData theme, bool isTablet, double width) {
    final donutRadius = isTablet ? width * 0.15 : width * 0.25;
    
    final donutChart = AspectRatio(
      aspectRatio: 1,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: donutRadius / 2,
          sections: _categoryData.entries.map((entry) {
            return PieChartSectionData(
              color: _categoryColors[entry.key],
              value: entry.value,
              title: '${entry.value.toInt()}%',
              radius: donutRadius / 2,
              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            );
          }).toList(),
        ),
      ),
    );

    final legend = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _categoryData.keys.map((cat) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: _categoryColors[cat], shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Text(cat, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.white70)),
            ],
          ),
        );
      }).toList(),
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
            Text('Expense Breakdown', style: theme.textTheme.displayLarge?.copyWith(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            isTablet
                ? Row(
                    children: [
                      Expanded(flex: 2, child: donutChart),
                      const SizedBox(width: 48),
                      Expanded(flex: 3, child: legend),
                    ],
                  )
                : Column(
                    children: [
                      SizedBox(height: 200, child: donutChart),
                      const SizedBox(height: 24),
                      legend,
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendLineCard(ThemeData theme, bool isTablet, double screenHeight) {
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
            Text('Expense Trends', style: theme.textTheme.displayLarge?.copyWith(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            AspectRatio(
              aspectRatio: isTablet ? 2.5 : 1.7,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (val, meta) => Text(
                          val.toInt().toString(),
                          style: const TextStyle(color: Colors.white38, fontSize: 10),
                        ),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 30),
                        FlSpot(2.6, 20),
                        FlSpot(4.9, 50),
                        FlSpot(6.8, 31),
                        FlSpot(8, 40),
                        FlSpot(9.5, 30),
                        FlSpot(11, 70),
                      ],
                      isCurved: true,
                      color: theme.colorScheme.secondary,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.3),
                            theme.colorScheme.primary.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (spot) => theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorizedBreakdown(ThemeData theme, bool isTablet) {
    final categories = _categoryData.keys.toList();
    
    Widget buildItem(String cat) {
      final percentage = _categoryData[cat]! / 100;
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(cat, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                Text('${(percentage * 100).toInt()}%', style: TextStyle(color: _categoryColors[cat], fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                color: _categoryColors[cat],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Budget Consumption', style: theme.textTheme.displayLarge?.copyWith(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        isTablet
            ? GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 32,
                  mainAxisExtent: 80,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) => buildItem(categories[index]),
              )
            : Column(
                children: categories.map((cat) => buildItem(cat)).toList(),
              ),
      ],
    );
  }
}

