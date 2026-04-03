import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';
import 'package:extend_crane_services/features/auth/presentation/pages/login_page.dart';
import 'package:extend_crane_services/features/auth/presentation/pages/admin_login_page.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:flutter/services.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}


class _RoleSelectionPageState extends State<RoleSelectionPage> {
  int _logoTapCount = 0;
  DateTime? _lastLogoTap;
  bool _isNavigating = false;

  void _handleLogoTap() {
    final now = DateTime.now();
    if (_lastLogoTap == null || now.difference(_lastLogoTap!) > const Duration(milliseconds: 1500)) {
      _logoTapCount = 1;
    } else {
      _logoTapCount++;
    }
    _lastLogoTap = now;

    if (_logoTapCount == 3) { // Exactly 3 taps
      _logoTapCount = 0;
      if (_isNavigating) return;

      setState(() => _isNavigating = true);
      HapticFeedback.mediumImpact(); // Subtle vibration for Admin
      
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminLoginPage()),
      ).then((_) => setState(() => _isNavigating = false));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.lavenderBlueGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _handleLogoTap,
                    child: Hero(
                      tag: 'logo',
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: Responsive.scale(context, 100).clamp(80.0, 150.0),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // TASK 3: Typography
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Select Your Role to Continue',
                      style: TextStyle(
                        color: AppTheme.lavenderPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // TASK 4: Responsive Layout (Side-by-side for Tablet, Stacked for Mobile)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: isTablet 
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: RoleCard3D(
                                  title: 'OPERATOR',
                                  subtitle: 'Heavy Equipment Management',
                                  icon: Icons.precision_manufacturing,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const LoginPage(roleTitle: 'Operator')),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: RoleCard3D(
                                  title: 'VIEWER',
                                  subtitle: 'Real-time Project Tracking',
                                  icon: Icons.visibility_rounded,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const LoginPage(roleTitle: 'Viewer')),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              RoleCard3D(
                                title: 'OPERATOR',
                                subtitle: 'Heavy Equipment Management',
                                icon: Icons.precision_manufacturing,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginPage(roleTitle: 'Operator')),
                                ),
                              ),
                              const SizedBox(height: 30),
                              RoleCard3D(
                                title: 'VIEWER',
                                subtitle: 'Real-time Project Tracking',
                                icon: Icons.visibility_rounded,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginPage(roleTitle: 'Viewer')),
                                ),
                              ),
                            ],
                          ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RoleCard3D extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final double? boxWidth;

  const RoleCard3D({
    super.key,
    required this.title,
    this.boxWidth,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  State<RoleCard3D> createState() => _RoleCard3DState();
}

class _RoleCard3DState extends State<RoleCard3D> {
  bool _isPressed = false;
  double? get boxWidth => null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _isPressed ? 4.0 : 0.0, 0)
          ..setEntry(3, 2, 0.001) // Depth perception
          ..scale(_isPressed ? 0.95 : 1.0), // Scale effect
        child: Container(
          width: boxWidth ?? 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            // TASK: Sinking effect shadows
            boxShadow: _isPressed 
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ] 
              : [
                  // Bottom Shadow (Deep)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    offset: const Offset(0, 15),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                  // Side Shadow (Soft)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    offset: const Offset(10, 5),
                    blurRadius: 15,
                  ),
                  // Highlighting Effect (Inner white glow simulation)
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.4),
                    offset: const Offset(-2, -2),
                    blurRadius: 5,
                  ),
                ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Premium 3D-style icon container
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            offset: const Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.icon,
                        size: 30,
                        color: AppTheme.deepNavyBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: AppTheme.deepNavyBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        color: AppTheme.deepNavyBlue.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

