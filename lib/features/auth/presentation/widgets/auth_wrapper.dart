import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/login_notifier.dart';
import '../pages/pending_approval_page.dart';
import '../pages/role_selection_page.dart';
import '../../../admin/presentation/pages/admin_control_page.dart';
import '../../../dashboard/presentation/pages/main_dashboard.dart';
import '../../../../core/themes/app_theme.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: authState.when(
        data: (user) {
          if (user == null) {
            return const RoleSelectionPage(key: ValueKey('role_selection'));
          }

          final userProfile = ref.watch(currentUserProvider);

          return userProfile.when(
            data: (profile) {
              if (profile == null) {
                return const RoleSelectionPage(key: ValueKey('role_selection_null'));
              }

              // SMART ROUTING LOGIC
              // 1. Admin Bypass & Routing
              if (profile.role == 'admin') {
                return const AdminControlPage(key: ValueKey('admin_panel'));
              }

              // 2. Approval Guard for non-admins
              if (!profile.isAdminApproved) {
                return const PendingApprovalPage(key: ValueKey('pending_approval'));
              }

              // 3. Role-Specific Dashboards
              if (profile.role == 'viewer') {
                return const MainDashboard(
                  key: ValueKey('viewer_dash'),
                  isViewer: true,
                );
              }

              // Default: Operator Dashboard
              return const MainDashboard(key: ValueKey('operator_dash'));
            },
            loading: () => const Scaffold(
              key: ValueKey('loading_profile'),
              body: Center(
                child: CircularProgressIndicator(color: AppTheme.deepNavyBlue),
              ),
            ),
            error: (err, _) => Scaffold(
              key: ValueKey('error_profile'),
              body: Center(
                child: Text('Profile Error: $err'),
              ),
            ),
          );
        },
        loading: () => const Scaffold(
          key: ValueKey('loading_auth'),
          body: Center(
            child: CircularProgressIndicator(color: AppTheme.deepNavyBlue),
          ),
        ),
        error: (err, _) => Scaffold(
          key: ValueKey('error_auth'),
          body: Center(
            child: Text('Auth Error: $err'),
          ),
        ),
      ),
    );
  }
}
