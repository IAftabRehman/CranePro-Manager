import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/waiting_room_page.dart';
import '../pages/role_selection_page.dart';
import '../pages/blocked_account_page.dart';
import '../../../admin/presentation/pages/admin_control_page.dart';
import '../../../dashboard/presentation/pages/main_dashboard.dart';
import '../../../dashboard/presentation/pages/viewer_dashboard.dart';
import '../../data/models/user_model.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Auth Stream Error: ${snapshot.error}')),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const RoleSelectionPage();
        }

        // Use a stream on the user's UID doc first.
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.hasError) {
              return Scaffold(
                body: Center(child: Text('Firestore Stream Error: ${userSnapshot.error}')),
              );
            }

            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // If the UID-based doc doesn't exist, the Firestore doc was likely
            // stored under a different ID. Fall back to an email-based lookup.
            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .where('email', isEqualTo: user.email)
                    .limit(1)
                    .get(),
                builder: (context, emailSnapshot) {
                  if (emailSnapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!emailSnapshot.hasData ||
                      emailSnapshot.data!.docs.isEmpty) {
                    // Truly no user doc — go back to role selection
                    return const RoleSelectionPage();
                  }
                  final userData = emailSnapshot.data!.docs.first.data()
                      as Map<String, dynamic>;
                  return _routeFromUserData(userData);
                },
              );
            }

            final userData =
                userSnapshot.data!.data() as Map<String, dynamic>;
            return _routeFromUserData(userData);
          },
        );
      },
    );
  }

  /// Determines the correct page based on the user's Firestore data.
  Widget _routeFromUserData(Map<String, dynamic> userData) {
    final role = userData['role'] as String?;
    final isAdminApproved = userData['isAdminApproved'] as bool? ?? false;
    final isBlocked = userData['isBlocked'] as bool? ?? false;

    // Security Layer: Block Guard
    if (isBlocked) {
      return BlockedAccountPage(user: UserModel.fromMap(userData));
    }

    if (role == 'admin') {
      return const AdminControlPage();
    } else if (role == 'viewer') {
      return const ViewerDashboard();
    } else if (isAdminApproved) {
      return const MainDashboard();
    } else {
      return const WaitingRoomPage();
    }
  }
}
