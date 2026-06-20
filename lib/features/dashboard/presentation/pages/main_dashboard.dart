import 'package:flutter/material.dart';
import 'pending_tasks_page.dart';
import 'package:extend_crane_services/features/operations/presentation/widgets/direct_work_modal.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../quotation/data/models/quotation_model.dart';
import 'package:extend_crane_services/features/quotation/presentation/pages/add_quotation_page.dart';
import 'package:extend_crane_services/features/quotation/presentation/pages/quotation_history_page.dart';
import 'package:extend_crane_services/features/maintenance/presentation/pages/maintenance_history_page.dart';
import 'package:extend_crane_services/features/reports/presentation/pages/earnings_report_page.dart';
import 'package:extend_crane_services/features/notifications/presentation/pages/notification_screen.dart';
import 'package:extend_crane_services/features/settings/presentation/pages/settings_page.dart';
import 'package:extend_crane_services/core/presentation/widgets/custom_drawer.dart';
import 'package:extend_crane_services/shared/global_widgets/premium_background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../features/finance/data/repositories/finance_repository.dart';
import '../../../../features/quotation/data/repositories/quotation_repository.dart';
import '../../../auth/presentation/controllers/login_notifier.dart';
import '../../../notifications/presentation/providers/notification_providers.dart'
    as np;
import '../../../notifications/data/models/pending_item.dart';
import '../../../../core/services/local_notification_service.dart';

class MainDashboard extends ConsumerStatefulWidget {
  final bool isViewer;

  const MainDashboard({super.key, this.isViewer = false});

