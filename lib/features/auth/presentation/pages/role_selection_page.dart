import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/core/providers/session_provider.dart';
import 'package:extend_crane_services/features/dashboard/presentation/pages/main_dashboard.dart';
import 'package:extend_crane_services/features/dashboard/presentation/pages/viewer_dashboard.dart';

class RoleSelectionPage extends ConsumerWidget {
  const RoleSelectionPage({super.key});

  void _enterAsOperator(BuildContext context, WidgetRef ref) {
    ref.read(selectedRoleProvider.notifier).setRole('operator');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainDashboard(isViewer: false)),
    );
  }

  void _enterAsViewer(BuildContext context, WidgetRef ref) {
    ref.read(selectedRoleProvider.notifier).setRole('viewer');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ViewerDashboard()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  Hero(
                    tag: 'logo',
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: Responsive.scale(context, 100).clamp(80.0, 150.0),
                      cacheHeight: 450,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 30),

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
                                    onTap: () => _enterAsOperator(context, ref),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: RoleCard3D(
                                    title: 'VIEWER',
                                    subtitle: 'Real-time Project Tracking',
                                    icon: Icons.visibility_rounded,
                                    onTap: () => _enterAsViewer(context, ref),
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
                                  onTap: () => _enterAsOperator(context, ref),
                                ),
                                const SizedBox(height: 30),
                                RoleCard3D(
                                  title: 'VIEWER',
                                  subtitle: 'Real-time Project Tracking',
                                  icon: Icons.visibility_rounded,
                                  onTap: () => _enterAsViewer(context, ref),
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

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
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
            ..setEntry(3, 2, 0.001)
            ..multiply(Matrix4.diagonal3Values(
                _isPressed ? 0.95 : 1.0, _isPressed ? 0.95 : 1.0, 1.0)),
          child: Container(
            width: widget.boxWidth ?? 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: _isPressed
                  ? const [
                      BoxShadow(
                        color: Color(0x33000000),
                        offset: Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ]
                  : const [
                      BoxShadow(
                        color: Color(0x4D000000),
                        offset: Offset(0, 15),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Color(0x1A000000),
                        offset: Offset(10, 5),
                        blurRadius: 15,
                      ),
                      BoxShadow(
                        color: Color(0x66FFFFFF),
                        offset: Offset(-2, -2),
                        blurRadius: 5,
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0x26FFFFFF),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0x4DFFFFFF),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0x33FFFFFF),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x1A000000),
                              offset: Offset(0, 4),
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
                        style: const TextStyle(
                          color: Color(0xB30A1931),
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
      ),
    );
  }
}
