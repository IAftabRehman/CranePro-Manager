import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';

class PremiumBackground extends StatelessWidget {
  final Widget child;
  final bool showAppBarShadow;

  const PremiumBackground({
    super.key,
    required this.child,
    this.showAppBarShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.premiumGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Let the gradient show through
        body: child,
      ),
    );
  }
}

class PremiumScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  const PremiumScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.drawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.premiumGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        drawer: drawer,
        body: body,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}
