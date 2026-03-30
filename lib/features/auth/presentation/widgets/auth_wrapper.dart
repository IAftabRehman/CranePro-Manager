import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/login_notifier.dart';
import '../pages/pending_approval_page.dart';
import '../pages/role_selection_page.dart';
import '../../admin/presentation/pages/admin_control_page.dart';
import '../../dashboard/presentation/pages/main_dashboard.dart';
import '../../../core/themes/app_theme.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const RoleSelectionPage();
        }

        final userProfile = ref.watch(currentUserProvider);

        return userProfile.when(
          data: (profile) {
            if (profile == null) {
              return const RoleSelectionPage();
            }

            // Approval Guard
            bool isApproved = profile.isAdminApproved || profile.role == 'admin';

            if (isApproved) {
              if (profile.role == 'admin') {
                return const AdminControlPage();
              } else {
                return const MainDashboard();
              }
            } else {
              return const PendingApprovalPage();
            }
          },
          loading: () => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.deepNavyBlue),
            ),
          ),
          error: (err, _) => Scaffold(
            body: Center(
              child: Text('Profile Error: $err'),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.deepNavyBlue),
        ),
      ),
      error: (err, _) => Scaffold(
        body: Center(
          child: Text('Auth Error: $err'),
        ),
      ),
    );
  }
}
