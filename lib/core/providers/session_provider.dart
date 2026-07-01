import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the role selected by the user on the Role Selection screen.
/// Values: 'operator' | 'viewer' | null (not yet selected)
class SessionNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setRole(String role) => state = role;
  void clear() => state = null;
}

final selectedRoleProvider =
    NotifierProvider<SessionNotifier, String?>(SessionNotifier.new);
