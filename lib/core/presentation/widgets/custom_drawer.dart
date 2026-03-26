import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';

class CustomDrawer extends StatelessWidget {
  final String activeRoute;
  const CustomDrawer({super.key, this.activeRoute = 'Dashboard'});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final drawerWidth = Responsive.isTablet(context) ? 300.0 : Responsive.screenWidth(context) * 0.75;

    return Drawer(
      width: drawerWidth,
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
                  _buildNavItem(context, Icons.file_copy_outlined, 'Quotation Manager', theme),
                  _buildNavItem(context, Icons.calendar_today_outlined, 'Daily Work Logs', theme),
                  _buildNavItem(context, Icons.settings_suggest_outlined, 'Expense & Maintenance', theme),
                  _buildNavItem(context, Icons.bar_chart_outlined, 'Reports & Analytics', theme),
                  
                  // Role-based Admin Link (Conditional)
                  _buildNavItem(context, Icons.admin_panel_settings_outlined, 'Admin Panel', theme, isAdminOnly: true),
                ],
              ),
            ),

            // Bottom Logout
            const Divider(),
            _buildLogoutItem(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
          // Navigation logic would go here
        },
        leading: Icon(
          icon,
          color: isSelected ? theme.colorScheme.secondary : theme.colorScheme.primary,
          size: 24,
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? theme.colorScheme.secondary : theme.colorScheme.primary,
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
