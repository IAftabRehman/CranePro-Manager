import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/features/admin/presentation/pages/admin_financial_dashboard.dart';
import 'package:extend_crane_services/features/admin/presentation/pages/admin_reports_page.dart';
import 'package:extend_crane_services/features/admin/presentation/pages/admin_activity_logs_page.dart';
import 'package:extend_crane_services/features/admin/presentation/pages/admin_audit_trail_page.dart';
import 'package:extend_crane_services/features/admin/presentation/pages/admin_backup_page.dart';
import 'package:extend_crane_services/features/admin/presentation/pages/user_management_page.dart';

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
      const AdminActivityLogsPage(),
      const AdminReportsPage(),
      const AdminSecurityModule(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        if (isWide) {
          return Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppTheme.lavenderBlueGradient,
              ),
              child: Row(
                children: [
                  AdminWebSidebar(
                    currentIndex: _currentIndex,
                    onIndexChanged: (index) => setState(() => _currentIndex = index),
                    onLogout: _handleLogout,
                  ),
                  Expanded(
                    child: SafeArea(
                      child: Column(
                        children: [
                          AdminWebHeader(currentIndex: _currentIndex),
                          Expanded(
                            child: IndexedStack(index: _currentIndex, children: pages),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
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
                    AdminMobileHeader(
                      currentIndex: _currentIndex,
                      onLogout: _handleLogout,
                    ),
                    Expanded(
                      child: IndexedStack(index: _currentIndex, children: pages),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: AdminBottomNav(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
          );
        }
      },
    );
  }
}

class AdminWebSidebar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final VoidCallback onLogout;

  const AdminWebSidebar({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {'title': 'Dashboard', 'icon': Icons.dashboard_rounded},
      {'title': 'User Management', 'icon': Icons.people_alt_rounded},
      {'title': 'Activity Tracker', 'icon': Icons.history_edu_rounded},
      {'title': 'Advanced Reports', 'icon': Icons.assessment_outlined},
      {'title': 'Security Hub', 'icon': Icons.security_rounded},
    ];

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: const Color(0xD90D1B3E),
        border: const Border(
          right: BorderSide(color: Colors.white12, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Row(
              children: [
                const Icon(
                  Icons.engineering_rounded,
                  color: AppTheme.accentGold,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CRANEPRO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        'ADMIN PANEL',
                        style: TextStyle(
                          color: const Color(0xCCFFB300),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = currentIndex == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: InkWell(
                    onTap: () => onIndexChanged(index),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0x26FFB300) 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: const Color(0x66FFB300), width: 1)
                            : Border.all(color: Colors.transparent, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            color: isSelected ? AppTheme.accentGold : Colors.white70,
                            size: 22,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            item['title'] as String,
                            style: TextStyle(
                              color: isSelected ? AppTheme.accentGold : Colors.white70,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                              fontSize: 14,
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
          const Divider(color: Colors.white12, height: 1),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white12,
                      child: Text(
                        'A',
                        style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Administrator',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            'Super User',
                            style: TextStyle(color: Colors.white54, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0x1AFF5252),
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent, width: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.logout_sharp, size: 18),
                  label: const Text('LOGOUT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  onPressed: onLogout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminWebHeader extends StatelessWidget {
  final int currentIndex;

  const AdminWebHeader({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final titles = [
      'Financial Analytics Overview',
      'System Users Management',
      'Global System Activity Logs',
      'Advanced Business Reports',
      'Security & System Backups',
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 24, 30, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titles[currentIndex],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Real-time system state monitoring',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AdminBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AdminBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0x802196F3),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
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
}

class AdminMobileHeader extends StatelessWidget {
  final int currentIndex;
  final VoidCallback onLogout;

  const AdminMobileHeader({
    super.key,
    required this.currentIndex,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final titles = [
      'Financial Overview',
      'User Management',
      'Activity Tracker',
      'Advanced Reports',
      'Security & Data Hub',
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titles[currentIndex],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.logout_sharp,
              color: Colors.white,
              size: 25,
            ),
            onPressed: onLogout,
          ),
        ],
      ),
    );
  }
}

class AdminSecurityModule extends StatelessWidget {
  const AdminSecurityModule({super.key});

  @override
  Widget build(BuildContext context) {
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
            )
          ),
        ],
      ),
    );
  }
}
