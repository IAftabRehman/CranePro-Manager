import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/features/finance/data/repositories/finance_repository.dart';

class AdminFinancialDashboard extends ConsumerWidget {
  const AdminFinancialDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(financialSummaryProvider);

    return summaryAsync.when(
      data: (summary) => RefreshIndicator(
        onRefresh: () async => ref.refresh(financialSummaryProvider),
        color: AppTheme.accentGold,
        backgroundColor: AppTheme.primaryNavy,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: isWide ? 40 : 10, vertical: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Extracted analytics cards section
                              TopAnalyticsCardsSection(summary: summary, isWide: isWide),
                              const SizedBox(height: 24),
                              if (isWide)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: ExpenseBreakdownSection(summary: summary),
                                    ),
                                    const SizedBox(width: 32),
                                    const Expanded(
                                      flex: 5,
                                      child: RecentTransactionsSection(),
                                    ),
                                  ],
                                )
                              else ...[
                                // Extracted expenditure breakdown section
                                ExpenseBreakdownSection(summary: summary),
                                const SizedBox(height: 20),
                                // Extracted financial activity log section which watches its own providers
                                const RecentTransactionsSection(),
                              ],
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            );
          }
        ),
      ),
      loading: () => const Center(
        child: RepaintBoundary(child: CircularProgressIndicator(color: AppTheme.accentGold)),
      ),
      error: (err, stack) => Center(
        child: Text(
          'Error loading analytics: $err',
          style: const TextStyle(color: Colors.redAccent),
        ),
      ),
    );
  }
}

// Extracted widget for the 3D-effect top analytic summary cards
class TopAnalyticsCardsSection extends StatelessWidget {
  final FinancialSummary summary;
  final bool isWide;

  const TopAnalyticsCardsSection({
    super.key,
    required this.summary,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: 'AED ', decimalDigits: 2);
    final revenueText = formatter.format(summary.totalRevenue).replaceFirst('AED ', '');
    final expenseText = formatter.format(summary.totalExpenses).replaceFirst('AED ', '');
    final profitText = formatter.format(summary.netProfit).replaceFirst('AED ', '');
    final profitColor = summary.netProfit >= 0 ? Colors.greenAccent : Colors.redAccent;

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: FinancialCard(
              title: 'Total Revenue',
              amount: revenueText,
              icon: Icons.account_balance_wallet_rounded,
              color: AppTheme.lavenderPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FinancialCard(
              title: 'Operational Cost',
              amount: expenseText,
              icon: Icons.speed_rounded,
              color: const Color(0xFFFF5252),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FinancialCard(
              title: 'NET BUSINESS PROFIT',
              amount: profitText,
              icon: Icons.trending_up_rounded,
              color: profitColor,
              isMain: true,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: FinancialCard(
                title: 'Total Revenue',
                amount: revenueText,
                icon: Icons.account_balance_wallet_rounded,
                color: AppTheme.lavenderPrimary,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: FinancialCard(
                title: 'Operational Cost',
                amount: expenseText,
                icon: Icons.speed_rounded,
                color: const Color(0xFFFF5252),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        FinancialCard(
          title: 'NET BUSINESS PROFIT',
          amount: profitText,
          icon: Icons.trending_up_rounded,
          color: profitColor,
          isMain: true,
          fontSize: 18.0,
        ),
      ],
    );
  }
}

// Optimized FinancialCard component with const constructor
class FinancialCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final double? fontSize;
  final Color color;
  final double offsetY;
  final bool isMain;

  const FinancialCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    this.fontSize,
    this.offsetY = 0,
    this.isMain = false,
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.translationValues(0, offsetY, 0)..setEntry(3, 2, 0.002),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: AppTheme.lavenderBlueGradient,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0x66FFFFFF)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 30,
              offset: Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: const Color(0xCCFFFFFF),
                fontSize: fontSize ?? 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  amount,
                  style: TextStyle(
                    color: color,
                    fontSize: isMain ? 28 : 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'AED',
                    style: TextStyle(
                      color: color.withValues(alpha: 0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Extracted Expense breakdown card segment
class ExpenseBreakdownSection extends StatelessWidget {
  final FinancialSummary summary;

  const ExpenseBreakdownSection({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Expense Breakdown',
          style: TextStyle(
            color: AppTheme.lavenderPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0x0DFFFFFF),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0x4DFFFFFF)),
          ),
          child: summary.totalExpenses == 0
              ? const SizedBox(
                  height: 100,
                  child: Center(
                    child: Text(
                      'No expenses recorded yet',
                      style: TextStyle(color: Colors.white60),
                    ),
                  ),
                )
              : isSmallScreen
                  ? Column(
                      children: [
                        SizedBox(height: 100, child: _PieChart(summary: summary)),
                        const SizedBox(height: 32),
                        _ExpenseIndicators(summary: summary),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 4,
                          child: AspectRatio(
                            aspectRatio: 1.2,
                            child: _PieChart(summary: summary),
                          ),
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          flex: 5,
                          child: _ExpenseIndicators(summary: summary),
                        ),
                      ],
                    ),
        ),
      ],
    );
  }
}

