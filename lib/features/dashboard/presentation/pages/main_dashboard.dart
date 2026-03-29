import 'package:flutter/material.dart';
import 'package:extend_crane_services/features/operations/presentation/widgets/direct_work_modal.dart';
import '../../../quotation/data/models/quotation_model.dart';
import 'package:extend_crane_services/features/quotation/presentation/pages/add_quotation_page.dart';
import 'package:extend_crane_services/features/maintenance/presentation/pages/maintenance_history_page.dart';
import 'package:extend_crane_services/features/reports/presentation/pages/earnings_report_page.dart';
import 'package:extend_crane_services/features/notifications/presentation/pages/notification_screen.dart';
import 'package:extend_crane_services/features/settings/presentation/pages/settings_page.dart';
import 'package:extend_crane_services/core/presentation/widgets/custom_drawer.dart';
import 'package:extend_crane_services/shared/global_widgets/premium_background.dart';
import '../widgets/midnight_status_modal.dart';

import '../../../../core/utils/responsive.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard>
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

    // TASK 1: Mock 12:00 AM Notification Trigger
    _checkAndShowMidnightPopup();
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
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => MidnightStatusModal(
                    date: DateTime.now().subtract(const Duration(days: 1)),
                    quotation: QuotationData(clientName: 'Street Client'),
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
      elevation: 0,
      color: Colors.transparent,
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
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
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
      elevation: 0,
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: Responsive.scale(context, 16).clamp(16.0, 24.0),
          vertical: 8,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.precision_manufacturing, color: Colors.white),
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
    final screenWidth = Responsive.screenWidth(context);
    final useSidebar = screenWidth > 900;

    return PremiumScaffold(
      drawer: useSidebar ? null : CustomDrawer(activeRoute: 'Dashboard', isViewer: false),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
          const SizedBox(height: 12),
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
      body: Stack(
        children: [
          // TASK 3: Persistent Sticky Red Bar
          if (_pendingCount > 0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Pending Report: Street Client at Musaffah. Update now!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          // Trigger update modal
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'UPDATE NOW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          Padding(
            padding: EdgeInsets.only(top: _pendingCount > 0 ? 60 : 0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth > 600;
                final crossAxisCount = isTablet ? 4 : 2;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [

                        SliverAppBar(
                          expandedHeight: Responsive.scale(
                            context,
                            0,
                          ).clamp(00.0, 00.0),
                          floating: true,
                          pinned: false,
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          title: Text(
                            'Welcome Aftab 👋',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontSize: Responsive.scale(
                                context,
                                10,
                              ).clamp(16.0, 24.0),
                            ),
                          ),
                          actions: [
                            IconButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NotificationScreen(),
                                ),
                              ),
                              icon: const Icon(
                                Icons.notifications_active_outlined,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SettingsPage(),
                                ),
                              ),
                              icon: const Icon(
                                Icons.person_outline,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.scale(
                              context,
                              24,
                            ).clamp(16.0, 32.0),
                            vertical: Responsive.scale(
                              context,
                              24,
                            ).clamp(16.0, 32.0),
                          ),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.0,
                                ),
                            delegate: SliverChildListDelegate([
                              _buildSummaryCard(
                                context,
                                'Total Quotes',
                                '142',
                                Icons.request_quote,
                                theme.colorScheme.primary,
                              ),
                              _buildSummaryCard(
                                context,
                                'Active Jobs',
                                '18',
                                Icons.engineering,
                                theme.colorScheme.secondary,
                                null,
                              ),
                              _buildSummaryCard(
                                context,
                                'Maintenance',
                                '3',
                                Icons.build,
                                Colors.redAccent,
                                const MaintenanceHistoryPage(),
                              ),
                              _buildSummaryCard(
                                context,
                                'Earnings',
                                '\$42k',
                                Icons.monetization_on,
                                Colors.green,
                                const EarningsReportPage(),
                              ),
                            ]),
                          ),
                        ),
                        if (_pendingCount > 0)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                              child: FadeTransition(
                                opacity: Tween<double>(
                                  begin: 0.6,
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
                                        quotation: QuotationData(
                                          clientName: 'Street Client',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withOpacity(
                                        0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.redAccent.withOpacity(
                                          0.5,
                                        ),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.redAccent.withOpacity(
                                            0.2,
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
                                          color: Colors.redAccent,
                                          size: 28,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'ACTION REQUIRED',
                                                style: TextStyle(
                                                  color: Colors.redAccent,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 13,
                                                  letterSpacing: 1.1,
                                                ),
                                              ),
                                              Text(
                                                'Work Update Required for: Street Client',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.redAccent,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.scale(
                              context,
                              24,
                            ).clamp(16.0, 32.0),
                          ).copyWith(bottom: 100),
                          // Padding to avoid FAB overlapping lists
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              const SizedBox(height: 20),
                              Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  'Recent Quotations',
                                  style: theme.textTheme.displayLarge?.copyWith(
                                    fontSize: Responsive.scale(
                                      context,
                                      20,
                                    ).clamp(18.0, 24.0),
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              _buildRecentQuoteTile(
                                context,
                                'Emaar Constructions',
                                'Downtown Dubai',
                                '\$4,500',
                                'Today, 10:30 AM',
                              ),
                              _buildRecentQuoteTile(
                                context,
                                'Al-Nakheel Group',
                                'Palm Jumeirah',
                                '\$12,000',
                                'Yesterday, 2:15 PM',
                              ),
                              _buildRecentQuoteTile(
                                context,
                                'Binladin Contracting',
                                'Jeddah Tower',
                                '\$85,000',
                                'Mar 24',
                              ),
                              _buildRecentQuoteTile(
                                context,
                                'City Transport Co.',
                                'Warehouse 42',
                                '\$1,200',
                                'Mar 22',
                              ),
                            ]),
                          ),
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
  }
}
