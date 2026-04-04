import 'package:flutter/material.dart';
import 'pending_tasks_page.dart';
import 'package:extend_crane_services/features/operations/presentation/widgets/direct_work_modal.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../quotation/data/models/quotation_model.dart';
import 'package:extend_crane_services/features/quotation/presentation/pages/add_quotation_page.dart';
import 'package:extend_crane_services/features/maintenance/presentation/pages/maintenance_history_page.dart';
import 'package:extend_crane_services/features/reports/presentation/pages/earnings_report_page.dart';
import 'package:extend_crane_services/features/notifications/presentation/pages/notification_screen.dart';
import 'package:extend_crane_services/features/settings/presentation/pages/settings_page.dart';
import 'package:extend_crane_services/core/presentation/widgets/custom_drawer.dart';
import 'package:extend_crane_services/shared/global_widgets/premium_background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../features/finance/data/repositories/finance_repository.dart';
import '../../../../features/quotation/data/repositories/quotation_repository.dart';
import '../../../auth/presentation/controllers/login_notifier.dart';
import '../../../notifications/presentation/providers/notification_providers.dart' as np;
import '../../../notifications/data/models/pending_item.dart';
import '../../../../core/services/local_notification_service.dart';

class MainDashboard extends ConsumerStatefulWidget {
  final bool isViewer;
  const MainDashboard({super.key, this.isViewer = false});

