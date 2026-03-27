import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_button.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_text_field.dart';
import 'package:extend_crane_services/features/auth/presentation/pages/register_page.dart';
import 'package:extend_crane_services/features/dashboard/presentation/pages/main_dashboard.dart';
import 'package:extend_crane_services/features/dashboard/presentation/pages/viewer_dashboard.dart';
import 'package:extend_crane_services/features/admin/presentation/pages/admin_control_page.dart';
import 'package:extend_crane_services/shared/global_widgets/premium_background.dart';

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
    if (_formKey.currentState!.validate()) return; // !

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
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PremiumScaffold(
        appBar: AppBar(
          title: const Text('Login', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.scale(context, 16).clamp(16.0, 32.0),
                vertical: Responsive.screenHeight(context) * 0.05,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Logo & Welcome
                      Icon(
                        Icons.precision_manufacturing,
                        size: Responsive.scale(context, 60).clamp(40.0, 80.0),
                        color: Colors.white,
                      ),
                      SizedBox(height: Responsive.screenHeight(context) * 0.02),
                      Text(
                        'Welcome Back, Officer',
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontSize: Responsive.scale(context, 24).clamp(20.0, 32.0),
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: Responsive.screenHeight(context) * 0.01),

                      // Role Indicator Badge
                      Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.scale(context, 16).clamp(12.0, 24.0),
                            vertical: Responsive.scale(context, 8).clamp(6.0, 12.0),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.badge, size: 16, color: Colors.white70),
                              const SizedBox(width: 8),
                              Text(
                                'Logging in as: ${widget.roleTitle}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: Responsive.scale(context, 12).clamp(10.0, 14.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.screenHeight(context) * 0.05),

                      // Email Input
                      CraneInput(
                        controller: _emailController,
                        hintText: 'Email Address',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: Responsive.screenHeight(context) * 0.02),

                      // Password Input
                      CraneInput(
                        controller: _passwordController,
                        hintText: 'Password',
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: Responsive.screenHeight(context) * 0.01),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Forgot Password?',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.screenHeight(context) * 0.04),

                      // Login Button Wrapper
                      Center(
                        child: CraneButton(
                          text: 'Secure Login',
                          isLoading: _isLoading,
                          onPressed: _handleLogin,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'New to CranePro?',
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RegisterPage()),
                              );
                            },
                            child: Text(
                              'Create Account',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.secondary,
                                    fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }
}
