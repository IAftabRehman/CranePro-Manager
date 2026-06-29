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
    // Only watch the user ID to prevent rebuilds on other user profile updates
    final userId = ref.watch(currentUserProvider.select((userAsync) => userAsync.asData?.value?.id));
    final user = ref.watch(currentUserProvider.select((userAsync) => userAsync.asData?.value));

    return PremiumScaffold(
      appBar: AppBar(
        title: const Text(
          'My Analytics',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 15),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: userId == null
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Component Extraction & Riverpod Optimization:
                  // Extracted OperatorSummaryCardsSection watches its own provider, preventing rebuilds of the entire screen when stats update
                  OperatorSummaryCardsSection(userId: userId),
                  
                  const SizedBox(height: 32),
                  
                  // Component Extraction: Extracted standalone circular target chart
                  const MonthlyPerformanceTargetCard(),
                  
                  const SizedBox(height: 32),
                  
                  const Text(
                    'Recent Activity',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  
                  // Component Extraction & List Optimization:
                  // Extracted OperatorActivityListSection watches its own provider and uses virtualized ListView.builder
                  OperatorActivityListSection(userId: userId),
                  
                  const SizedBox(height: 20),
                  
                  if (user != null)
                    DownloadReportButton(user: user),
                  
                  const SizedBox(height: 10),
                ],
              ),
            ),
    );
  }
}

// Extracted summary stats section
class OperatorSummaryCardsSection extends ConsumerWidget {
  final String userId;

  const OperatorSummaryCardsSection({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(operatorStatsProvider(userId));

    return statsAsync.when(
      data: (stats) => Column(
        children: [
          StatCard(
            title: 'Total Earnings',
            value: 'AED ${stats.totalEarnings.toStringAsFixed(2)}',
            icon: Icons.payments_outlined,
            gradient: AppTheme.lavenderBlueGradient,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Expenses',
                  value: 'AED ${stats.totalExpenses.toStringAsFixed(0)}',
                  icon: Icons.shopping_cart_outlined,
                  gradient: AppTheme.lavenderBlueGradient,
                  isSmall: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: 'Net Profit',
                  value: 'AED ${stats.netBalance.toStringAsFixed(0)}',
                  icon: Icons.account_balance_wallet_outlined,
                  gradient: AppTheme.lavenderBlueGradient,
                  isSmall: true,
                ),
              ),
            ],
          ),
        ],
      ),
      loading: () => const RepaintBoundary(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: CircularProgressIndicator(color: Colors.amber),
          ),
        ),
      ),
      error: (err, _) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          'Error loading stats: $err',
          style: const TextStyle(color: Colors.redAccent),
        ),
      ),
    );
  }
}

// Reusable stat card with const constructor
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final LinearGradient gradient;
  final bool isSmall;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 12 : 20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0x33000000),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!isSmall) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0x33FFFFFF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 25),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: isSmall ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: const Color(0xCCFFFFFF),
                    fontSize: isSmall ? 12 : 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmall ? 15 : 20,
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
}

// Extracted Monthly target indicator card with const constructor
class MonthlyPerformanceTargetCard extends StatelessWidget {
  const MonthlyPerformanceTargetCard({super.key});

  @override
  Widget build(BuildContext context) {
    const double progress = 0.68; // Mock value for visual representation

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 100,
            width: 100,
            child: PieChart(
              curve: Curves.easeOutCirc,
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
                    color: const Color(0x1AFFFFFF),
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
                const Text(
                  'Monthly Target',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                const Text(
                  '68% Completed',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Keep pushing! You are 12 jobs away from your monthly bonus.',
                  style: TextStyle(
                    color: const Color(0x80FFFFFF),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Extracted recent activity list section
class OperatorActivityListSection extends ConsumerWidget {
  final String userId;

  const OperatorActivityListSection({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(operatorRecentActivityProvider(userId));

    return activityAsync.when(
      data: (activities) {
        if (activities.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'No recent activity recorded.',
                style: TextStyle(color: Colors.white38),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          prototypeItem: Builder(
            builder: (context) {
              if (activities.isEmpty) return const SizedBox.shrink();
              final activity = activities.first;
              final isJob = activity['type'] == 'job';
              final dateStr = DateFormat('dd MMM, hh:mm a').format(activity['date']);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0x0DFFFFFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isJob ? const Color(0x1A4CAF50) : const Color(0x1AFF5252),
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
                            activity['description'] ?? '',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            dateStr,
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
            }
          ),
          itemBuilder: (context, index) {
            final activity = activities[index];
            final isJob = activity['type'] == 'job';
            final dateStr = DateFormat('dd MMM, hh:mm a').format(activity['date']);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0x0DFFFFFF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isJob ? const Color(0x1A4CAF50) : const Color(0x1AFF5252),
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
                          activity['description'] ?? '',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          dateStr,
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
      },
      loading: () => const RepaintBoundary(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: CircularProgressIndicator(color: Colors.amber),
          ),
        ),
      ),
      error: (err, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'Error loading activity: $err',
          style: const TextStyle(color: Colors.redAccent),
        ),
      ),
    );
  }
}

// Extracted download button widget
class DownloadReportButton extends ConsumerWidget {
  final dynamic user;

  const DownloadReportButton({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ElevatedButton(
        onPressed: () => _generateReport(context, ref, user),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: const Text(
          'Download Monthly Report',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
        ),
      ),
    );
  }

  Future<void> _generateReport(BuildContext context, WidgetRef ref, dynamic user) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const RepaintBoundary(
        child: Center(child: CircularProgressIndicator(color: Colors.amber)),
      ),
    );

    try {
      final repo = ref.read(financeRepositoryProvider);
      final now = DateTime.now();

      final expenses = await repo.getOperatorExpensesStream(user.id).first;

      final pdfBytes = await PdfService.generateOperatorMonthlyReport(
        user,
        [], 
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
