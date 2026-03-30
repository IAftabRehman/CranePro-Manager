import 'package:flutter/material.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_button.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_text_field.dart';
import 'package:extend_crane_services/features/admin/presentation/pages/admin_control_page.dart';

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
    if (!_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simulating Admin Authentication
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() => _isLoading = false);
        
        // Success Mock Logic
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Admin Access Granted!'), backgroundColor: Colors.green),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminControlPage()),
        );
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
                          text: 'AUTHENTICATE',
                          onPressed: _handleLogin,
                          isLoading: _isLoading,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'RETURN TO PUBLIC AREA',
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
