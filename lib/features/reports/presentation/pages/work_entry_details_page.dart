import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'dart:ui';

class WorkEntryDetailsPage extends StatelessWidget {
  final bool isOwnCrane;
  final String client;
  final String location;
  final double total;
  final double deduction;
  final String deductionLabel;

  const WorkEntryDetailsPage({
    super.key,
    required this.isOwnCrane,
    required this.client,
    required this.location,
    required this.total,
    required this.deduction,
    required this.deductionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final net = total - deduction;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.lavenderBlueGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    children: [
                      // Header Card
                      _buildHeaderCard(),
                      const SizedBox(height: 24),

                      // Section 1: Work Identity
                      _buildDetailSection(
                        'Work Identity',
                        [
                          _buildDetailRow(Icons.precision_manufacturing_rounded, 'Service Type', isOwnCrane ? 'Own 25T Crane' : 'Commission/Outsourced'),
                          _buildDetailRow(Icons.calendar_month_rounded, 'Work Date', 'March 29, 2026'),
                        ],
                      ),

                      // Section 2: Location Details
                      _buildDetailSection(
                        'Location Details',
                        [
                          _buildDetailRow(Icons.location_on_rounded, 'Worksite', location),
                          _buildDetailRow(Icons.map_rounded, 'Region', 'Dubai, UAE'),
                        ],
                      ),

                      // Section 3: Financial Breakdown
                      _buildDetailSection(
                        'Financial Breakdown',
                        [
                          _buildFinancialRow('Total Received', total, AppTheme.deepNavyBlue),
                          _buildFinancialRow(deductionLabel, deduction, Colors.red.shade900, isDeduction: true),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(color: Colors.white38, thickness: 1),
                          ),
                          _buildFinancialRow('Profit / Net Commission', net, Colors.green.shade900, isNet: true),
                        ],
                      ),

                      // Section 4: Status History
                      _buildDetailSection(
                        'Status History',
                        [
                          _buildStatusHistoryRow('Quotation Generated', '09:30 AM', Icons.description_rounded, completed: true),
                          _buildStatusHistoryRow('Marked as Completed', '04:45 PM', Icons.check_circle_rounded, completed: true, isLast: true),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.deepNavyBlue),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'ENTRY DETAILS',
              style: TextStyle(
                color: AppTheme.deepNavyBlue,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Image.asset('assets/images/logo.png', height: 80),
          const SizedBox(height: 20),
          Text(
            client.toUpperCase(),
            style: const TextStyle(
              color: AppTheme.deepNavyBlue,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.deepNavyBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isOwnCrane ? 'OWN ASSET EXECUTION' : 'COMMISSION WORK DETAILS',
              style: const TextStyle(
                color: AppTheme.deepNavyBlue,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppTheme.deepNavyBlue,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.deepNavyBlue.withValues(alpha: 0.6), size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.deepNavyBlue.withValues(alpha: 0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.deepNavyBlue,
                    fontSize: 20, // AS REQUESTED: Big (20)
                    fontWeight: FontWeight.w900, // AS REQUESTED: Bold (w900)
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(String label, double amount, Color color, {bool isDeduction = false, bool isNet = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.deepNavyBlue.withValues(alpha: 0.7),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            '${isDeduction ? "(-)" : ""} AED ${amount.toStringAsFixed(0)}',
            style: TextStyle(
              color: color,
              fontSize: isNet ? 24 : 20, // Enhanced for math clarity
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHistoryRow(String status, String time, IconData icon, {bool completed = false, bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: completed ? AppTheme.deepNavyBlue : Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 14),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.white38,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status,
                    style: const TextStyle(
                      color: AppTheme.deepNavyBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      color: AppTheme.deepNavyBlue.withValues(alpha: 0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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
}
