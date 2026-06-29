import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';
import '../widgets/auth_wrapper.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();
    _startNavigationTimer();
  }

  void _startNavigationTimer() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const AuthWrapper(),
          ),
        );
      }
    });
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
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Hero(
                    tag: 'logo',
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: Responsive.scale(context, 120).clamp(100.0, 180.0),
                      cacheHeight: 540,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'CranePro Manager',
                    style: TextStyle(
                      color: AppTheme.lavenderPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Extend Crane Services',
                    style: TextStyle(
                      color: AppTheme.lavenderPrimary.withValues(alpha: 0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 80),
                  
                  // Optimized Spinner to visualise background activity / initialization
                  const RepaintBoundary(
                    child: CircularProgressIndicator(color: Colors.amber),
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
