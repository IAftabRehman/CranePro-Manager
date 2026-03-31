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
                  _buildRecentTransactionsSection(),
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
          // Use the requested lavenderBlueGradient as base
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
              ? const Center(child: Text('No expenses recorded yet', style: TextStyle(color: Colors.white60)))
              : isSmallScreen
                  ? Column(
                      children: [
                        SizedBox(height: 180, child: _buildPieChart()),
                        const SizedBox(height: 32),
                        _buildExpenseIndicators(),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: SizedBox(height: 200, child: _buildPieChart()),
                        ),
                        const SizedBox(width: 24),
                        Expanded(flex: 5, child: _buildExpenseIndicators()),
                      ],
                    ),
        ),
      ],
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sectionsSpace: 0,
        centerSpaceRadius: 35,
        sections: [
          PieChartSectionData(
            color: Colors.black,
            value: 45,
            title: '45%',
            radius: 45,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          PieChartSectionData(
            color: Colors.yellow,
            value: 30,
            title: '30%',
            radius: 45,
            titleStyle: const TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          PieChartSectionData(
            color: Colors.red.shade900,
            value: 25,
            title: '25%',
            radius: 45,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseIndicators() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildExpenseIndicator('Fuel Costs', 45, Colors.black),
        const SizedBox(height: 16),
        _buildExpenseIndicator('Maintenance', 30, Colors.yellow),
        const SizedBox(height: 16),
        _buildExpenseIndicator('Partners', 25, Colors.red),
      ],
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
              '$percent%',
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

  Widget _buildRecentTransactionsSection() {
    final transactions = [
      {
        'client': 'Mock Realtime Sync',
        'date': 'Status: Ready',
        'profit': '0',
        'type': 'Reactive',
      },
    ];

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
        ...transactions.map((tx) => _buildTransactionTile(tx)),
      ],
    );
  }

  Widget _buildTransactionTile(Map<String, String> tx) {
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
                  tx['client']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                Text(
                  tx['date']!,
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
                    tx['profit']!,
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
                tx['type']!,
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
