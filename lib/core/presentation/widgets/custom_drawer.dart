import 'package:extend_crane_services/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/features/dashboard/presentation/pages/main_dashboard.dart';
import 'package:extend_crane_services/features/maintenance/presentation/pages/maintenance_history_page.dart';
import 'package:extend_crane_services/features/reports/presentation/pages/earnings_report_page.dart';
import '../../../features/reports/presentation/pages/all_work_history_page.dart';


class CustomDrawer extends StatelessWidget {
  final String activeRoute;
  const CustomDrawer({super.key, this.activeRoute = 'Dashboard'});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final drawerWidth = Responsive.isTablet(context) ? 300.0 : Responsive.screenWidth(context) * 0.75;

    return Drawer(
      width: drawerWidth,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.premiumGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Drawer Header
              DrawerHeaderWidget(theme: theme),

              // Navigation Links
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: [
                        _NavItem(icon: Icons.dashboard_outlined, title: 'Dashboard', theme: theme, activeRoute: activeRoute),
                        _NavItem(icon: Icons.history_edu_outlined, title: 'Total Work History', theme: theme, activeRoute: activeRoute),
                        _NavItem(icon: Icons.build_circle_outlined, title: 'Maintenance & Expenses', theme: theme, activeRoute: activeRoute),
                        _NavItem(icon: Icons.bar_chart_outlined, title: 'Reports & Analytics', theme: theme, activeRoute: activeRoute),
                        _NavItem(icon: Icons.person, title: 'Profile', theme: theme, activeRoute: activeRoute),
                      ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final ThemeData theme;
  final String activeRoute;

  const _NavItem({
    required this.icon,
    required this.title,
    required this.theme,
    required this.activeRoute,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = activeRoute == title;
    return DrawerNavItem(
      icon: icon,
      title: title,
      theme: theme,
      isSelected: isSelected,
      onTap: () {
        Navigator.pop(context); // Close drawer first
        if (isSelected) return;

        Widget destination;
        switch (title) {
          case 'Dashboard':
            destination = const MainDashboard();
            break;
          case 'Total Work History':
            destination = const AllWorkHistoryPage();
            break;
          case 'Reports & Analytics':
            destination = const EarningsReportPage();
            break;
          case 'Maintenance & Expenses':
            destination = const MaintenanceHistoryPage();
            break;
          case 'Profile':
            destination = const SettingsPage();
            break;
          default:
            return;
        }

        if (title == 'Dashboard') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => destination),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destination),
          );
        }
      },
    );
  }
}

class DrawerHeaderWidget extends StatelessWidget {
  final ThemeData theme;

  const DrawerHeaderWidget({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Color(0x26FFEB3B),
        border: Border(bottom: BorderSide(color: Color(0x1AFFFFFF))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aftab Ur Rehman',
            style: theme.textTheme.displayLarge?.copyWith(color: Colors.white, fontSize: 18),
          ),
          Text(
            'Admin • 0332 3220916',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class DrawerNavItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final ThemeData theme;
  final bool isSelected;
  final VoidCallback onTap;

  const DrawerNavItem({
    super.key,
    required this.icon,
    required this.title,
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: isSelected ? theme.colorScheme.secondary : Colors.white70,
          size: 24,
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? theme.colorScheme.secondary : Colors.white,
          ),
        ),
        selected: isSelected,
        selectedTileColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

