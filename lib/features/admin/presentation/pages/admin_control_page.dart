import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/core/data/models/user_model.dart';
import 'package:extend_crane_services/features/admin/presentation/widgets/admin_approval_view.dart';
import 'package:extend_crane_services/features/admin/presentation/widgets/admin_directory_view.dart';
import 'package:extend_crane_services/features/admin/presentation/pages/admin_financial_dashboard.dart';
import 'package:extend_crane_services/features/admin/presentation/pages/admin_export_page.dart';
import 'package:extend_crane_services/features/admin/presentation/pages/admin_activity_logs_page.dart';
import 'package:extend_crane_services/features/admin/presentation/pages/admin_audit_trail_page.dart';
import 'package:extend_crane_services/features/admin/presentation/pages/admin_backup_page.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_button.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_text_field.dart';

class AdminControlPage extends StatefulWidget {
  const AdminControlPage({super.key});

  @override
  State<AdminControlPage> createState() => _AdminControlPageState();
}

class _AdminControlPageState extends State<AdminControlPage> {
  // Real User Models with added statistics
  final List<UserModel> _users = [
    UserModel(
      id: '1',
      fullName: 'Bahadar Khan',
      email: 'bahadar@cranepro.ae',
      role: UserRole.admin,
      signupDate: DateTime.now().subtract(const Duration(days: 60)),
      isAdminApproved: true,
      lastLogin: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    UserModel(
      id: '2',
      fullName: 'Aftab Rehman',
      email: 'aftab@cranepro.ae',
      role: UserRole.operator,
      signupDate: DateTime.now().subtract(const Duration(days: 30)),
      isAdminApproved: true,
      totalQuotations: 124,
      lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    UserModel(
      id: '3',
      fullName: 'John Doe',
      email: 'john@alfajr.com',
      role: UserRole.operator,
      signupDate: DateTime.now().subtract(const Duration(hours: 5)),
      isAdminApproved: false,
    ),
    UserModel(
      id: '4',
      fullName: 'Jane Smith',
      email: 'jane@emaar.ae',
      role: UserRole.viewer,
      signupDate: DateTime.now().subtract(const Duration(hours: 2)),
      isAdminApproved: false,
    ),
    UserModel(
      id: '5',
      fullName: 'Ali Qasim',
      email: 'ali@binladin.com',
      role: UserRole.viewer,
      signupDate: DateTime.now().subtract(const Duration(days: 10)),
      isAdminApproved: true,
      lastLogin: DateTime.now().subtract(const Duration(hours: 24)),
    ),
  ];

  void _handleApprove(UserModel user) {
    setState(() {
      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index] = _users[index].copyWith(isAdminApproved: true, rejectionReason: null);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${user.fullName} Approved!'), backgroundColor: Colors.green),
    );
  }

  void _handleReject(UserModel user) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            'Reject User Request',
            style: TextStyle(color: AppTheme.deepNavyBlue, fontWeight: FontWeight.w900),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter reason for rejecting ${user.fullName}:', style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 16),
              CraneInput(
                controller: reasonController,
                hintText: 'e.g. Unknown Identity',
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            CraneButton(
              text: 'Send & Reject',
              onPressed: () {
                if (reasonController.text.isEmpty) return;
                setState(() {
                  final index = _users.indexWhere((u) => u.id == user.id);
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${user.fullName} ${isBlocked ? 'Blocked' : 'Unblocked'}!'),
        backgroundColor: isBlocked ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
                const TabBar(
                  tabs: [
                    Tab(text: 'PENDING APPROVAL'),
                    Tab(text: 'USER DIRECTORY'),
                  ],
                  labelColor: AppTheme.deepNavyBlue,
                  indicatorColor: AppTheme.deepNavyBlue,
                  labelStyle: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0, fontSize: 13),
                  unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
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
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.deepNavyBlue, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'ADMIN TERMINAL',
              style: TextStyle(
                color: AppTheme.deepNavyBlue,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.monetization_on_outlined, color: AppTheme.deepNavyBlue, size: 22),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminFinancialDashboard()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.description_outlined, color: AppTheme.deepNavyBlue, size: 22),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminExportPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppTheme.deepNavyBlue, size: 22),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminActivityLogsPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.manage_search_rounded, color: AppTheme.deepNavyBlue, size: 22),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminAuditTrailPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.cloud_sync_rounded, color: AppTheme.deepNavyBlue, size: 22),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminBackupPage()),
            ),
          ),
        ],
      ),
    );
  }
}
