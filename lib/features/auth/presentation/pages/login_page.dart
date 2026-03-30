import 'package:flutter/material.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_button.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_text_field.dart';
import 'package:extend_crane_services/features/auth/presentation/pages/register_page.dart';
import 'package:extend_crane_services/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:extend_crane_services/features/dashboard/presentation/pages/main_dashboard.dart';
import 'package:extend_crane_services/features/dashboard/presentation/pages/viewer_dashboard.dart';
import 'package:extend_crane_services/features/admin/presentation/pages/admin_control_page.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';

class LoginPage extends StatefulWidget {
  final String roleTitle;

  const LoginPage({super.key, required this.roleTitle});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
    if (_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Successful!')),
      );

      if (widget.roleTitle.contains('Viewer')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ViewerDashboard()),
        );
      } else if (widget.roleTitle.contains('Admin')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminControlPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainDashboard()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.lavenderBlueGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // TASK 1: Header & Logo hero
                  Hero(
                    tag: 'logo',
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      color: AppTheme.lavenderPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  
                  Text(
                    'Login to manage your ${widget.roleTitle} account',
                    style: TextStyle(
                      color: AppTheme.lavenderPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  CraneInput(
                    controller: _emailController,
                    hintText: 'Email Address',
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: (v) => v != null && v.contains('@') ? null : 'Enter a valid email',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  CraneInput(
                    controller: _passwordController,
                    hintText: 'Password',
                    obscureText: true,
                    prefixIcon: const Icon(Icons.lock_outline),
                    validator: (v) => v != null && v.length >= 6 ? null : 'Password too short',
                  ),
                  
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (_) => const ForgotPasswordPage())
                      ),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: AppTheme.lavenderPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  CraneButton(
                    text: 'Login',
                    onPressed: _handleLogin,
                    isLoading: _isLoading,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Don\'t have an account?',
                        style: TextStyle(color: AppTheme.lavenderPrimary),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RegisterPage(roleTitle: widget.roleTitle),
                          ),
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: AppTheme.lavenderPrimary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
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