// Isolated Pie chart to avoid layout shifts and optimize drawing
class _PieChart extends StatelessWidget {
  final FinancialSummary summary;

  const _PieChart({required this.summary});

  @override
  Widget build(BuildContext context) {
    final List<Color> palette = [
      Colors.amber,
      Colors.lightBlueAccent,
      Colors.redAccent,
      Colors.greenAccent,
      Colors.purpleAccent
    ];

    int index = 0;
    final sections = summary.categoryBreakdown.entries.map((entry) {
      final color = palette[index % palette.length];
      final percentage = (entry.value / summary.totalExpenses) * 100;
      index++;

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 30,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sectionsSpace: 0,
        centerSpaceRadius: 35,
        sections: sections,
      ),
    );
  }
}

// Extracted indicators container
class _ExpenseIndicators extends StatelessWidget {
  final FinancialSummary summary;

  const _ExpenseIndicators({required this.summary});

  @override
  Widget build(BuildContext context) {
    final List<Color> palette = [
      Colors.amber,
      Colors.lightBlueAccent,
      Colors.redAccent,
      Colors.greenAccent,
      Colors.purpleAccent
    ];

    int index = 0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: summary.categoryBreakdown.entries.map((entry) {
        final color = palette[index % palette.length];
        final percentage = (entry.value / summary.totalExpenses) * 100;
        index++;
        return Column(
          children: [
            _ExpenseIndicatorTile(
              label: entry.key,
              percent: percentage,
              color: color,
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }
}

// Isolated single progress indicator tile to prevent rebuild cascading
class _ExpenseIndicatorTile extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;

  const _ExpenseIndicatorTile({
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Text(
              '${percent.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent / 100,
            backgroundColor: const Color(0x1AFFFFFF),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

// Riverpod Optimized: watches the transaction list independently. 
// When transactional states alter, the rest of the financial dashboard is skipped from rebuilds.
class RecentTransactionsSection extends ConsumerWidget {
  const RecentTransactionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(recentExpensesProvider(10));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Financial Activity Logs',
          style: TextStyle(
            color: AppTheme.lavenderPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        expensesAsync.when(
          data: (expenses) {
            if (expenses.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'No transactions yet',
                    style: TextStyle(color: Colors.white60),
                  ),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: expenses.length > 10 ? 10 : expenses.length,
              itemBuilder: (context, index) => TransactionTile(expense: expenses[index]),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: RepaintBoundary(child: CircularProgressIndicator(color: AppTheme.accentGold)),
            ),
          ),
          error: (err, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Error loading transactions: $err',
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }
}

// Extracted widget representing each single transaction tile
class TransactionTile extends StatelessWidget {
  final dynamic expense;

  const TransactionTile({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM, yyyy').format(expense.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0x1AFFFFFF),
            child: Icon(
              Icons.receipt_long_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description.isEmpty ? expense.category : expense.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Color(0x80FFFFFF),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    expense.amount.toStringAsFixed(0),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text(
                      'AED',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        color: Colors.white60,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                expense.category.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  color: Colors.greenAccent,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
