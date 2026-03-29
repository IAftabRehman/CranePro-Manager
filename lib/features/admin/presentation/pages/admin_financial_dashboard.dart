import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_button.dart';

class AdminFinancialDashboard extends StatelessWidget {
  const AdminFinancialDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.lavenderBlueGradient,
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeader(context),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 24),
                    _buildTopAnalyticsCards(),
                    const SizedBox(height: 48),
                    _buildExpenditureSection(),
                    const SizedBox(height: 48),
                    _buildRecentTransactionsSection(),
                    const SizedBox(height: 48),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.deepNavyBlue),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'FINANCIAL COMMAND CENTER',
        style: TextStyle(
          color: AppTheme.deepNavyBlue,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
        ),
      ),
      centerTitle: true,
      floating: true,
    );
  }

  Widget _buildTopAnalyticsCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _build3DFinancialCard(
                'TOTAL REVENUE',
                '450,000',
                Icons.account_balance_wallet_rounded,
                AppTheme.deepNavyBlue,
                offsetY: -10,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _build3DFinancialCard(
                'OPERATIONAL COST',
                '125,500',
                Icons.speed_rounded,
                Colors.amber.shade900,
                offsetY: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _build3DFinancialCard(
          'NET BUSINESS PROFIT',
          '324,500',
          Icons.trending_up_rounded,
          Colors.green.shade900,
          isMain: true,
        ),
      ],
    );
  }

  Widget _build3DFinancialCard(String title, String amount, IconData icon, Color color, {double offsetY = 0, bool isMain = false}) {
    return Transform(
      transform: Matrix4.translationValues(0, offsetY, 0)..setEntry(3, 2, 0.002),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
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
          crossAxisAlignment: isMain ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: isMain ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: isMain ? 32 : 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.deepNavyBlue.withValues(alpha: 0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: isMain ? MainAxisAlignment.center : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: TextStyle(
                    color: color,
                    fontSize: isMain ? 32 : 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'AED',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
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

  Widget _buildExpenditureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'EXPENSE BREAKDOWN',
          style: TextStyle(color: AppTheme.deepNavyBlue, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
        const SizedBox(height: 32),
        Container(
          height: 250,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(color: AppTheme.deepNavyBlue, value: 45, title: '45%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      PieChartSectionData(color: Colors.amber.shade700, value: 30, title: '30%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      PieChartSectionData(color: Colors.red.shade900, value: 25, title: '25%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildExpenseIndicator('Fuel Costs', 45, AppTheme.deepNavyBlue),
                    const SizedBox(height: 16),
                    _buildExpenseIndicator('Maintenance', 30, Colors.amber.shade700),
                    const SizedBox(height: 16),
                    _buildExpenseIndicator('Partners', 25, Colors.red.shade900),
                  ],
                ),
              ),
            ],
          ),
        ),
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
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.deepNavyBlue)),
            Text('$percent%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent / 100,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactionsSection() {
    final transactions = [
      {'client': 'Emaar Sites', 'date': '24 Mar 2024', 'profit': '12,500', 'type': 'High Value'},
      {'client': 'Binladin Group', 'date': '22 Mar 2024', 'profit': '8,200', 'type': 'Standard'},
      {'client': 'Al-Fajr Projects', 'date': '20 Mar 2024', 'profit': '15,000', 'type': 'High Value'},
      {'client': 'Dubai Metro', 'date': '18 Mar 2024', 'profit': '9,800', 'type': 'Standard'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RECENT HIGH-VALUE LOGS',
          style: TextStyle(color: AppTheme.deepNavyBlue, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5),
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
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.deepNavyBlue.withValues(alpha: 0.1),
            child: const Icon(Icons.receipt_long_rounded, color: AppTheme.deepNavyBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx['client']!, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.deepNavyBlue)),
                Text(tx['date']!, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.deepNavyBlue.withValues(alpha: 0.6))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(tx['profit']!, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.deepNavyBlue)),
                  const SizedBox(width: 4),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text('AED', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: AppTheme.deepNavyBlue)),
                  ),
                ],
              ),
              Text(tx['type']!, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.green.shade700, letterSpacing: 0.5)),
            ],
          ),
        ],
      ),
    );
  }
}
