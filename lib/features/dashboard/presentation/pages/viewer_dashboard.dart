import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';
import 'package:extend_crane_services/shared/global_widgets/premium_background.dart';

class ViewerDashboard extends StatelessWidget {
  const ViewerDashboard({super.key});

  final bool _hasPendingReports = true; // Mocking pending status for viewer

  Widget _buildStatusCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: EdgeInsets.all(
            Responsive.scale(context, 16).clamp(16.0, 24.0)),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              radius: Responsive.scale(context, 24).clamp(20.0, 32.0),
              child: Icon(icon, color: color,
                  size: Responsive.scale(context, 24).clamp(20.0, 32.0)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      fontSize: Responsive.scale(context, 12).clamp(11.0, 14.0),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontSize: Responsive.scale(context, 18).clamp(16.0, 24.0),
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(BuildContext context, String title, String subtitle,
      bool isCompleted, bool isLast) {
    final theme = Theme.of(context);
    final color = isCompleted ? Colors.green : theme.colorScheme.tertiary
        .withValues(alpha: 0.3);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: Responsive.scale(context, 12).clamp(10.0, 16.0),
                backgroundColor: color,
                child: isCompleted
                    ? Icon(Icons.check,
                    size: Responsive.scale(context, 16).clamp(14.0, 20.0),
                    color: Colors.white)
                    : const SizedBox.shrink(),
              ),
              if (!isLast)
                Expanded(
                  child: VerticalDivider(
                    color: color,
                    thickness: 2,
                    width: 24,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontSize: Responsive.scale(context, 16).clamp(14.0, 18.0),
                      color: isCompleted ? theme.colorScheme.secondary : Colors
                          .white24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isCompleted ? Colors.white70 : Colors.white12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyPulse(BuildContext context) {
    final theme = Theme.of(context);
    final fuelSpent = 1250;
    final commission = 3500;
    final isInactive = true; // Mocking inactivity > 24h

    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: isInactive ? Colors.redAccent.withValues(alpha: 0.3) : Colors
                .white.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'DAILY PULSE',
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white38,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2),
                ),
                if (isInactive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                            Icons.timer_outlined, color: Colors.redAccent,
                            size: 12),
                        const SizedBox(width: 4),
                        const Text('LAZY METER: HIGH', style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildPulseStat(context, 'WORK DONE', '✅ YES', Colors.green),
                _buildVerticalDivider(),
                _buildPulseStat(
                    context, 'FUEL SPENT', 'AED $fuelSpent', Colors.orange),
                _buildVerticalDivider(),
                _buildPulseStat(context, 'EARNED', 'AED $commission',
                    theme.colorScheme.secondary),
              ],
            ),
            if (isInactive) ...[
              const SizedBox(height: 16),
              const Divider(color: Colors.white10),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                      Icons.error_outline, color: Colors.redAccent, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'Operator has not reported for 28 hours!',
                    style: TextStyle(color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPulseStat(BuildContext context, String label, String value,
      Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(
              color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(
              color: color, fontSize: 13, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white.withValues(alpha: 0.05),
    );
  }

  Widget _buildTimelineSection(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: EdgeInsets.all(
            Responsive.scale(context, 20).clamp(16.0, 32.0)),
        child: IgnorePointer( // Strictly view-only timeline
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Job Progress',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontSize: Responsive.scale(context, 18).clamp(16.0, 22.0),
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              _buildTimelineStep(context, 'Quotation Sent',
                  'Oct 24, 2026 - Approved by Client', true, false),
              _buildTimelineStep(context, 'Crane Dispatched',
                  'Oct 25, 2026 - 50 Ton Crane en route', true, false),
              _buildTimelineStep(context, 'Work Started',
                  'Oct 25, 2026 - Lifting operations ongoing', false, false),
              _buildTimelineStep(
                  context, 'Completed', 'Awaiting final sign-off', false, true),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PremiumScaffold(
        appBar: AppBar(
          title: const Text('Dashboard', style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: Container(
              width: double.infinity,
              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text(
                  'Guest / Viewer Mode',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      body: SafeArea(
        child: Stack(
          children: [
            // TASK 3: Persistent Sticky Red Bar (Visible to Viewer)
            if (_hasPendingReports)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: Colors.red.withValues(alpha: 0.95),
                  child: Row(
                    children: [
                      const Icon(Icons.report_problem_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'OPERATOR ALERT: Pending Report for Street Client',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Colors.white70, size: 20),
                    ],
                  ),
                ),
              ),

            Padding(
              padding: EdgeInsets.only(top: _hasPendingReports ? 45 : 0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isTablet = constraints.maxWidth > 700;
                  final paddingVal = Responsive.scale(context, 16).clamp(16.0, 32.0);

                  // Summary Cards Items
                  final summaryCards = [
                    _buildStatusCard(context, 'Today\'s Work Status', 'Crane Active at Site A', Icons.engineering, Colors.blue),
                    _buildStatusCard(context, 'Pending Quotations', '3 Awaiting', Icons.request_page, Colors.orange),
                    _buildStatusCard(context, 'Completed Jobs', '14 This Week', Icons.task_alt, Colors.green),
                  ];

                  Widget summarySection;
                  if (isTablet) {
                    summarySection = Row(
                      children: summaryCards.map((card) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: card == summaryCards.last ? 0 : 16.0),
                          child: card,
                        ),
                      )).toList(),
                    );
                  } else {
                    summarySection = Column(
                      children: summaryCards.map((card) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: card,
                      )).toList(),
                    );
                  }

                  if (isTablet) {
                    // Side-by-side for iPad Pro
                    return Padding(
                      padding: EdgeInsets.all(paddingVal * 1.5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Overview',
                                    style: theme.textTheme.displayLarge?.copyWith(fontSize: 22, color: Colors.white),
                                  ),
                                  const SizedBox(height: 16),
                                  summarySection,
                                  const SizedBox(height: 24),
                                  _buildDailyPulse(context),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            flex: 4,
                            child: SingleChildScrollView(
                              child: _buildTimelineSection(context),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Mobile Column
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Overview',
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: Responsive.scale(context, 20).clamp(18.0, 24.0),
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDailyPulse(context),
                        const SizedBox(height: 16),
                        summarySection,
                        const SizedBox(height: 32),
                        _buildTimelineSection(context),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
