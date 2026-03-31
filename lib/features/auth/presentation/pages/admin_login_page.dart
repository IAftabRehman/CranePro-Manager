import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_button.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_text_field.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // 1. Firebase Authentication
        final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final user = userCredential.user;
        if (user != null && mounted) {
          // 2. Fetch Firestore profile to verify Admin status immediately
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (!userDoc.exists || userDoc.data()?['role'] != 'admin') {
            // Not an admin!
            await FirebaseAuth.instance.signOut();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Access Denied: Not an authorized Administrator account.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
            return;
          }

          // 3. Success Feedback
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication Successful! Initiating Admin Handshake...'),
              backgroundColor: Colors.green,
            ),
          );
          
          // 4. Pop until original screen to let AuthWrapper take over
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message ?? 'Authentication Failed'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An unexpected error occurred: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F), // Deep Restricted Black
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F0F0F),
              const Color(0xFF1A237E).withValues(alpha: 0.2), // Subtle Navy hint
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Restricted Icon
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.2), width: 2),
                        ),
                        child: const Icon(Icons.lock_person_rounded, size: 70, color: Colors.amber),
                      ),
                      const SizedBox(height: 40),
                      
                      const Text(
                        'ADMINISTRATOR ACCESS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'RESTRICTED TERMINAL - AUTHORIZED ONLY',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 60),

                      CraneInput(
                        controller: _emailController,
                        hintText: 'Admin Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v != null && v.contains('@') ? null : 'Valid email required',
                      ),
                      const SizedBox(height: 20),
                      CraneInput(
                        controller: _passwordController,
                        hintText: 'Security Token',
                        obscureText: true,
                        validator: (v) => v != null && v.length >= 6 ? null : 'Token too short',
                      ),
                      
                      const SizedBox(height: 60),

                      SizedBox(
                        width: double.infinity,
                        child: CraneButton(
                          text: 'Authenticate',
                          onPressed: _handleLogin,
                          isLoading: _isLoading,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Return To Public Area',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