  @override
  ConsumerState<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends ConsumerState<MainDashboard>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _pulseController;
  List<PendingItem> _currentPendingItems = [];
  bool _hasShownPendingAlert = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndShowPendingPopup();
    }
  }

  void _checkAndShowPendingPopup() {
    if (_currentPendingItems.isNotEmpty) {
      final item = _currentPendingItems.first;
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.amberAccent, width: 2),
          ),
          title: const Text('Pending Task Resume', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Client: ${item.clientName}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Location: ${item.location}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text('Amount: AED ${item.totalPrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w900)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('LATER', style: TextStyle(color: Colors.white30)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: () {
                Navigator.pop(context);
                // Navigate to processing page or open modal
              },
              child: const Text('ACCEPT / PROCESS', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  void _showForcedResolutionDialog(QuotationModel quotation) {
    debugPrint('DEBUG: Calling _showForcedResolutionDialog for quote ID: ${quotation.id}');
    showDialog(
      context: context,
      barrierDismissible: false, // Force User Action
      builder: (context) => WillPopScope(
        onWillPop: () async => false, // Disable back button
        child: AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.redAccent, width: 2),
          ),
          title: const Text(
            'ACTION REQUIRED',
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'You must resolve your oldest pending quotation before proceeding:',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Text('Client: ${quotation.clientName}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('Location: ${quotation.siteLocation}', style: const TextStyle(color: Colors.blueAccent)),
              Text('Amount: AED ${quotation.totalAmount}', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Still Pending', style: TextStyle(color: Colors.white38)),
            ),
            TextButton(
              onPressed: () async {
                await ref.read(quotationRepositoryProvider).updateQuotationStatus(quotation.id, 'cancelled');
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Cancel Job', style: TextStyle(color: Colors.orangeAccent)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
              onPressed: () async {
                await ref.read(quotationRepositoryProvider).updateQuotationStatus(quotation.id, 'completed');
                if (context.mounted) Navigator.pop(context);
              },

              child: const Text('Complete Job', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: ()  {
                Navigator.pop(context);
              },
              child: const Text('Back to Screen', style: TextStyle(color: Colors.orangeAccent)),
            ),
          ],
        ),
      ),
    );
  }

  // void _checkAndShowMidnightPopup() {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (context) => AlertDialog(
  //         backgroundColor: const Color(0xFF1A1A2E),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(16),
  //           side: const BorderSide(color: Colors.redAccent, width: 2),
  //         ),
  //         title: const Row(
  //           children: [
  //             Icon(
  //               Icons.notification_important_rounded,
  //               color: Colors.redAccent,
  //             ),
  //             SizedBox(width: 12),
  //             Expanded(
  //               child: Text(
  //                 'MIDNIGHT UPDATE',
  //                 style: TextStyle(
  //                   color: Colors.white,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             const Text(
  //               'Work Update Required for:',
  //               style: TextStyle(color: Colors.white70, fontSize: 12),
  //             ),
  //             const Text(
  //               'Street Client',
  //               style: TextStyle(
  //                 color: Colors.white,
  //                 fontWeight: FontWeight.w900,
  //                 fontSize: 18,
  //               ),
  //             ),
  //             const SizedBox(height: 8),
  //             const Text(
  //               'Location: Musaffah M-27',
  //               style: TextStyle(
  //                 color: Colors.blueAccent,
  //                 fontWeight: FontWeight.bold,
  //                 fontSize: 14,
  //               ),
  //             ),
  //             const SizedBox(height: 16),
  //             const Text(
  //               'Please update the status to clear this from your dashboard.',
  //               style: TextStyle(color: Colors.white60, fontSize: 12),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(onPressed: () => Navigator.pop(context), child: const Text(
  //             'Cancel',
  //             style: TextStyle(
  //               color: Colors.redAccent,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),),
  //           const Spacer(),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //               showModalBottomSheet(
  //                 context: context,
  //                 isScrollControlled: true,
  //                 backgroundColor: Colors.transparent,
  //                 builder: (_) => MidnightStatusModal(
  //                   date: DateTime.now().subtract(const Duration(days: 1)),
  //                   quotation: QuotationModel(
  //                     id: 'mock_1',
  //                     operatorId: 'mock_op',
  //                     clientName: 'Street Client',
  //                     siteLocation: 'Musaffah M-27',
  //                     serviceType: '50 Ton Crane',
  //                     totalAmount: 1000,
  //                     balanceAmount: 1000,
  //                     createdAt: DateTime.now(),
  //                     updatedAt: DateTime.now(),
  //                     workDate: DateTime.now(),
  //                   ),
  //                 ),
  //               );
  //             },
  //             child: const Text(
  //               'UPDATE NOW',
  //               style: TextStyle(
  //                 color: Colors.redAccent,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   });
  // }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, [
    Widget? destination,
  ]) {
    final theme = Theme.of(context);
    return Card(
      elevation: 6,
      color: Colors.black26,
      child: InkWell(
        onTap: destination != null
            ? () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => destination),
              )
            : null,
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            padding: EdgeInsets.all(
              Responsive.scale(context, 16).clamp(12.0, 24.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: Responsive.scale(context, 28).clamp(24.0, 36.0),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontSize: Responsive.scale(
                          context,
                          24,
                        ).clamp(20.0, 32.0),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                        fontSize: Responsive.scale(
                          context,
                          12,
                        ).clamp(10.0, 14.0),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userAsync = ref.watch(currentUserProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final useSidebar = screenWidth > 900;

    // TASK 2: High-reliability listener at top level of build
    final userId = userAsync.asData?.value?.id;
    if (userId != null && !widget.isViewer) {
      ref.listen<AsyncValue<QuotationModel?>>(firstPendingQuotationProvider(userId), (previous, next) {
        if (!_hasShownPendingAlert) {
          next.when(
            data: (quotation) {
              if (quotation != null) {
                _hasShownPendingAlert = true;
                debugPrint('DEBUG: Pending quotation found for forced modal (listen): ${quotation.clientName}');
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _showForcedResolutionDialog(quotation);
                });
              }
            },
            loading: () => debugPrint('DEBUG: Pending quotation stream loading for UID: $userId'),
            error: (err, stack) => debugPrint('DEBUG: Pending quotation stream error: $err'),
          );
        }
      });
    }

    return PremiumScaffold(
      drawer: useSidebar ? null : CustomDrawer(activeRoute: 'Dashboard', isViewer: widget.isViewer),
      floatingActionButton: userAsync.when(
        data: (user) {
          if (user == null || widget.isViewer) return null;
          return IgnorePointer(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'direct_work',
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const DirectWorkModal(),
                    );
                  },
                  icon: const Icon(Icons.flash_on_rounded, size: 20, color: Colors.black),
                  label: const Text(
                    'Direct Work',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                FloatingActionButton.extended(
                  heroTag: 'quotation',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddQuotationPage()),
                    );
                  },
                  icon: const Icon(Icons.add_box, size: 20, color: Colors.black),
                  label: const Text(
                    'Generate Quotation',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
              ],
            ),
          );
        },
        loading: () => null,
        error: (_, _) => null,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('User session ended.'));
          final statsAsync = ref.watch(operatorStatsProvider(user.id));
          final activityAsync = ref.watch(operatorRecentActivityProvider(user.id));
          final pendingAsync = ref.watch(np.pendingWorkProvider(user.id));

          return pendingAsync.when(
            data: (pendingItems) {
              _currentPendingItems = pendingItems;
              final hasPending = !widget.isViewer && pendingItems.isNotEmpty;

              if (hasPending) {
                LocalNotificationService.scheduleMidnightCheck(pendingItems.first.clientName);
                if (DateTime.now().hour >= 0 && DateTime.now().hour < 6) {
                   LocalNotificationService.showHighPriorityAlert(pendingItems.first.clientName);
                }
              }

              return SafeArea(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: AppTheme.lavenderBlueGradient,
                      ),
                    ),

                    if (hasPending)
                      Positioned(
                        top: 0, left: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.9),
                            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
                          ),
                          child: SafeArea(
                            bottom: false,
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 22),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '⚠️ PENDING: ${pendingItems.first.clientName} @ ${pendingItems.first.location} (${pendingItems.first.type.toUpperCase()})',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
                                      ),
                                      Text(
                                        'Amount: AED ${pendingItems.first.totalPrice.toStringAsFixed(2)}',
                                        style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const PendingTasksPage()),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.black26,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text(
                                    'MANAGE',
                                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    Padding(
                      padding: EdgeInsets.only(top: hasPending ? 50 : 0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isTablet = constraints.maxWidth > 600;
                          return Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1200),
                              child: CustomScrollView(
                                physics: const BouncingScrollPhysics(),
                                slivers: [
                                  _buildDashboardAppBar(theme, user.fullName),

                                  statsAsync.when(
                                    data: (stats) => _buildStatsGrid(context, stats, isTablet),
                                    loading: () => const SliverToBoxAdapter(
                                      child: Center(child: CircularProgressIndicator(color: Colors.amber)),
                                    ),
                                    error: (err, _) => SliverToBoxAdapter(
                                      child: Center(child: Text('Error loading stats: $err', style: const TextStyle(color: Colors.redAccent))),
                                    ),
                                  ),
                                  SliverPadding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                                    sliver: SliverList(
                                      delegate: SliverChildListDelegate([
                                        if (hasPending)
                                          FadeTransition(
                                            opacity: Tween<double>(begin: 0.6, end: 1.0).animate(_pulseController),
                                            child: FloatingActionButton.extended(
                                              onPressed: () {
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => PendingTasksPage()));
                                              },
                                              backgroundColor: Colors.redAccent,
                                              icon: const Icon(Icons.assignment_late, color: Colors.white),
                                              label: Text(
                                                '${pendingItems.length} PENDING',
                                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                              ),
                                            ),
                                          ),

                                        const SizedBox(height: 10),
                                        Text(
                                          'Recent Activity',
                                          style: theme.textTheme.displayLarge?.copyWith(fontSize: 20, color: Colors.white),
                                        ),
                                        const SizedBox(height: 16),
                                        activityAsync.when(
                                          data: (activities) {
                                            if (activities.isEmpty) {
                                              return const Center(child: Text('No recent jobs found.', style: TextStyle(color: Colors.white38)));
                                            }
                                            return Column(
                                              children: activities.map((act) => _buildLiveActivityTile(context, act)).toList(),
                                            );
                                          },
                                          loading: () => const Center(child: CircularProgressIndicator(color: Colors.amber)),
                                          error: (err, _) => Center(child: Text('Error loading activities', style: const TextStyle(color: Colors.redAccent))),
                                        ),
                                      ]),
                                    ),
                                  ),
                                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    if (hasPending)
                      FadeTransition(
                        opacity: Tween<double>(begin: 0.6, end: 1.0).animate(_pulseController),
                        child: FloatingActionButton.extended(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => PendingTasksPage()));
                          },
                          backgroundColor: Colors.redAccent,
                          icon: const Icon(Icons.assignment_late, color: Colors.white),
                          label: Text(
                            '${pendingItems.length} PENDING',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
            error: (err, stack) {
              // TASK 3: Print firestore error to identify missing indices
              debugPrint('Firestore Pending Stream Error: $err');
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Error loading pending work: $err',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) {
          debugPrint('Auth Stream Error: $err');
          return Center(child: Text('Auth error: $err', style: const TextStyle(color: Colors.white)));
        },
      ),
    );
  }

  // Widget _buildPendingBanner(BuildContext context) {
  //   return Positioned(
  //     top: 0,
  //     left: 0,
  //     right: 0,
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  //       decoration: BoxDecoration(
  //         color: Colors.red.withValues(alpha: 0.8),
  //         boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 2))],
  //       ),
  //       child: SafeArea(
  //         bottom: false,
  //         child: Row(
  //           children: [
  //             const Icon(Icons.warning_rounded, color: Colors.white, size: 25),
  //             const SizedBox(width: 12),
  //             const Expanded(
  //               child: Text(
  //                 'Pending Mid-Night Updates. Please update status now!',
  //                 style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
  //               ),
  //             ),
  //             ElevatedButton(
  //               onPressed: () {},
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: Colors.black.withValues(alpha: 0.2),
  //                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //                 elevation: 0,
  //               ),
  //               child: const Text('Update Now', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildDashboardAppBar(ThemeData theme, String? name) {
    return SliverAppBar(
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'Welcome ${name ?? 'Operator'} 👋',
        style: theme.textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
          icon: const Icon(Icons.notifications_active_outlined, color: Colors.white),
        ),
        IconButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsPage())),
          icon: const Icon(Icons.person_outline, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, OperatorStats stats, bool isTablet) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 4 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        delegate: SliverChildListDelegate([
          _buildSummaryCard(context, 'Total Quotes', '${stats.totalQuotes}', Icons.request_quote, Colors.blue),
          _buildSummaryCard(context, 'Pending Jobs', '${stats.pendingJob}', Icons.engineering, Colors.orange, const PendingTasksPage()),
          _buildSummaryCard(context, 'Maintenance', '${stats.maintenanceCount}', Icons.build, Colors.redAccent, const MaintenanceHistoryPage()),
          _buildSummaryCard(context, 'Earnings', 'AED ${stats.totalEarnings.toStringAsFixed(0)}', Icons.monetization_on, Colors.green, const EarningsReportPage()),
        ]),
      ),
    );
  }

  Widget _buildLiveActivityTile(BuildContext context, dynamic act) {
    final isJob = act['type'] == 'job';
    final dateStr = DateFormat('dd MMM, hh:mm a').format(act['date']);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.black.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isJob ? Colors.green : Colors.amber).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isJob ? Icons.precision_manufacturing : Icons.receipt_long_outlined,
            color: isJob ? Colors.greenAccent : Colors.amberAccent,
            size: 20,
          ),
        ),
        title: Text(
          act['description'],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
        ),
        subtitle: Text(
          dateStr.toString(),
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        trailing: Text(
          '${isJob ? '+' : '-'} ${act['amount'].toStringAsFixed(0)} AED',
          style: TextStyle(
            color: isJob ? Colors.greenAccent : Colors.redAccent,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
