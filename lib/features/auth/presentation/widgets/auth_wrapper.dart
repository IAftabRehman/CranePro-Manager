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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const RoleSelectionPage();
        }

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              // If user is authenticated but doc doesn't exist yet, we might be mid-registration
              return const RoleSelectionPage();
            }

            final userData = userSnapshot.data!.data() as Map<String, dynamic>;
            
            // TASK 3: Debug Print
            print("Checking Role: ${userData['role']}");

            final role = userData['role'];
            final isAdminApproved = userData['isAdminApproved'] ?? false;
            final isBlocked = userData['isBlocked'] ?? false;

            debugPrint("AuthWrapper: User ${user.email} Role: $role, Approved: $isAdminApproved, Blocked: $isBlocked");

            // Security Layer: Block Guard
            if (isBlocked) {
              return BlockedAccountPage(user: UserModel.fromMap(userData));
            }

            if (role == 'admin') {
              return const AdminControlPage();
            } else if (isAdminApproved == true) {
              if (role == 'viewer') {
                return const ViewerDashboard();
              }
              return const MainDashboard();
            } else {
              return const WaitingRoomPage();
            }
          },
        );
      },
    );
  }
}
