import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/features/quotation/presentation/pages/add_quotation_page.dart';
import 'package:extend_crane_services/features/dashboard/presentation/pages/main_dashboard.dart';
import 'package:extend_crane_services/features/operations/presentation/pages/daily_log_page.dart';
import 'package:extend_crane_services/features/maintenance/presentation/pages/maintenance_history_page.dart';
import 'package:extend_crane_services/features/reports/presentation/pages/earnings_report_page.dart';

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
            _buildHeader(theme, context),

            // Navigation Links
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  _buildNavItem(context, Icons.dashboard_outlined, 'Dashboard', theme),
                  _buildNavItem(context, Icons.file_copy_outlined, 'Generate Quotation', theme),
                  _buildNavItem(context, Icons.flash_on_outlined, 'Direct Work Entry', theme),
                  _buildNavItem(context, Icons.build_circle_outlined, 'Maintenance & Expenses', theme),
                  _buildNavItem(context, Icons.bar_chart_outlined, 'Reports & Analytics', theme),
                ],
              ),
            ),

            // Bottom Logout
            const Divider(),
            _buildLogoutItem(context, theme),
          ],
        ),
      ),
    ));
  }

  Widget _buildHeader(ThemeData theme, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(Icons.architecture, color: theme.colorScheme.primary, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'Aftab Ur Rehman',
            style: theme.textTheme.displayLarge?.copyWith(color: Colors.white, fontSize: 18),
          ),
          Text(
            'Admin • Al-Fajr Cranes',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String title, ThemeData theme, {bool isAdminOnly = false}) {
    // In a real app, check user role here
    final isSelected = activeRoute == title;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        onTap: () {
          Navigator.pop(context); // Close drawer first
          if (isSelected) return;

          Widget destination;
          switch (title) {
            case 'Dashboard':
              destination = const MainDashboard();
              break;
            case 'Generate Quotation':
              destination = const AddQuotationPage();
              break;
            case 'Direct Work Entry':
              // This is usually a modal, but for drawer menu we can link to a list or the modal trigger
              // For now, let's keep it simple or redirect to dashboard with modal trigger
              destination = const MainDashboard(); 
              break;
            case 'Maintenance & Expenses':
              destination = const MaintenanceHistoryPage();
              break;
            case 'Reports & Analytics':
              destination = const EarningsReportPage();
              break;
            default:
              return;
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => destination),
          );
        },
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

  Widget _buildLogoutItem(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListTile(
        onTap: () {
           Navigator.pop(context);
           Navigator.of(context).popUntil((route) => route.isFirst);
        },
        leading: const Icon(Icons.logout, color: Colors.redAccent),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
