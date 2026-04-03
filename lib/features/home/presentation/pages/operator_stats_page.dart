import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../shared/global_widgets/premium_background.dart';
import '../../../auth/presentation/controllers/login_notifier.dart';
import '../../../../features/finance/data/repositories/finance_repository.dart';

class OperatorStatsPage extends ConsumerWidget {
  const OperatorStatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    
    return PremiumScaffold(
      appBar: AppBar(
        title: const Text('My Analytics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('User not found', style: TextStyle(color: Colors.white)));
          
          final statsAsync = ref.watch(operatorStatsProvider(user.id));
          final activityAsync = ref.watch(operatorRecentActivityProvider(user.id));
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Summary Cards Section
                statsAsync.when(
                  data: (stats) => _buildSummaryCards(stats),
                  loading: () => const Center(child: CircularProgressIndicator(color: Colors.amber)),
                  error: (err, _) => Text('Error loading stats: $err', style: const TextStyle(color: Colors.redAccent)),
                ),
                
                const SizedBox(height: 32),
                
                // 2. Circular Performance Chart
                _buildPerformanceChart(theme: Theme.of(context)),
                
                const SizedBox(height: 32),
                
                // 3. Recent Activity List
                const Text(
                  'Recent Activity',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                activityAsync.when(
                  data: (activities) => _buildActivityList(activities),
                  loading: () => const Center(child: CircularProgressIndicator(color: Colors.amber)),
                  error: (err, _) => Text('Error loading activity: $err', style: const TextStyle(color: Colors.redAccent)),
                ),
                
                const SizedBox(height: 40),
                
                // 4. Download Report Button
                _buildDownloadButton(context, ref, user),
                
                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
      ),
    );
  }

  Widget _buildSummaryCards(OperatorStats stats) {
    return Column(
      children: [
        _buildStatCard(
          'Total Earnings',
          'AED ${stats.totalEarnings.toStringAsFixed(2)}',
          Icons.payments_outlined,
          AppTheme.lavenderBlueGradient,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Expenses',
                'AED ${stats.totalExpenses.toStringAsFixed(0)}',
                Icons.shopping_cart_outlined,
                AppTheme.lavenderBlueGradient,
                isSmall: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Net Profit',
                'AED ${stats.netBalance.toStringAsFixed(0)}',
                Icons.account_balance_wallet_outlined,
                AppTheme.lavenderBlueGradient,
                isSmall: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, LinearGradient gradient, {bool isSmall = false}) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 16 : 24),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: isSmall ? 20 : 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: isSmall ? 12 : 14)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmall ? 18 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart({required ThemeData theme}) {
    // Current month target: 25 days job completion
    double progress = 0.68; // Mock value for visual
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 100,
            width: 100,
            child: PieChart(
              PieChartData(
                startDegreeOffset: 270,
                sectionsSpace: 0,
                centerSpaceRadius: 35,
                sections: [
                  PieChartSectionData(
                    color: Colors.amber,
                    value: progress * 100,
                    title: '',
                    radius: 12,
                  ),
                  PieChartSectionData(
                    color: Colors.white.withValues(alpha: 0.1),
                    value: (1 - progress) * 100,
                    title: '',
                    radius: 10,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Monthly Target', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                const Text('68% Completed', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'Keep pushing! You are 12 jobs away from your monthly bonus.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList(List<dynamic> activities) {
    if (activities.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: Text('No recent activity recorded.', style: TextStyle(color: Colors.white38))),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        final isJob = activity['type'] == 'job';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isJob ? Colors.green : Colors.redAccent).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isJob ? Icons.work_outline : Icons.receipt_long_outlined,
                  color: isJob ? Colors.green : Colors.redAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['description'],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      DateFormat('dd MMM, hh:mm a').format(activity['date']),
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Text(
                '${isJob ? '+' : '-'} AED ${activity['amount'].toStringAsFixed(0)}',
                style: TextStyle(
                  color: isJob ? Colors.green : Colors.redAccent,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDownloadButton(BuildContext context, WidgetRef ref, dynamic user) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _generateReport(context, ref, user),
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('Download My Monthly Report'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  Future<void> _generateReport(BuildContext context, WidgetRef ref, dynamic user) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.amber)),
    );

    try {
      final repo = ref.read(financeRepositoryProvider);
      final now = DateTime.now();
      
      // In a real production app, you'd use a repository method that filters by date.
      // For this implementation, we reuse the existing data available in the providers.
      final expenses = await repo.getOperatorExpensesStream(user.id).first; 

      final pdfBytes = await PdfService.generateOperatorMonthlyReport(
        user,
        [], // Would fetch actual current month quotes if available
        expenses,
      );

      if (context.mounted) Navigator.pop(context); // Close loading

      await Printing.layoutPdf(
        onLayout: (_) => pdfBytes,
        name: 'Report_${DateFormat('MMM_yyyy').format(now)}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