  @override
  ConsumerState<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends ConsumerState<MainDashboard>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _pulseController;
  List<PendingItem> _currentPendingItems = [];
  bool _hasShownPendingAlert = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndShowPendingPopup();
    }
  }

  void _checkAndShowPendingPopup() {
    if (_currentPendingItems.isNotEmpty) {
      final item = _currentPendingItems.first;
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.amberAccent, width: 2),
          ),
          title: const Text(
            'Pending Task Resume',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Client: ${item.clientName}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Location: ${item.location}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                'Amount: AED ${item.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'LATER',
                style: TextStyle(color: Colors.white30),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'ACCEPT / PROCESS',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showForcedResolutionDialog(QuotationModel quotation) {
    debugPrint(
      'DEBUG: Calling _showForcedResolutionDialog for quote ID: ${quotation.id}',
    );
    showDialog(
      context: context,
      barrierDismissible: false, // Force User Action
      builder: (context) => PopScope(
        canPop: false, // Disable back button
        child: AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Colors.redAccent, width: 2),
          ),
          title: const Text(
            'Action Required',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'You must resolve your oldest pending quotation before proceeding:',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Text(
                'Client: ${quotation.clientName}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Location: ${quotation.siteLocation}',
                style: const TextStyle(color: Colors.blueAccent),
              ),
              Text(
                'Amount: AED ${quotation.totalAmount}',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.2, // Perfect rectangle ratio text visibility ke liye
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                // Button 1: Pending
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 4), // Text ko side margins se bachaega
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Pending',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Button 2: Cancel
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  onPressed: () async {
                    await ref.read(quotationRepositoryProvider).updateQuotationStatus(quotation.id, 'cancelled');
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Button 3: Completed
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  onPressed: () async {
                    await ref.read(quotationRepositoryProvider).updateQuotationStatus(quotation.id, 'completed');
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text(
                    'Completed',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Button 4: Back to Screen
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Back to Screen',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.2), // Chota size taake word break na ho
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Optimization: Listen to only the user ID to reduce unnecessary rebuilding
    final userId = ref.watch(currentUserProvider.select((userAsync) => userAsync.asData?.value?.id));
    final userName = ref.watch(currentUserProvider.select((userAsync) => userAsync.asData?.value?.fullName));
    
    final screenWidth = MediaQuery.of(context).size.width;
    final useSidebar = screenWidth > 900;

    // TASK 2: High-reliability listener for forced modals
    if (userId != null && !widget.isViewer) {
      ref.listen<AsyncValue<QuotationModel?>>(
        firstPendingQuotationProvider(userId),
        (previous, next) {
          if (!_hasShownPendingAlert) {
            next.whenData((quotation) {
              if (quotation != null) {
                _hasShownPendingAlert = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _showForcedResolutionDialog(quotation);
                });
              }
            });
          }
        },
      );

      // Task: Move notifications to listener to improve performance
      ref.listen<AsyncValue<List<PendingItem>>>(
        np.pendingWorkProvider(userId),
        (previous, next) {
          next.whenData((items) {
            if (items.isNotEmpty) {
              LocalNotificationService.scheduleMidnightCheck(
                items.first.clientName,
              );
              if (DateTime.now().hour >= 0 && DateTime.now().hour < 6) {
                LocalNotificationService.showHighPriorityAlert(
                  items.first.clientName,
                );
              }
            }
          });
        },
      );
    }

    return PremiumScaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      drawer: useSidebar
          ? null
          : CustomDrawer(activeRoute: 'Dashboard', isViewer: widget.isViewer),
      floatingActionButton: widget.isViewer 
          ? null 
          : Consumer(
              builder: (context, ref, child) {
                final userAsync = ref.watch(currentUserProvider);
                return userAsync.when(
                  data: (user) {
                    if (user == null) return const SizedBox.shrink();
                    return const _DashboardFabRow();
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (err, stack) => const SizedBox.shrink(),
                );
              },
            ),
      body: userId == null
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : Consumer(
              builder: (context, ref, child) {
                final pendingAsync = ref.watch(np.pendingWorkProvider(userId));
                return pendingAsync.when(
                  data: (pendingItems) {
                    _currentPendingItems = pendingItems;
                    final hasPending = !widget.isViewer && pendingItems.isNotEmpty;

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
                          if (hasPending)
                            _PendingWarningBanner(pendingItem: pendingItems.first),
                          Padding(
                            padding: EdgeInsets.only(top: hasPending ? 50 : 0),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final isTablet = constraints.maxWidth > 600;
                                return Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 1200),
                                    child: CustomScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      slivers: [
                                        _buildDashboardAppBar(theme, userName),
                                        // Component Extraction & Riverpod Optimization:
                                        // Extracted StatsGridSection watches its own provider, preventing rebuilds of the entire screen when stats update
                                        StatsGridSection(userId: userId, isTablet: isTablet),
                                        SliverPadding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 0,
                                          ),
                                          sliver: SliverList(
                                            delegate: SliverChildListDelegate([
                                              if (hasPending)
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                                  child: FadeTransition(
                                                    opacity: Tween<double>(
                                                      begin: 0.6,
                                                      end: 1.0,
                                                    ).animate(_pulseController),
                                                    child: FloatingActionButton.extended(
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                const PendingTasksPage(),
                                                          ),
                                                        );
                                                      },
                                                      backgroundColor: Colors.redAccent,
                                                      icon: const Icon(
                                                        Icons.assignment_late,
                                                        color: Colors.white,
                                                      ),
                                                      label: Text(
                                                        '${pendingItems.length} PENDING',
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              const SizedBox(height: 10),
                                              const Text(
                                                'Recent Activity',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              // Component Extraction & List Optimization:
                                              // Extracted RecentActivitySection watches its own provider and uses a ListView.builder for performance
                                              RecentActivitySection(userId: userId),
                                            ]),
                                          ),
                                        ),
                                        const SliverToBoxAdapter(
                                          child: SizedBox(height: 100),
                                        ),
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
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  error: (err, stack) {
                    debugPrint('Firestore Pending Stream Error: $err');
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Error loading pending work: $err',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                );
              },
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
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationScreen()),
          ),
          icon: const Icon(
            Icons.notifications_active_outlined,
            color: Colors.white,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SettingsPage()),
          ),
          icon: const Icon(Icons.person_outline, color: Colors.white),
        ),
      ],
    );
  }
}

// Standalone FAB Row to prevent main rebuilds
class _DashboardFabRow extends StatelessWidget {
  const _DashboardFabRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
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
          icon: const Icon(
            Icons.flash_on_rounded,
            size: 20,
            color: Colors.black,
          ),
          label: const Text(
            'Direct Work',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
        ),
        const SizedBox(width: 16),
        FloatingActionButton.extended(
          heroTag: 'quotation',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddQuotationPage()),
            );
          },
          icon: const Icon(Icons.add_box, size: 20, color: Colors.black),
          label: const Text(
            'Generate Q',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
        ),
      ],
    );
  }
}

