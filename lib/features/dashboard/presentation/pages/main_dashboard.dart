import 'package:flutter/material.dart';
import 'package:extend_crane_services/features/operations/presentation/widgets/direct_work_modal.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../quotation/data/models/quotation_model.dart';
import 'package:extend_crane_services/features/quotation/presentation/pages/add_quotation_page.dart';
import 'package:extend_crane_services/features/maintenance/presentation/pages/maintenance_history_page.dart';
import 'package:extend_crane_services/features/reports/presentation/pages/earnings_report_page.dart';
import 'package:extend_crane_services/features/reports/presentation/pages/all_work_history_page.dart';
import 'package:extend_crane_services/features/settings/presentation/pages/settings_page.dart';
import 'package:extend_crane_services/core/presentation/widgets/custom_drawer.dart';
import 'package:extend_crane_services/shared/global_widgets/premium_background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../features/finance/data/repositories/finance_repository.dart';
import '../../../../features/quotation/data/repositories/quotation_repository.dart';
class MainDashboard extends ConsumerStatefulWidget {
  const MainDashboard({super.key});

  @override
  ConsumerState<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends ConsumerState<MainDashboard>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _pulseController;
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
      // Logic removed
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
    // No Firebase Auth — dashboard always renders for the selected role
    final String userId = '';
    final String? userName = null;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final useSidebar = screenWidth > 900;

    // TASK 2: High-reliability listener for forced modals
    if (true) {
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

    }

    return PremiumScaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      drawer: useSidebar
          ? null
          : const CustomDrawer(activeRoute: 'Dashboard'),
      floatingActionButton: const _DashboardFabRow(),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppTheme.lavenderBlueGradient,
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth > 600;
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        DashboardAppBar(theme: theme, name: userName),
                        StatsGridSection(userId: userId, isTablet: isTablet),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 0,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Recent Activity',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  TextButton(onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => AllWorkHistoryPage()));
                                  }, child: const Text("View All", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, decorationColor: Colors.white)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              RecentActivitySection(userId: userId),
                            ])
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
          ],
        ),
      ),
    );
  }

}

class DashboardAppBar extends StatelessWidget {
  final ThemeData theme;
  final String? name;

  const DashboardAppBar({
    super.key,
    required this.theme,
    this.name,
  });

  @override
  Widget build(BuildContext context) {
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
            MaterialPageRoute(builder: (_) => const SettingsPage()),
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
        child: RepaintBoundary(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(color: Colors.amber),
            ),
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
            title: 'Total Work',
            value: '${stats.totalQuotes}',
            icon: Icons.history,
            color: Colors.blue,
            destination: const AllWorkHistoryPage(),
          ),
          SummaryCard(
            title: 'Pending Jobs',
            value: '${stats.pendingJob}',
            icon: Icons.engineering,
            color: Colors.orange,
            destination: const AllWorkHistoryPage(), // Fallback destination
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
      loading: () => const RepaintBoundary(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: CircularProgressIndicator(color: Colors.amber),
          ),
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
