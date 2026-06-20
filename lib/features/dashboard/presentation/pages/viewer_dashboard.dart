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
  late final AnimationController _alertController;
  late final ScrollController _scrollController;
  // Performance Optimization: Use ValueNotifier instead of calling setState() 
  // on every scroll event to prevent rebuilding the entire widget tree.
  final ValueNotifier<double> _parallaxNotifier = ValueNotifier<double>(0.0);

  @override
  void initState() {
    super.initState();
    _alertController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scrollController = ScrollController()
      ..addListener(() {
        _parallaxNotifier.value = _scrollController.offset * 0.3;
      });
  }

  @override
  void dispose() {
    _alertController.dispose();
    _scrollController.dispose();
    _parallaxNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          // Performance Optimization: ValueListenableBuilder intercepts the scroll updates
          // and translates the background, bypassing rebuilds of cards and lists below.
          ValueListenableBuilder<double>(
            valueListenable: _parallaxNotifier,
            builder: (context, offset, child) {
              return Positioned(
                top: -offset,
                left: 0,
                right: 0,
                bottom: 0,
                child: child!,
              );
            },
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.lavenderBlueGradient,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Extracted header widget that animates independently
                ViewerLiveStatusHeader(alertController: _alertController),
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
                        // Extracted CommandCenterSection watches its own providers, saving page rebuilds
                        const ViewerCommandCenter(),
                        const SizedBox(height: 10),
                        const _ViewerExecutionTabs(),
                        const SizedBox(height: 20),
                        // Extracted activity feed watches only what it needs and uses ListView.builder
                        const ViewerActivityStream(),
                      ],
                    ),
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

// Helper to convert model status string to widget enum
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

// Extracted independent status header widget
class ViewerLiveStatusHeader extends ConsumerWidget {
  final AnimationController alertController;

  const ViewerLiveStatusHeader({super.key, required this.alertController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only watch the latest quotation description/details to avoid full header rebuilds on other updates
    final latestQuotationAsync = ref.watch(allQuotationsProvider);

    return latestQuotationAsync.when(
      data: (quotations) {
        if (quotations.isEmpty) return const SizedBox.shrink();
        final latest = quotations.first;
        final latestActivity = 'New Site Activity: ${latest.clientName} @ ${latest.siteLocation}';

        return AnimatedBuilder(
          animation: alertController,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: Color.lerp(
                  Colors.red.shade900,
                  Colors.amber.shade900,
                  alertController.value,
                )!.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(
                      alpha: 0.3 * alertController.value,
                    ),
                    blurRadius: 15 * alertController.value,
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
      },
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}

// Extracted command center section watching financial and job updates independently
class ViewerCommandCenter extends ConsumerWidget {
  const ViewerCommandCenter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(financialSummaryProvider);
    final quotationsAsync = ref.watch(allQuotationsProvider);
    final workOrdersAsync = ref.watch(allWorkOrdersProvider);

    return summaryAsync.when(
      data: (summary) => quotationsAsync.when(
        data: (quotations) => workOrdersAsync.when(
          data: (workOrders) {
            final liveProfit = summary.netProfit;
            final activeWorkCount = quotations.where((q) => q.status == 'pending').length +
                workOrders.where((w) => w.status == 'pending' || w.status == 'pending_approval').length;
            final maintenanceCost = summary.categoryBreakdown['Maintenance'] ?? 0.0;
            final cancelledTaskCount = quotations.where((q) => q.status == 'cancelled').length +
                workOrders.where((w) => w.status == 'cancelled').length;

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
          },
          loading: () => const _LoadingPlaceholder(),
          error: (err, _) => _ErrorPlaceholder(error: err.toString()),
        ),
        loading: () => const _LoadingPlaceholder(),
        error: (err, _) => _ErrorPlaceholder(error: err.toString()),
      ),
      loading: () => const _LoadingPlaceholder(),
      error: (err, _) => _ErrorPlaceholder(error: err.toString()),
    );
  }
}

// Extracted reports tabs widget
class _ViewerExecutionTabs extends StatelessWidget {
  const _ViewerExecutionTabs();

  @override
  Widget build(BuildContext context) {
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
}

// Extracted and list-optimized LiveActivityStream Section
class ViewerActivityStream extends ConsumerWidget {
  const ViewerActivityStream({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotationsAsync = ref.watch(allQuotationsProvider);
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
        quotationsAsync.when(
          data: (quotations) {
            final recentQuotations = quotations.take(5).toList();
            if (recentQuotations.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No recent activity',
                    style: TextStyle(
                      color: AppTheme.deepNavyBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentQuotations.length,
              itemBuilder: (context, index) {
                final q = recentQuotations[index];
                return LiveStatusFeedItem(
                  title: q.clientName,
                  subtitle: q.siteLocation,
                  amount: currencyFormatter.format(q.totalAmount),
                  status: _parseStatus(q.status),
                  reason: q.cancellationReason,
                );
              },
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: CircularProgressIndicator(color: Colors.amber),
            ),
          ),
          error: (err, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Error loading activity feed: $err',
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 150,
      child: Center(child: CircularProgressIndicator(color: Colors.amber)),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  final String error;
  const _ErrorPlaceholder({required this.error});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Center(
        child: Text(
          'Error loading data: $error',
          style: const TextStyle(color: Colors.redAccent),
        ),
      ),
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
                color: const Color(0x59FFFFFF),
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
                      color: const Color(0x990A1931),
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
        shadowColor: const Color(0x660A1931),
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