// Standalone Pending Warning Banner to prevent unnecessary builds
class _PendingWarningBanner extends StatelessWidget {
  final PendingItem pendingItem;

  const _PendingWarningBanner({required this.pendingItem});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xE6F44336),
          boxShadow: const [
            BoxShadow(color: Colors.black45, blurRadius: 10),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚠️ PENDING: ${pendingItem.clientName} @ ${pendingItem.location} (${pendingItem.type.toUpperCase()})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      'Amount: AED ${pendingItem.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PendingTasksPage(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black26,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'MANAGE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extracted Stats Grid Section (ConsumerWidget)
class StatsGridSection extends ConsumerWidget {
  final String userId;
  final bool isTablet;

  const StatsGridSection({
    super.key,
    required this.userId,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(operatorStatsProvider(userId));
    return statsAsync.when(
      data: (stats) => StatsGrid(stats: stats, isTablet: isTablet),
      loading: () => const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: CircularProgressIndicator(color: Colors.amber),
          ),
        ),
      ),
      error: (err, _) => SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Error loading stats: $err',
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ),
      ),
    );
  }
}

// Stats Grid Display (StatelessWidget)
class StatsGrid extends StatelessWidget {
  final OperatorStats stats;
  final bool isTablet;

  const StatsGrid({
    super.key,
    required this.stats,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
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
          SummaryCard(
            title: 'Total Quotes',
            value: '${stats.totalQuotes}',
            icon: Icons.request_quote,
            color: Colors.blue,
            destination: const QuotationHistoryPage(),
          ),
          SummaryCard(
            title: 'Pending Jobs',
            value: '${stats.pendingJob}',
            icon: Icons.engineering,
            color: Colors.orange,
            destination: const PendingTasksPage(),
          ),
          SummaryCard(
            title: 'Maintenance',
            value: '${stats.maintenanceCount}',
            icon: Icons.build,
            color: Colors.redAccent,
            destination: const MaintenanceHistoryPage(),
          ),
          SummaryCard(
            title: 'Earnings',
            value: 'AED ${stats.totalEarnings.toStringAsFixed(0)}',
            icon: Icons.monetization_on,
            color: Colors.green,
            destination: const EarningsReportPage(),
          ),
        ]),
      ),
    );
  }
}

// Summary Card Widget (StatelessWidget with const constructor)
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Widget? destination;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.destination,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 6,
      color: Colors.black26,
      child: InkWell(
        onTap: destination != null
            ? () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => destination!),
                )
            : null,
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceTranslucent,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0x1AFFFFFF)),
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
}

// Extracted Recent Activity Section (ConsumerWidget)
class RecentActivitySection extends ConsumerWidget {
  final String userId;

  const RecentActivitySection({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(operatorRecentActivityProvider(userId));
    return activityAsync.when(
      data: (activities) {
        if (activities.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No recent jobs found.',
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
          itemBuilder: (context, index) {
            return LiveActivityTile(act: activities[index]);
          },
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(color: Colors.amber),
        ),
      ),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'Error loading activities: $err',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }
}

// Live Activity Tile Widget (StatelessWidget with const constructor)
class LiveActivityTile extends StatelessWidget {
  final dynamic act;

  const LiveActivityTile({super.key, required this.act});

  @override
  Widget build(BuildContext context) {
    final isJob = act['type'] == 'job';
    final dateStr = DateFormat('dd MMM, hh:mm a').format(act['date']);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: const Color(0x80000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0x80FFFFFF)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isJob ? const Color(0x1A4CAF50) : const Color(0x1AFFC107),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isJob ? Icons.precision_manufacturing : Icons.receipt_long_outlined,
            color: isJob ? Colors.greenAccent : Colors.amberAccent,
            size: 20,
          ),
        ),
        title: Text(
          act['description'] ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 14,
          ),
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
