import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_button.dart';
import 'package:extend_crane_services/features/auth/data/models/user_model.dart';
import 'package:url_launcher/url_launcher.dart';

class BlockedAccountPage extends StatelessWidget {
  final UserModel user;
  const BlockedAccountPage({super.key, required this.user});

  Future<void> _contactAdmin() async {
    const phone = 'tel:+923323220916';
    if (await canLaunchUrl(Uri.parse(phone))) {
      await launchUrl(Uri.parse(phone));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A1A),
              Color(0xFF000000),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.block_flipped,
                  color: Colors.redAccent,
                  size: 100,
                ),
                const SizedBox(height: 32),
                const Text(
                  'ACCOUNT SUSPENDED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Hello ${user.fullName.split(' ')[0]}, your access to the CranePro terminal has been suspended by an administrator.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'This action is usually due to a policy violation or maintenance. Please contact support to resolve this.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: _contactAdmin,
                        icon: const Icon(Icons.phone, color: Colors.amber, size: 18),
                        label: const Text(
                          '+92 332 3220916',
                          style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                CraneButton(
                  text: 'Log Out',
                  onPressed: () => FirebaseAuth.instance.signOut(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
