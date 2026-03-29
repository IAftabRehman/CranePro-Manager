import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/core/presentation/widgets/custom_drawer.dart';
import 'dart:ui';

class ViewerDashboard extends StatefulWidget {
  const ViewerDashboard({super.key});

  @override
  State<ViewerDashboard> createState() => _ViewerDashboardState();
}

class _ViewerDashboardState extends State<ViewerDashboard> with SingleTickerProviderStateMixin {
  late AnimationController _alertController;
  final bool _hasPendingQuotations = true; // Simulated: Check for yesterday's pending work

  @override
  void initState() {
    super.initState();
    _alertController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _alertController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(activeRoute: 'Dashboard', isViewer: true),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.lavenderBlueGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // TASK 1: Header Integration
              _buildAppBar(context),
              
              // TASK 3: Lazy Driver Alert System
              if (_hasPendingQuotations) _buildFlashingAlert(),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    children: [
                      // TASK 2: 3D Summary Analytics
                      _buildSummaryGrid(context),
                      
                      const SizedBox(height: 40),
                      
                      // TASK 4: Recent Activity Feed
                      _buildTodayWorkFeed(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: AppTheme.deepNavyBlue, size: 32),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
          Column(
            children: [
              Image.asset('assets/images/logo.png', height: 60),
              const Text(
                'LIVE MONITORING',
                style: TextStyle(
                  color: AppTheme.deepNavyBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlashingAlert() {
    return AnimatedBuilder(
      animation: _alertController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Color.lerp(Colors.redAccent, Colors.amber, _alertController.value)!.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.3 * _alertController.value),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.report_problem_rounded, color: Colors.white, size: 22),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'PENDING REPORT: Street Client @ Dubai Marina - Status not updated by Driver.',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryGrid(BuildContext context) {
    final bool isTablet = Responsive.isTablet(context);
    
    return Column(
      children: [
        if (!isTablet) ...[
          _Viewer3DCard(
            title: 'TOTAL GROSS INCOME',
            value: 'AED 84,250',
            icon: Icons.account_balance_wallet_rounded,
            color: Colors.blueAccent,
          ),
          const SizedBox(height: 20),
          _Viewer3DCard(
            title: 'OPERATING EXPENSES',
            value: 'AED 12,400',
            icon: Icons.receipt_long_rounded,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 20),
          _Viewer3DCard(
            title: 'NET CASH FLOW (PROFIT)',
            value: 'AED 71,850',
            icon: Icons.trending_up_rounded,
            color: Colors.greenAccent,
            isProfit: true,
          ),
        ] else
          Row(
            children: [
              Expanded(
                child: _Viewer3DCard(
                  title: 'GROSS INCOME',
                  value: 'AED 84.2K',
                  icon: Icons.account_balance_wallet_rounded,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _Viewer3DCard(
                  title: 'EXPENSES',
                  value: 'AED 12.4K',
                  icon: Icons.receipt_long_rounded,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _Viewer3DCard(
                  title: 'NET PROFIT',
                  value: 'AED 71.8K',
                  icon: Icons.trending_up_rounded,
                  color: Colors.greenAccent,
                  isProfit: true,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildTodayWorkFeed(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'TODAY\'S WORK ACTIVITY',
            style: TextStyle(
              color: AppTheme.deepNavyBlue,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
        ),
        _buildActivityTile('Own Crane 25T', 'AED 2,500', 'Business Bay, Dubai'),
        _buildActivityTile('Commission Basis', 'AED 850', 'Deira, Dubai'),
        _buildActivityTile('Own Crane 25T', 'AED 4,200', 'Jumeirah Village Circle'),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildActivityTile(String type, String amount, String location) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.deepNavyBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.precision_manufacturing_rounded, color: AppTheme.deepNavyBlue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    color: AppTheme.deepNavyBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  location,
                  style: TextStyle(
                    color: AppTheme.deepNavyBlue.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              color: Color(0xFF1A237E),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _Viewer3DCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isProfit;

  const _Viewer3DCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isProfit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 15),
            blurRadius: 30,
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.deepNavyBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Icon(icon, color: color.withOpacity(0.8), size: 24),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.deepNavyBlue,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (isProfit) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.trending_up, color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '+12% from last month',
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
