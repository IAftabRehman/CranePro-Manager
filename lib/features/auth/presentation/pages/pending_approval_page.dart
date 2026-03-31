import 'package:flutter/material.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_button.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/features/dashboard/presentation/pages/viewer_dashboard.dart';
import 'dart:async';

class PendingApprovalPage extends StatefulWidget {
  const PendingApprovalPage({super.key});

  @override
  State<PendingApprovalPage> createState() => _PendingApprovalPageState();
}

class _PendingApprovalPageState extends State<PendingApprovalPage> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  // Simulated real-time status stream
  final StreamController<Map<String, dynamic>> _statusController = StreamController<Map<String, dynamic>>.broadcast();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Simulate Admin Response after 10 seconds
    Timer(const Duration(seconds: 10), () {
      if (mounted) {
        _statusController.add({
          'isAdminApproved': true,
          'rejectionReason': null,
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _statusController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // TASK 4: Block Back Button
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot return until verified or logged out')),
        );
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppTheme.lavenderBlueGradient,
          ),
          child: StreamBuilder<Map<String, dynamic>>(
            stream: _statusController.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!['isAdminApproved'] == true) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const ViewerDashboard()),
                  );
                });
              }

              final rejectionReason = snapshot.data?['rejectionReason'];

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Hero(
                          tag: 'logo',
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 120,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      
                      Text(
                        rejectionReason != null ? 'Access Rejected' : 'Verification in Progress',
                        style: const TextStyle(
                          color: AppTheme.deepNavyBlue,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      
                      if (rejectionReason != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            'REASON: $rejectionReason',
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        const Text(
                          'Admin is reviewing your request. You will be access once approved.\nIf you have been waiting for too long, please contact Admin at +92 332 3220916.',
                          style: TextStyle(
                            color: AppTheme.deepNavyBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      
                      const SizedBox(height: 60),

                      if (rejectionReason == null)
                        const SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            color: AppTheme.deepNavyBlue,
                            strokeWidth: 3,
                          ),
                        ),

                      const SizedBox(height: 60),
                      
                      CraneButton(
                        text: rejectionReason != null ? 'Back to Signup' : 'Logout',
                        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
