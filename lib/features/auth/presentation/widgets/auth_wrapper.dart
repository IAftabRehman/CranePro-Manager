import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:extend_crane_services/core/providers/session_provider.dart';
import '../pages/role_selection_page.dart';
import '../../../dashboard/presentation/pages/main_dashboard.dart';
import '../../../dashboard/presentation/pages/viewer_dashboard.dart';

/// Simple router that replaces the old Firebase-Auth-based AuthWrapper.
/// No login, no Firestore user lookup — just reads the selected role
/// from [selectedRoleProvider] and routes accordingly.
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(selectedRoleProvider);

    return switch (role) {
      'operator' => const MainDashboard(isViewer: false),
      'viewer'   => const ViewerDashboard(),
      _          => const RoleSelectionPage(),
    };
  }
}
