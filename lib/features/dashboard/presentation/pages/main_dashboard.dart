import 'package:flutter/material.dart';
import 'package:extend_crane_services/features/operations/presentation/widgets/direct_work_modal.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../quotation/data/models/quotation_model.dart';
import 'package:extend_crane_services/features/quotation/presentation/pages/add_quotation_page.dart';
import 'package:extend_crane_services/features/maintenance/presentation/pages/maintenance_history_page.dart';
import 'package:extend_crane_services/features/reports/presentation/pages/earnings_report_page.dart';
import 'package:extend_crane_services/features/notifications/presentation/pages/notification_screen.dart';
import 'package:extend_crane_services/features/settings/presentation/pages/settings_page.dart';
import 'package:extend_crane_services/core/presentation/widgets/custom_drawer.dart';
import 'package:extend_crane_services/shared/global_widgets/premium_background.dart';
import '../widgets/midnight_status_modal.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../features/finance/data/repositories/finance_repository.dart';
import '../../../auth/presentation/controllers/login_notifier.dart';

class MainDashboard extends ConsumerStatefulWidget {
  final bool isViewer;
  const MainDashboard({super.key, this.isViewer = false});

  @override
  ConsumerState<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends ConsumerState<MainDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final int _pendingCount = 2; // Mocking 2 pending reports for demonstration

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // TASK 1: Mock 12:00 AM Notification Trigger (Only for non-viewers)
    if (!widget.isViewer) {
      _checkAndShowMidnightPopup();
    }
  }

  void _checkAndShowMidnightPopup() {
    // In a real app, this would check the current time and shared preferences
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.redAccent, width: 2),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.notification_important_rounded,
                color: Colors.redAccent,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'MIDNIGHT UPDATE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Work Update Required for:',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const Text(
                'Street Client',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Location: Musaffah M-27',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please update the status to clear this from your dashboard.',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),),
            const Spacer(),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => MidnightStatusModal(
                    date: DateTime.now().subtract(const Duration(days: 1)),
                    quotation: QuotationModel(
                      id: 'mock_1',
                      operatorId: 'mock_op',
                      clientName: 'Street Client',
                      siteLocation: 'Musaffah M-27',
                      serviceType: '50 Ton Crane',
                      totalAmount: 1000,
                      balanceAmount: 1000,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                      workDate: DateTime.now(),
                    ),
                  ),
                );
              },
              child: const Text(
                'UPDATE NOW',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, [
    Widget? destination,
  ]) {
    final theme = Theme.of(context);
    return Card(
      elevation: 6,
      color: Colors.black26,
      child: InkWell(
        onTap: destination != null
            ? () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => destination),
              )
            : null,
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            padding: EdgeInsets.all(
              Responsive.scale(context, 16).clamp(12.0, 24.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: Responsive.scale(context, 28).clamp(24.0, 36.0),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontSize: Responsive.scale(
                          context,
                          24,
                        ).clamp(20.0, 32.0),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                        fontSize: Responsive.scale(
                          context,
                          12,
                        ).clamp(10.0, 14.0),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentQuoteTile(
    BuildContext context,
    String client,
    String site,
    String amount,
    String date,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 6,
      color: Colors.black38,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: Responsive.scale(context, 16).clamp(16.0, 24.0),
          vertical: 8,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.precision_manufacturing, color: Color(0xFFFFB300)),
        ),
        title: Text(
          client,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          site,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: Colors.white70),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userAsync = ref.watch(currentUserProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final useSidebar = screenWidth > 900;

    return PremiumScaffold(
      drawer: useSidebar ? null : CustomDrawer(activeRoute: 'Dashboard', isViewer: widget.isViewer),
      floatingActionButton: widget.isViewer ? null : Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'direct_work',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const DirectWorkModal(),
              );
            },
            icon: const Icon(Icons.flash_on_rounded, size: 20),
            label: const Text(
              'Direct Work',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
          ),
          const SizedBox(width: 12),
          FloatingActionButton.extended(
            heroTag: 'quotation',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddQuotationPage()),
              );
            },
            icon: const Icon(Icons.add_box, size: 20),
            label: const Text(
              'Generate Quotation',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('User session ended.'));
          final statsAsync = ref.watch(operatorStatsProvider(user.id));
          final activityAsync = ref.watch(operatorRecentActivityProvider(user.id));

          return SafeArea(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: AppTheme.lavenderBlueGradient,
                  ),
                ),
                // Persistence Header Logic for Pending Tasks
                if (!widget.isViewer && _pendingCount > 0)
                  _buildPendingBanner(context),

                Padding(
                  padding: EdgeInsets.only(top: _pendingCount > 0 ? 60 : 0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isTablet = constraints.maxWidth > 600;
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: CustomScrollView(
                            physics: const BouncingScrollPhysics(),
                            slivers: [
                              _buildDashboardAppBar(theme, user.fullName),
                              
                              // 4 Summary Cards Grid
                              statsAsync.when(
                                data: (stats) => _buildStatsGrid(context, stats, isTablet),
                                loading: () => const SliverToBoxAdapter(
                                  child: Center(child: CircularProgressIndicator(color: Colors.amber)),
                                ),
                                error: (err, _) => SliverToBoxAdapter(
                                  child: Center(child: Text('Error loading stats: $err', style: const TextStyle(color: Colors.redAccent))),
                                ),
                              ),

                              if (!widget.isViewer && _pendingCount > 0)
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                    child: FadeTransition(
                                      opacity: Tween<double>(
                                        begin: 0.4,
                                        end: 1.0,
                                      ).animate(_pulseController),
                                      child: InkWell(
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (_) => MidnightStatusModal(
                                              date: DateTime.now().subtract(
                                                const Duration(days: 1),
                                              ),
                                              quotation: QuotationModel(
                                                id: 'mock_1',
                                                operatorId: 'mock_op',
                                                clientName: 'Street Client',
                                                siteLocation: 'Musaffah M-27',
                                                serviceType: '50 Ton Crane',
                                                totalAmount: 1000,
                                                balanceAmount: 1000,
                                                createdAt: DateTime.now(),
                                                updatedAt: DateTime.now(),
                                                workDate: DateTime.now(),
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.redAccent.withValues(
                                              alpha: 0.8,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.blue,
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.redAccent.withValues(
                                                  alpha: 0.5,
                                                ),
                                                blurRadius: 10,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.warning_amber_rounded,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'Action Required',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 15,
                                                        letterSpacing: 1.1,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Work Update Required for: Street Client',
                                                      style: const TextStyle(
                                                        color: Colors.white70,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Icon(
                                                Icons.arrow_forward_ios,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                              // Recent Activity Section
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                sliver: SliverList(
                                  delegate: SliverChildListDelegate([
                                    Text(
                                      'Recent Activity',
                                      style: theme.textTheme.displayLarge?.copyWith(
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    activityAsync.when(
                                      data: (activities) {
                                        if (activities.isEmpty) {
                                          return const Center(child: Text('No recent jobs found.', style: TextStyle(color: Colors.white38)));
                                        }
                                        return Column(
                                          children: activities.map((act) => _buildLiveActivityTile(context, act)).toList(),
                                        );
                                      },
                                      loading: () => const Center(child: CircularProgressIndicator(color: Colors.amber)),
                                      error: (err, _) => Center(child: Text('Error loading activities', style: const TextStyle(color: Colors.redAccent))),
                                    ),
                                  ]),
                                ),
                              ),
                              const SliverToBoxAdapter(child: SizedBox(height: 100)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Auth error: $err')),
      ),
    );
  }

  Widget _buildPendingBanner(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.8),
          boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 2))],
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              const Icon(Icons.warning_rounded, color: Colors.white, size: 25),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Pending Mid-Night Updates. Please update status now!',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              ElevatedButton(
                onPressed: () {}, // Trigger modal
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.2),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  elevation: 0,
                ),
                child: const Text('Update Now', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardAppBar(ThemeData theme, String? name) {
    return SliverAppBar(
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'Welcome ${name ?? 'Operator'} 👋',
        style: theme.textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
          icon: const Icon(Icons.notifications_active_outlined, color: Colors.white),
        ),
        IconButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsPage())),
          icon: const Icon(Icons.person_outline, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, OperatorStats stats, bool isTablet) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 4 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        delegate: SliverChildListDelegate([
          _buildSummaryCard(context, 'Total Quotes', '${stats.totalQuotes}', Icons.request_quote, Colors.blue),
          _buildSummaryCard(context, 'Active Jobs', '${stats.activeJobs}', Icons.engineering, Colors.orange),
          _buildSummaryCard(context, 'Maintenance', '${stats.maintenanceCount}', Icons.build, Colors.redAccent, const MaintenanceHistoryPage()),
          _buildSummaryCard(context, 'Earnings', 'AED ${stats.totalEarnings.toStringAsFixed(0)}', Icons.monetization_on, Colors.green, const EarningsReportPage()),
        ]),
      ),
    );
  }

  Widget _buildLiveActivityTile(BuildContext context, dynamic act) {
    final isJob = act['type'] == 'job';
    final dateStr = DateFormat('dd MMM, hh:mm a').format(act['date']);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.black.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isJob ? Colors.green : Colors.amber).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isJob ? Icons.precision_manufacturing : Icons.receipt_long_outlined,
            color: isJob ? Colors.greenAccent : Colors.amberAccent,
            size: 20,
          ),
        ),
        title: Text(
          act['description'],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
        ),
        subtitle: Text(
          dateStr,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        trailing: Text(
          '${isJob ? '+' : '-'} ${act['amount'].toStringAsFixed(0)} AED',
          style: TextStyle(
            color: isJob ? Colors.greenAccent : Colors.redAccent,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
