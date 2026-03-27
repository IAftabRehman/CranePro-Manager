import 'package:flutter/material.dart';
import 'package:extend_crane_services/features/quotation/presentation/pages/add_quotation_page.dart';
import 'package:extend_crane_services/features/operations/presentation/pages/daily_log_page.dart';
import 'package:extend_crane_services/features/maintenance/presentation/pages/add_expense_page.dart';
import 'package:extend_crane_services/features/reports/presentation/pages/earnings_report_page.dart';
import 'package:extend_crane_services/features/notifications/presentation/pages/notification_screen.dart';
import 'package:extend_crane_services/features/settings/presentation/pages/settings_page.dart';
import 'package:extend_crane_services/core/presentation/widgets/custom_drawer.dart';
import 'package:extend_crane_services/shared/global_widgets/premium_background.dart';

import '../../../../core/utils/responsive.dart';

class MainDashboard extends StatelessWidget {
  const MainDashboard({super.key});

  Widget _buildSummaryCard(BuildContext context, String title, String value, IconData icon, Color color, [Widget? destination]) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: InkWell(
        onTap: destination != null ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => destination)) : null,
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            padding: EdgeInsets.all(Responsive.scale(context, 16).clamp(12.0, 24.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Colors.white, size: Responsive.scale(context, 28).clamp(24.0, 36.0)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontSize: Responsive.scale(context, 24).clamp(20.0, 32.0),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                        fontSize: Responsive.scale(context, 12).clamp(10.0, 14.0),
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

  Widget _buildRecentQuoteTile(BuildContext context, String client, String site, String amount, String date) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
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
          child: const Icon(Icons.precision_manufacturing, color: Colors.white),
        ),
        title: Text(
          client,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(
          site,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white70),
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
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white60),
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
      drawer: useSidebar ? null : const CustomDrawer(activeRoute: 'Dashboard'),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddQuotationPage()),
          );
        },
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: theme.colorScheme.primary,
        elevation: 6,
        child: const Icon(Icons.add, size: 30),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          final crossAxisCount = isTablet ? 4 : 2;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200), // Max width for very large iPad Pro / Desktop
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: Responsive.scale(context, 120).clamp(100.0, 160.0),
                    floating: true,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    actions: [
                      IconButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
                        icon: const Icon(Icons.notifications_active_outlined, color: Colors.white, size: 24),
                      ),
                      IconButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
                        icon: const Icon(Icons.person_outline, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 8),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: EdgeInsets.only(
                        left: Responsive.scale(context, 24).clamp(16.0, 32.0),
                        bottom: 16,
                      ),
                      title: Text(
                        'Good Morning, Aftab 👋',
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                          fontSize: Responsive.scale(context, 20).clamp(16.0, 24.0),
                        ),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.scale(context, 24).clamp(16.0, 32.0),
                      vertical: Responsive.scale(context, 24).clamp(16.0, 32.0),
                    ),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.0, 
                      ),
                      delegate: SliverChildListDelegate([
                        _buildSummaryCard(context, 'Total Quotes', '142', Icons.request_quote, theme.colorScheme.primary),
                        _buildSummaryCard(context, 'Active Jobs', '18', Icons.engineering, theme.colorScheme.secondary, const DailyLogPage()),
                        _buildSummaryCard(context, 'Maintenance', '3', Icons.build, Colors.redAccent, const AddExpensePage()),
                        _buildSummaryCard(context, 'Earnings', '\$42k', Icons.monetization_on, Colors.green, const EarningsReportPage()),
                      ]),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.scale(context, 24).clamp(16.0, 32.0),
                    ).copyWith(bottom: 100), // Padding to avoid FAB overlapping lists
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Text(
                          'Recent Quotations',
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: Responsive.scale(context, 20).clamp(18.0, 24.0),
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildRecentQuoteTile(context, 'Emaar Constructions', 'Downtown Dubai', '\$4,500', 'Today, 10:30 AM'),
                        _buildRecentQuoteTile(context, 'Al-Nakheel Group', 'Palm Jumeirah', '\$12,000', 'Yesterday, 2:15 PM'),
                        _buildRecentQuoteTile(context, 'Binladin Contracting', 'Jeddah Tower', '\$85,000', 'Mar 24'),
                        _buildRecentQuoteTile(context, 'City Transport Co.', 'Warehouse 42', '\$1,200', 'Mar 22'),
                      ]),
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
