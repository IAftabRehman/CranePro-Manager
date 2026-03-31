import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/login_notifier.dart';

class RoleGuard extends ConsumerWidget {
  final Widget child;
  final List<String> allowedRoles;
  final Widget? fallback;

  const RoleGuard({
    super.key,
    required this.child,
    required this.allowedRoles,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(currentUserProvider);

    return userProfile.when(
      data: (profile) {
        if (profile != null && allowedRoles.contains(profile.role)) {
          return child;
        }
        
        return fallback ?? _buildAccessDenied(context);
      },
      loading: () => const SizedBox.shrink(), // Silent loading for guards
      error: (_, __) => fallback ?? _buildAccessDenied(context),
    );
  }

  Widget _buildAccessDenied(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_person_rounded, size: 80, color: Colors.redAccent),
            const SizedBox(height: 24),
            const Text(
              'ACCESS DENIED',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'You do not have permission to access this feature.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('GO BACK'),
            ),
          ],
        ),
      ),
    );
  }
}
