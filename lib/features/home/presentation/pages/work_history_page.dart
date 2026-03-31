import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../shared/global_widgets/premium_background.dart';
import '../../../auth/presentation/controllers/login_notifier.dart';
import '../../../quotation/data/repositories/quotation_repository.dart';
import '../../../quotation/data/models/quotation_model.dart';
import '../../../finance/data/repositories/finance_repository.dart';
import '../../../finance/data/models/expense_model.dart';

class WorkHistoryPage extends ConsumerStatefulWidget {
  const WorkHistoryPage({super.key});

  @override
  ConsumerState<WorkHistoryPage> createState() => _WorkHistoryPageState();
}

class _WorkHistoryPageState extends ConsumerState<WorkHistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double _calculateMTD(List<QuotationModel> quotations) {
    final now = DateTime.now();
    return quotations
        .where((q) {
          return q.createdAt.month == now.month && q.createdAt.year == now.year;
        })
        .fold(0.0, (sum, q) => sum + q.totalAmount);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);
    final uid = authState.value?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please login to view history', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    // Direct streams for real-time history
    final quotationsStream = ref.watch(quotationRepositoryProvider).getOperatorQuotations(uid);
    final expensesStream = ref.watch(financeRepositoryProvider).getMyExpenses(uid);
    final currencyFormatter = NumberFormat.currency(symbol: 'AED ', decimalDigits: 2);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Working History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentGold,
          labelColor: AppTheme.accentGold,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'MY BILLS'),
            Tab(text: 'MY EXPENSES'),
          ],
        ),
      ),
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              // TASK 3: Summary Header Card
              StreamBuilder<List<QuotationModel>>(
                stream: quotationsStream,
                builder: (context, snapshot) {
                  final totalMTD = snapshot.hasData ? _calculateMTD(snapshot.data!) : 0.0;
                  return _buildSummaryHeader(totalMTD, currencyFormatter);
                },
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: My Bills
                    _buildQuotationTab(quotationsStream, currencyFormatter),
                    
                    // Tab 2: My Expenses
                    _buildExpenseTab(expensesStream, currencyFormatter),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(double amount, NumberFormat formatter) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppTheme.lavenderBlueGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_month, color: Colors.white.withValues(alpha: 0.8), size: 16),
              const SizedBox(width: 8),
              const Text(
                'TOTAL WORK THIS MONTH (MTD)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            formatter.format(amount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotationTab(Stream<List<QuotationModel>> stream, NumberFormat formatter) {
    return StreamBuilder<List<QuotationModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState('No billed work found', Icons.engineering_outlined);
        }

        final items = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final q = items[index];
            return _buildHistoryCard(
              title: q.clientName,
              subtitle: 'Type: ${q.serviceType}',
              date: q.createdAt,
              amount: q.totalAmount,
              formatter: formatter,
              status: q.balanceAmount <= 0 ? 'Completed' : 'Pending',
              statusColor: q.balanceAmount <= 0 ? Colors.greenAccent : Colors.orangeAccent,
              icon: Icons.engineering,
            );
          },
        );
      },
    );
  }

  Widget _buildExpenseTab(Stream<List<ExpenseModel>> stream, NumberFormat formatter) {
    return StreamBuilder<List<ExpenseModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState('No recorded expenses found', Icons.receipt_long_outlined);
        }

        final items = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final e = items[index];
            return _buildHistoryCard(
              title: e.category,
              subtitle: e.description,
              date: e.date,
              amount: e.amount,
              formatter: formatter,
              isExpense: true,
              icon: Icons.receipt_long,
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white24, size: 64),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.white54, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildHistoryCard({
    required String title,
    required String subtitle,
    required DateTime date,
    required double amount,
    required NumberFormat formatter,
    required IconData icon,
    String? status,
    Color? statusColor,
    bool isExpense = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: isExpense ? Colors.redAccent.withValues(alpha: 0.15) : AppTheme.accentGold.withValues(alpha: 0.15),
            child: Icon(icon, color: isExpense ? Colors.redAccent : AppTheme.accentGold, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM, yyyy').format(date),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatter.format(amount),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: isExpense ? Colors.redAccent : Colors.white,
                  fontSize: 16,
                ),
              ),
              if (status != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor!.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
