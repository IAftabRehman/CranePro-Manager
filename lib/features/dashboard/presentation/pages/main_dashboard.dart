import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extend_crane_services/features/auth/presentation/pages/splash_screen_page.dart';
import 'package:extend_crane_services/features/operations/presentation/widgets/direct_work_modal.dart';
import '../../../../core/themes/app_theme.dart';
import 'package:extend_crane_services/features/reports/presentation/pages/earnings_report_page.dart';
import 'package:extend_crane_services/features/reports/presentation/pages/all_work_history_page.dart';
import 'package:extend_crane_services/core/presentation/widgets/custom_drawer.dart';
import 'package:extend_crane_services/shared/global_widgets/premium_background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../features/finance/data/repositories/finance_repository.dart';
import '../../../../features/quotation/data/repositories/quotation_repository.dart';
import '../../../maintenance/presentation/pages/maintenance_history_page.dart';
import '../../../quotation/presentation/pages/add_quotation_page.dart';

class MainDashboard extends ConsumerStatefulWidget {
  const MainDashboard({super.key});

  @override
  ConsumerState<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends ConsumerState<MainDashboard>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _pulseController;
  String _role = 'operator';
  String? _viewerName;
  String? _operatorId;
  String? _loginPassword;

  @override
  void initState() {
    super.initState();
    _loadUserSession();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _role = prefs.getString('role') ?? 'operator';
      _viewerName = prefs.getString('viewer_name');
      _operatorId = prefs.getString('operator_id');
      _loginPassword = prefs.getString('login_password');
    });

    if (_role == 'viewer') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkFirstTimeViewerDialog(prefs);
      });
    }
  }

  Future<void> _checkFirstTimeViewerDialog(SharedPreferences prefs) async {
    final hasSeen = prefs.getBool('has_seen_viewer_disclaimer') ?? false;
    if (!hasSeen) {
      _showViewerDisclaimerDialog(prefs);
    }
  }

  void _showViewerDisclaimerDialog(SharedPreferences prefs) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2240),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.white24),
          ),
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber, size: 24),
              SizedBox(width: 8),
              Text(
                'Viewer Mode',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'You are logged in as a Viewer. You can only see the report details, work history, and analytics. Editing or adding new records is not allowed.',
            style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.4),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'I Understand',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                await prefs.setBool('has_seen_viewer_disclaimer', true);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Logic removed
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildBlockedScreen({bool isPasswordChanged = false}) {
    return Scaffold(
      backgroundColor: const Color(0xFF121224),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0x1AFF5252),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPasswordChanged ? Icons.vpn_key_rounded : Icons.block_flipped,
                  size: 80,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                isPasswordChanged ? 'Session Expired' : 'Access Restricted',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isPasswordChanged
                    ? 'Your password was changed by the administrator. Please log in again with your new password.'
                    : 'Your account has been deactivated or blocked by the administrator. Please contact support through\n(+92 3323220916)',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String userId = '';

    final screenWidth = MediaQuery.of(context).size.width;
    final useSidebar = screenWidth > 900;

    final Widget mainContent = _role == 'viewer'
        ? DefaultTabController(
            length: 3,
            child: PremiumScaffold(
              appBar: AppBar(
                title: const Text(
                  'Viewer Dashboard',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                centerTitle: true,
                backgroundColor: const Color(0xFF1E2240),
                elevation: 4,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const SplashScreenPage()),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],
                bottom: const TabBar(
                  indicatorColor: Colors.amber,
                  labelColor: Colors.amber,
                  unselectedLabelColor: Colors.white70,
                  tabs: [
                    Tab(icon: Icon(Icons.bar_chart), text: 'Analytics'),
                    Tab(icon: Icon(Icons.history), text: 'Work History'),
                    Tab(icon: Icon(Icons.build), text: 'Maintenance'),
                  ],
                ),
              ),
              body: const TabBarView(
                physics: BouncingScrollPhysics(),
                children: [
                  EarningsReportPage(isEmbedded: true),
                  AllWorkHistoryPage(isEmbedded: true),
                  MaintenanceHistoryPage(isEmbedded: true),
                ],
              ),
            ),
          )
        : PremiumScaffold(
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            drawer: useSidebar ? null : const CustomDrawer(activeRoute: 'Dashboard'),
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
                              DashboardAppBar(
                                theme: theme, 
                                name: _viewerName,
                                role: _role,
                              ),
                              _PendingJobBanner(userId: userId, animation: _pulseController),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Recent Activity',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AllWorkHistoryPage(),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            "View All",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.underline,
                                              decorationColor: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    RecentActivitySection(userId: userId),
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
                ],
              ),
            ),
          );

    final docId = _role == 'viewer' ? _viewerName : _operatorId;
    if (docId == null || docId.isEmpty) {
      return mainContent;
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(docId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null) {
            final isBlocked = (data['isBlocked'] == true || data['userStatus'] == 'blocked');
            if (isBlocked) {
              return _buildBlockedScreen(isPasswordChanged: false);
            }

            if (_role != 'viewer') {
              final dbPassword = data['password']?.toString();
              if (dbPassword != null && dbPassword.isNotEmpty && dbPassword != _loginPassword) {
                return _buildBlockedScreen(isPasswordChanged: true);
              }
            }
          }
        }
        return mainContent;
      },
    );
  }
}

class DashboardAppBar extends StatelessWidget {
  final ThemeData theme;
  final String? name;
  final String? role;

  const DashboardAppBar({super.key, required this.theme, this.name, this.role});

  @override
  Widget build(BuildContext context) {
    String titleText = 'Welcome';
    if (role == 'viewer' && name != null && name!.isNotEmpty) {
      titleText = 'Welcome, $name';
    } else if (role == 'operator') {
      titleText = 'Operator Dashboard';
    }

    return SliverAppBar(
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        titleText,
        style: theme.textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () async {
            // Show logout confirmation
            final bool? confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: const Color(0xFF1A1A2E),
                title: const Text('Log Out', style: TextStyle(color: Colors.white)),
                content: const Text('Are you sure you want to log out?', style: TextStyle(color: Colors.white70)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Log Out', style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // Clear all saved session data
              
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SplashScreenPage()),
                  (route) => false,
                );
              }
            }
          },
          icon: const Icon(Icons.logout, color: Colors.redAccent),
          tooltip: 'Log Out',
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

  const StatsGrid({super.key, required this.stats, required this.isTablet});

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
            destination: const AllWorkHistoryPage(isPendingScreen: true),
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
            value: 'AED ${stats.netBalance.toStringAsFixed(0)}',
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

  const RecentActivitySection({super.key, required this.userId});

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

class _PendingJobBanner extends ConsumerWidget {
  final String userId;
  final Animation<double> animation;

  const _PendingJobBanner({required this.userId, required this.animation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingTask = ref.watch(firstPendingTaskProvider);

    if (pendingTask == null) return const SliverToBoxAdapter(child: SizedBox.shrink());

    final locationText = pendingTask.siteLocation.isNotEmpty ? pendingTask.siteLocation : 'SYSTEM';

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            // Opacity from 0.5 to 1.0 for the pulsing effect
            final opacity = 0.5 + (0.5 * animation.value);
            return Opacity(
              opacity: opacity,
              child: InkWell(
                onTap: () {
                   Navigator.push(context, MaterialPageRoute(builder: (context) => const AllWorkHistoryPage(isPendingScreen: true)));
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD84315), // Deep Orange/Red
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.flash_on, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${locationText.toUpperCase()} UPDATE: New Site Activity: ${pendingTask.clientName} @ $locationText',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
