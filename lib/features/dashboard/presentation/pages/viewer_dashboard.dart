import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/core/presentation/widgets/custom_drawer.dart';
import 'package:extend_crane_services/features/dashboard/presentation/widgets/live_status_feed_item.dart';
import 'package:extend_crane_services/features/quotation/data/models/quotation_model.dart';
import 'package:extend_crane_services/features/reports/presentation/pages/work_history_viewer_page.dart';
import 'dart:ui';
import 'dart:async';

class ViewerDashboard extends StatefulWidget {
  const ViewerDashboard({super.key});

  @override
  State<ViewerDashboard> createState() => _ViewerDashboardState();
}

class _ViewerDashboardState extends State<ViewerDashboard> with TickerProviderStateMixin {
  late AnimationController _alertController;
  late ScrollController _scrollController;
  double _parallaxOffset = 0.0;

  // Stream simulation for "Live Status" updates
  final StreamController<String> _statusStreamController = StreamController<String>.broadcast();

  @override
  void initState() {
    super.initState();
    _alertController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scrollController = ScrollController()..addListener(() {
      setState(() {
        _parallaxOffset = _scrollController.offset * 0.3;
      });
    });

    // Simulate real-time updates from Dubai
    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _statusStreamController.add('New Site Activity: Own 25T Crane @ Dubai Marina');
      }
    });
  }

  @override
  void dispose() {
    _alertController.dispose();
    _scrollController.dispose();
    _statusStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(activeRoute: 'Dashboard', isViewer: true),
      body: Stack(
        children: [
          // Parallax Background
          Positioned(
            top: -_parallaxOffset,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.lavenderBlueGradient,
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                _buildLiveStatusHeader(),

                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      children: [
                        // TASK 2: 4 Command Center Cards
                        _buildCommandCenterGrid(context),
                        
                        const SizedBox(height: 48),

                        // TASK 4: Execution Modes
                        _buildExecutionTabs(context),
                        
                        const SizedBox(height: 48),
                        
                        // TASK 3: Status-Based Activity Feed
                        _buildLiveActivityStream(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
              Hero(tag: 'logo', child: Image.asset('assets/images/logo.png', height: 60)),
              const Text(
                'FAMILY MONITOR - LIVE STATION',
                style: TextStyle(
                  color: AppTheme.deepNavyBlue,
                  fontSize: 10,
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

  Widget _buildLiveStatusHeader() {
    return StreamBuilder<String>(
      stream: _statusStreamController.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        return AnimatedBuilder(
          animation: _alertController,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: Color.lerp(Colors.red.shade900, Colors.amber.shade900, _alertController.value)!.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.3 * _alertController.value),
                    blurRadius: 15 * _alertController.value,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt_rounded, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'DUBAI UPDATE: ${snapshot.data}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCommandCenterGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _CommandCard(
                label: 'LIVE PROFIT',
                value: 'AED 8,420',
                icon: Icons.auto_graph_rounded,
                isPrimary: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _CommandCard(
                label: 'ACTIVE WORK',
                value: '4 JOBS',
                icon: Icons.timer_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _CommandCard(
                label: 'MAINTENANCE',
                value: 'AED 3,200',
                icon: Icons.build_circle_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _CommandCard(
                label: 'CANCELLED',
                value: '2 TASKS',
                icon: Icons.cancel_presentation_rounded,
                isDanger: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExecutionTabs(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'EXECUTION REPORTS',
              style: TextStyle(
                color: AppTheme.deepNavyBlue,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('VIEW ALL', style: TextStyle(color: AppTheme.deepNavyBlue, fontWeight: FontWeight.w900, fontSize: 12)),
            )
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ReportExecutionModeButton(
                label: 'OWN CRANE (25T)',
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkHistoryViewerPage())),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ReportExecutionModeButton(
                label: 'COMMISSION',
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkHistoryViewerPage())),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLiveActivityStream(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 20),
          child: Text(
            'LIVE ACTIVITY STREAM',
            style: TextStyle(
              color: AppTheme.deepNavyBlue,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const LiveStatusFeedItem(
          title: 'Damac Hills - Site 4',
          subtitle: 'Dubai Al Qudra Road',
          amount: 'AED 4,500',
          status: QuotationStatus.completed,
        ),
        const LiveStatusFeedItem(
          title: 'Sobha Realty - Ground',
          subtitle: 'Meydan, Dubai',
          amount: 'AED 12,000',
          status: QuotationStatus.pending,
        ),
        const LiveStatusFeedItem(
          title: 'Emaar Marini',
          subtitle: 'Dubai Marina JBR',
          amount: 'AED 2,800',
          status: QuotationStatus.cancelled,
          reason: 'Operator Tired - No Night Shift',
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _CommandCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isPrimary;
  final bool isDanger;

  const _CommandCard({
    required this.label,
    required this.value,
    required this.icon,
    this.isPrimary = false,
    this.isDanger = false,
  });

  @override
  State<_CommandCard> createState() => _CommandCardState();
}

class _CommandCardState extends State<_CommandCard> with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color accentColor = AppTheme.deepNavyBlue;
    if (widget.isPrimary) accentColor = Colors.green.shade900;
    if (widget.isDanger) accentColor = Colors.red.shade900;

    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) => _pressController.reverse(),
      onTapCancel: () => _pressController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: accentColor.withValues(alpha: 0.2), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05 + (_scaleAnimation.value - 1.0)),
                    offset: const Offset(0, 10),
                    blurRadius: 20 * _scaleAnimation.value,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(widget.icon, color: accentColor, size: 24),
                      if (widget.isPrimary)
                        const Icon(Icons.flash_on_rounded, color: Colors.amber, size: 16),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.label.toUpperCase(),
                    style: TextStyle(
                      color: AppTheme.deepNavyBlue.withValues(alpha: 0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.value,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ReportExecutionModeButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ReportExecutionModeButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.deepNavyBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        shadowColor: AppTheme.deepNavyBlue.withValues(alpha: 0.4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
