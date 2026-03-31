import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/features/admin/presentation/pages/admin_financial_dashboard.dart';
import 'package:extend_crane_services/features/admin/presentation/pages/admin_reports_page.dart';
import 'package:extend_crane_services/features/admin/presentation/pages/admin_activity_logs_page.dart';
import 'package:extend_crane_services/features/admin/presentation/pages/admin_audit_trail_page.dart';
import 'package:extend_crane_services/features/admin/presentation/pages/admin_backup_page.dart';
import 'package:extend_crane_services/features/admin/presentation/pages/user_management_page.dart';
import 'package:extend_crane_services/features/admin/presentation/pages/fleet_management_page.dart';

class AdminControlPage extends StatefulWidget {
  const AdminControlPage({super.key});

  @override
  State<AdminControlPage> createState() => _AdminControlPageState();
}

class _AdminControlPageState extends State<AdminControlPage> {
  int _currentIndex = 0;

  void _handleLogout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const AdminFinancialDashboard(),
      const UserManagementPage(),
      const FleetManagementPage(),
      const AdminActivityLogsPage(),
      const AdminReportsPage(),
      _buildSecurityModule(),
    ];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.lavenderBlueGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: IndexedStack(index: _currentIndex, children: pages),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black26,
        selectedItemColor: Colors.green,
        iconSize: 20,
        selectedIconTheme: const IconThemeData(
          size: 30
        ),
        unselectedItemColor: Colors.white,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 16,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.construction_rounded),
            label: 'Fleet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_edu_rounded),
            label: 'Logs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment_outlined),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.security_rounded),
            label: 'Security',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final titles = [
      'Financial Overview',
      'User Management',
      'Fleet & Crane Management',
      'Live Activity Tracker',
      'Advanced Reports & Search',
      'Security & Data Hub',
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titles[_currentIndex],
            style: const TextStyle(
              color: AppTheme.deepNavyBlue,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.logout_sharp,
              color: AppTheme.deepNavyBlue,
              size: 25,
            ),
            onPressed: _handleLogout,
          ),
        ],
      ),
    );
  }


  Widget _buildSecurityModule() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'BackUp'),
              Tab(text: 'Audit'),
            ],
            labelColor: Colors.black,
            indicatorColor: Colors.black,
            labelStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
          ),
          const Expanded(
            child: TabBarView(
              children: [AdminBackupPage(), AdminAuditTrailPage()],
            ),
          ),
        ],
      ),
    );
  }
}
