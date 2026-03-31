import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_button.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/features/auth/data/models/user_model.dart';

class PendingApprovalPage extends StatelessWidget {
  final UserModel user;
  const PendingApprovalPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final bool isRejected = user.rejectionReason != null;
    final String statusTitle = isRejected ? 'Access Rejected' : 'Verification in Progress';
    
    // Dynamic theme colors
    final Color primaryColor = isRejected ? Colors.redAccent : AppTheme.deepNavyBlue;
    final Color bgColorStart = isRejected ? const Color(0xFF2C0B0B) : const Color(0xFFE8EAF6);
    final Color bgColorEnd = isRejected ? const Color(0xFF000000) : Colors.white;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot return until verified or logged out')),
        );
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [bgColorStart, bgColorEnd],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'logo',
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 120,
                      fit: BoxFit.contain,
                      color: isRejected ? Colors.redAccent.withOpacity(0.5) : null,
                      colorBlendMode: isRejected ? BlendMode.srcATop : null,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  Text(
                    statusTitle,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  if (isRejected)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'REASON FOR REJECTION:',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user.rejectionReason!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    const Text(
                      "Admin is reviewing your request. You will get access once approved.\nIf you have been waiting for too long, please contact Admin at +92 332 3220916.",
                      style: TextStyle(
                        color: AppTheme.deepNavyBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  
                  const SizedBox(height: 60),

                  if (!isRejected)
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        color: AppTheme.deepNavyBlue,
                        strokeWidth: 3,
                      ),
                    ),

                  const SizedBox(height: 60),
                  
                  CraneButton(
                    text: 'Logout',
                    onPressed: () => FirebaseAuth.instance.signOut(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
