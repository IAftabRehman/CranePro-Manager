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
    final currencyFormatter = NumberFormat.currency(symbol: 'AED ', decimalDigits: 2);

    return summaryAsync.when(
      data: (summary) => RefreshIndicator(
        onRefresh: () async => ref.refresh(financialSummaryProvider),
        color: AppTheme.accentGold,
        backgroundColor: AppTheme.primaryNavy,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildTopAnalyticsCards(summary, currencyFormatter),
                  const SizedBox(height: 48),
                  _buildExpenditureSection(context, summary),
                  const SizedBox(height: 48),
                  _buildRecentTransactionsSection(ref),
                  const SizedBox(height: 48),
                ]),
              ),
            ),
          ],
        ),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.accentGold),
      ),
      error: (err, stack) => Center(
        child: Text(
          'Error loading analytics: $err',
          style: const TextStyle(color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _buildTopAnalyticsCards(FinancialSummary summary, NumberFormat formatter) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _build3DFinancialCard(
                'TOTAL REVENUE',
                formatter.format(summary.totalRevenue).replaceFirst('AED ', ''),
                Icons.account_balance_wallet_rounded,
                null,
                AppTheme.lavenderPrimary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _build3DFinancialCard(
                'OPERATIONAL COST',
                formatter.format(summary.totalExpenses).replaceFirst('AED ', ''),
                Icons.speed_rounded,
                null,
                const Color(0xFFFF5252), // Vibrant Red
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _build3DFinancialCard(
          'NET BUSINESS PROFIT',
          formatter.format(summary.netProfit).replaceFirst('AED ', ''),
          Icons.trending_up_rounded,
          18.0,
          summary.netProfit >= 0 ? Colors.greenAccent : Colors.redAccent,
          isMain: true,
        ),
      ],
    );
  }

  Widget _build3DFinancialCard(
    String title,
    String amount,
    IconData icon,
    double? fontSize,
    Color color, {
    double offsetY = 0,
    bool isMain = false,
  }) {
    return Transform(
      transform: Matrix4.translationValues(0, offsetY, 0)..setEntry(3, 2, 0.002),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: AppTheme.lavenderBlueGradient,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
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

  Widget _buildExpenditureSection(BuildContext context, FinancialSummary summary) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'EXPENSE BREAKDOWN',
          style: TextStyle(
            color: AppTheme.lavenderPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: summary.totalExpenses == 0 
              ? const SizedBox(
                  height: 100,
                  child: Center(child: Text('No expenses recorded yet', style: TextStyle(color: Colors.white60)))
                )
              : isSmallScreen
                  ? Column(
                      children: [
                        SizedBox(height: 180, child: _buildPieChart(summary)),
                        const SizedBox(height: 32),
                        _buildExpenseIndicators(summary),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: SizedBox(height: 200, child: _buildPieChart(summary)),
                        ),
                        const SizedBox(width: 24),
                        Expanded(flex: 5, child: _buildExpenseIndicators(summary)),
                      ],
                    ),
        ),
      ],
    );
  }

  Widget _buildPieChart(FinancialSummary summary) {
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
        radius: 45,
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

  Widget _buildExpenseIndicators(FinancialSummary summary) {
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
            _buildExpenseIndicator(entry.key, percentage, color),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildExpenseIndicator(String label, double percent, Color color) {
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
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactionsSection(WidgetRef ref) {
    final expensesAsync = ref.watch(allExpensesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FINANCIAL ACTIVITY LOGS',
          style: TextStyle(
            color: AppTheme.lavenderPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        expensesAsync.when(
          data: (expenses) {
            if (expenses.isEmpty) {
              return const Center(child: Text('No transactions yet', style: TextStyle(color: Colors.white60)));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: expenses.length > 10 ? 10 : expenses.length,
              itemBuilder: (context, index) => _buildTransactionTile(expenses[index]),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentGold)),
          error: (err, _) => Text('Error loading transactions: $err', style: const TextStyle(color: Colors.redAccent)),
        ),
      ],
    );
  }

  Widget _buildTransactionTile(dynamic expense) {
    final dateStr = DateFormat('dd MMM, yyyy').format(expense.date);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
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
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.5),
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
