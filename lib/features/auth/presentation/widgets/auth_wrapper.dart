import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/pending_approval_page.dart';
import '../pages/role_selection_page.dart';
import '../pages/blocked_account_page.dart';
import '../../../admin/presentation/pages/admin_control_page.dart';
import '../../../dashboard/presentation/pages/main_dashboard.dart';
import '../../data/models/user_model.dart';
import '../../../../core/themes/app_theme.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          debugPrint("AuthWrapper: AuthState is WAITING...");
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.deepNavyBlue),
            ),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          debugPrint("AuthWrapper: No user found. Routing to RoleSelectionPage.");
          return const RoleSelectionPage();
        }

        debugPrint("AuthWrapper: User logged in: ${user.uid}. Listening to Firestore profile...");

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              debugPrint("AuthWrapper: Firestore profile stream - WAITING...");
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: AppTheme.deepNavyBlue),
                ),
              );
            }

            if (userSnapshot.hasError) {
              debugPrint("AuthWrapper: Firestore Error: ${userSnapshot.error}");
              return Scaffold(
                body: Center(child: Text('Database Error: ${userSnapshot.error}')),
              );
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              debugPrint("AuthWrapper: [MISSING PROFILE] UID: ${user.uid} authenticated but doc not found.");
              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off_rounded, size: 64, color: Colors.amber),
                      SizedBox(height: 16),
                      Text("Profile Not Found", style: TextStyle(color: Colors.white, fontSize: 18)),
                      SizedBox(height: 8),
                      Text("Contact support if you believe this is an error.", style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              );
            }

            final userData = userSnapshot.data!.data() as Map<String, dynamic>;
            final currentUser = UserModel.fromMap(userData);
            
            final role = currentUser.role;
            final isAdminApproved = currentUser.isAdminApproved;
            final isBlocked = currentUser.isBlocked;

            debugPrint("Current User Role from Firestore: $role (Approved: $isAdminApproved, Blocked: $isBlocked)");

            // CRITICAL: Block Guard
            if (isBlocked) {
              debugPrint("AuthWrapper: Account BLOCKED. Routing to BlockedAccountPage");
              return BlockedAccountPage(user: currentUser);
            }

            if (role == 'admin') {
              debugPrint("AuthWrapper: Routing to AdminControlPage");
              return const AdminControlPage();
            } else if (isAdminApproved == true) {
              debugPrint("AuthWrapper: Routing to MainDashboard");
              return const MainDashboard();
            } else {
              debugPrint("AuthWrapper: Routing to PendingApprovalPage with User Data");
              return PendingApprovalPage(user: currentUser);
            }
          },
        );
      },
    );
  }
}
