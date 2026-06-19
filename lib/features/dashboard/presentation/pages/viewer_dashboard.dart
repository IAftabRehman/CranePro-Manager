import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/core/presentation/widgets/custom_drawer.dart';
import 'package:extend_crane_services/features/dashboard/presentation/widgets/live_status_feed_item.dart';
import 'package:extend_crane_services/features/quotation/data/models/quotation_model.dart';
import 'package:extend_crane_services/features/reports/presentation/pages/work_history_viewer_page.dart';
import 'package:extend_crane_services/features/finance/data/repositories/finance_repository.dart';
import 'package:extend_crane_services/features/quotation/data/repositories/quotation_repository.dart';
import 'package:extend_crane_services/features/work_order/data/repositories/work_repository.dart';
import 'package:intl/intl.dart';

class ViewerDashboard extends ConsumerStatefulWidget {
  const ViewerDashboard({super.key});

  @override
  ConsumerState<ViewerDashboard> createState() => _ViewerDashboardState();
}

class _ViewerDashboardState extends ConsumerState<ViewerDashboard>
    with TickerProviderStateMixin {
  late AnimationController _alertController;
  late ScrollController _scrollController;
  double _parallaxOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _alertController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _parallaxOffset = _scrollController.offset * 0.3;
        });
      });
  }

  @override
  void dispose() {
    _alertController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  QuotationStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return QuotationStatus.completed;
      case 'cancelled':
        return QuotationStatus.cancelled;
      default:
        return QuotationStatus.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(financialSummaryProvider);
    final quotationsAsync = ref.watch(allQuotationsProvider);
    final workOrdersAsync = ref.watch(allWorkOrdersProvider);

    return Scaffold(
      drawer: const CustomDrawer(activeRoute: 'Dashboard', isViewer: true),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent.shade200,
        elevation: 5,
        shadowColor: Colors.blue,
        title: const Text(
          "Family Monitor",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -_parallaxOffset,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.lavenderBlueGradient,
              ),
            ),
          ),

          SafeArea(
            child: summaryAsync.when(
              data: (summary) => quotationsAsync.when(
                data: (quotations) => workOrdersAsync.when(
                  data: (workOrders) {
                    final liveProfit = summary.netProfit;
                    final activeWorkCount = quotations.where((q) => q.status == 'pending').length +
                        workOrders.where((w) => w.status == 'pending' || w.status == 'pending_approval').length;
                    final maintenanceCost = summary.categoryBreakdown['Maintenance'] ?? 0.0;
                    final cancelledTaskCount = quotations.where((q) => q.status == 'cancelled').length +
                        workOrders.where((w) => w.status == 'cancelled').length;

                    // Latest activity string
                    String? latestActivity;
                    if (quotations.isNotEmpty) {
                      final latest = quotations.first;
                      latestActivity = 'New Site Activity: ${latest.clientName} @ ${latest.siteLocation}';
                    }

                    // Get top 5 recent quotations for activity feed
                    final recentQuotations = quotations.take(5).toList();

                    return Column(
                      children: [
                        _buildLiveStatusHeader(latestActivity),
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 20,
                            ),
                            child: Column(
                              children: [
                                _buildCommandCenterGrid(
                                  liveProfit: liveProfit,
                                  activeWorkCount: activeWorkCount,
                                  maintenanceCost: maintenanceCost,
                                  cancelledTaskCount: cancelledTaskCount,
                                ),
                                const SizedBox(height: 10),
                                _buildExecutionTabs(context),
                                const SizedBox(height: 20),
                                _buildLiveActivityStream(context, recentQuotations),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: Colors.amber)),
                  error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
                ),
                loading: () => const Center(child: CircularProgressIndicator(color: Colors.amber)),
                error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
              ),
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.amber)),
              error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStatusHeader(String? latestActivity) {
    if (latestActivity == null || latestActivity.isEmpty) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _alertController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: Color.lerp(
              Colors.red.shade900,
              Colors.amber.shade900,
              _alertController.value,
            )!.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(
                  alpha: 0.3 * _alertController.value,
                ),
                blurRadius: 15 * _alertController.value,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.bolt_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'DUBAI UPDATE: $latestActivity',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommandCenterGrid({
    required double liveProfit,
    required int activeWorkCount,
    required double maintenanceCost,
    required int cancelledTaskCount,
  }) {
    final currencyFormatter = NumberFormat.currency(symbol: 'AED ', decimalDigits: 0);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _CommandCard(
                label: 'Live Profit',
                value: currencyFormatter.format(liveProfit),
                icon: Icons.auto_graph_rounded,
                isPrimary: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _CommandCard(
                label: 'Active Work',
                value: '$activeWorkCount JOBS',
                icon: Icons.timer_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _CommandCard(
                label: 'Maintenance',
                value: currencyFormatter.format(maintenanceCost),
                icon: Icons.build_circle_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _CommandCard(
                label: 'Cancelled',
                value: '$cancelledTaskCount TASKS',
                icon: Icons.cancel_presentation_rounded,
                isDanger: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExecutionTabs(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Reports',
              style: TextStyle(
                color: AppTheme.deepNavyBlue,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View All',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: _ReportExecutionModeButton(
                label: 'Own Crane',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WorkHistoryViewerPage(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: _ReportExecutionModeButton(
                label: 'Commission',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WorkHistoryViewerPage(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLiveActivityStream(BuildContext context, List<QuotationModel> recentQuotations) {
    final currencyFormatter = NumberFormat.currency(symbol: 'AED ', decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 20),
          child: Text(
            'Live Activity Stream',
            style: TextStyle(
              color: AppTheme.deepNavyBlue,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
        ),
        if (recentQuotations.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'No recent activity',
                style: TextStyle(color: AppTheme.deepNavyBlue, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          )
        else
          ...recentQuotations.map((q) => LiveStatusFeedItem(
                title: q.clientName,
                subtitle: q.siteLocation,
                amount: currencyFormatter.format(q.totalAmount),
                status: _parseStatus(q.status),
                reason: q.cancellationReason,
              )),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _CommandCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isPrimary;
  final bool isDanger;

  const _CommandCard({
    required this.label,
    required this.value,
    required this.icon,
    this.isPrimary = false,
    this.isDanger = false,
  });

  @override
  State<_CommandCard> createState() => _CommandCardState();
}

class _CommandCardState extends State<_CommandCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _pressController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color accentColor = AppTheme.deepNavyBlue;
    if (widget.isPrimary) accentColor = Colors.green.shade900;
    if (widget.isDanger) accentColor = Colors.red.shade900;

    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) => _pressController.reverse(),
      onTapCancel: () => _pressController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.05 + (_scaleAnimation.value - 1.0),
                    ),
                    offset: const Offset(0, 10),
                    blurRadius: 20 * _scaleAnimation.value,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(widget.icon, color: accentColor, size: 24),
                  const SizedBox(height: 10),
                  Text(
                    widget.label.toUpperCase(),
                    style: TextStyle(
                      color: AppTheme.deepNavyBlue.withValues(alpha: 0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.value,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ReportExecutionModeButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ReportExecutionModeButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white54,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 10,
        shadowColor: AppTheme.deepNavyBlue.withValues(alpha: 0.4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black,
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
