import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/features/auth/data/models/user_model.dart';
import 'package:extend_crane_services/features/admin/presentation/widgets/admin_approval_view.dart';
import 'package:extend_crane_services/features/admin/presentation/widgets/admin_directory_view.dart';
import 'package:extend_crane_services/features/admin/presentation/pages/admin_financial_dashboard.dart';
import 'package:extend_crane_services/features/admin/presentation/pages/admin_export_page.dart';
import 'package:extend_crane_services/features/admin/presentation/pages/admin_activity_logs_page.dart';
import 'package:extend_crane_services/features/admin/presentation/pages/admin_audit_trail_page.dart';
import 'package:extend_crane_services/features/admin/presentation/pages/admin_backup_page.dart';
import 'package:extend_crane_services/features/auth/presentation/pages/role_selection_page.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_button.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_text_field.dart';

class AdminControlPage extends StatefulWidget {
  const AdminControlPage({super.key});

  @override
  State<AdminControlPage> createState() => _AdminControlPageState();
}

class _AdminControlPageState extends State<AdminControlPage> {
  int _currentIndex = 0;

  final List<UserModel> _users = [
    UserModel(
      id: '1',
      fullName: 'Bahadar Khan',
      email: 'bahadar@cranepro.ae',
      role: 'admin',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      isAdminApproved: true,
      lastLogin: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    UserModel(
      id: '2',
      fullName: 'Aftab Rehman',
      email: 'aftab@cranepro.ae',
      role: 'operator',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      isAdminApproved: true,
      totalQuotations: 124,
      lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    UserModel(
      id: '3',
      fullName: 'John Doe',
      email: 'john@alfajr.com',
      role: 'operator',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      isAdminApproved: false,
    ),
    UserModel(
      id: '4',
      fullName: 'Jane Smith',
      email: 'jane@emaar.ae',
      role: 'viewer',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isAdminApproved: false,
    ),
    UserModel(
      id: '5',
      fullName: 'Ali Qasim',
      email: 'ali@binladin.com',
      role: 'viewer',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      isAdminApproved: true,
      lastLogin: DateTime.now().subtract(const Duration(hours: 24)),
    ),
  ];

  void _handleApprove(UserModel user) {
    setState(() {
      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index] = _users[index].copyWith(
          isAdminApproved: true,
          rejectionReason: null,
        );
      }
    });
  }

  void _handleReject(UserModel user) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          content: Container(
            width: 340,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              // --- AAPKA GRADIENT YAHAN HAI ---
              gradient: AppTheme.premiumGradient,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.person_remove_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Reason for Rejection',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mention why ${user.fullName} is being rejected:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Input Field
                  CraneInput(
                    controller: reasonController,
                    hintText: 'Reason of Rejection...',
                    maxLines: 3,
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      rejectionButtons(
                        context,
                        "Cancel",
                        Colors.red,
                        () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 10),
                      rejectionButtons(
                        context,
                        "Reject & Send",
                        Colors.green,
                        () {
                          if (reasonController.text.trim().isEmpty) return;
                          setState(() {
                            final index = _users.indexWhere(
                              (u) => u.id == user.id,
                            );
                            if (index != -1) {
                              _users[index] = _users[index].copyWith(
                                isAdminApproved: false,
                                rejectionReason: reasonController.text,
                              );
                            }
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Expanded rejectionButtons(
    BuildContext context,
    String title,
    Color color,
    GestureDragCancelCallback onTap,
  ) {
    return Expanded(
      child: TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }

  void _handleToggleBlock(UserModel user, bool isBlocked) {
    setState(() {
      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index] = _users[index].copyWith(isBlocked: isBlocked);
      }
    });
  }

  void _handleLogout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const AdminFinancialDashboard(),
      _buildUserManagementModule(),
      const AdminActivityLogsPage(),
      const AdminExportPage(),
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
            color: Colors.blue.withOpacity(0.5),
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
        selectedIconTheme: IconThemeData(
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

  Widget _buildHeader() {
    final titles = [
      'Financial Overview',
      'User Management',
      'Live Activity Tracker',
      'Report Export Hub',
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

  Widget _buildUserManagementModule() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Directory'),
            ],
            labelColor: Colors.black,
            indicatorColor: Colors.black,
            labelStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                AdminApprovalView(
                  users: _users,
                  onApprove: _handleApprove,
                  onReject: _handleReject,
                  onToggleBlock: _handleToggleBlock,
                ),
                AdminDirectoryView(
                  users: _users,
                  onToggleBlock: _handleToggleBlock,
                ),
              ],
            ),
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
