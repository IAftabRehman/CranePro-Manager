import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/features/reports/presentation/widgets/viewer_report_header.dart';
import 'package:extend_crane_services/features/reports/presentation/pages/work_entry_details_page.dart';
import 'dart:ui';

class WorkHistoryViewerPage extends StatefulWidget {
  const WorkHistoryViewerPage({super.key});

  @override
  State<WorkHistoryViewerPage> createState() => _WorkHistoryViewerPageState();
}

class _WorkHistoryViewerPageState extends State<WorkHistoryViewerPage> {
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _toDate = DateTime.now();

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.deepNavyBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.deepNavyBlue,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
    }
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
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  children: [
                    ViewerReportHeader(
                      title: 'Work History',
                      summaryLabel: 'Total Profit for period',
                      summaryValue: 'AED 38,420',
                      fromDate: _fromDate,
                      toDate: _toDate,
                      onSelectDateRange: _selectDateRange,
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'DETAILED TRANSACTIONS',
                      style: TextStyle(
                        color: AppTheme.deepNavyBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Own Crane Entry
                    _buildHistoryCard(
                      context,
                      isOwnCrane: true,
                      client: 'Emaar Properties',
                      location: 'Dubai Marina',
                      total: 4500,
                      deduction: 450,
                      deductionLabel: 'Fuel Cost',
                    ),
                    
                    // Commission Entry
                    _buildHistoryCard(
                      context,
                      isOwnCrane: false,
                      client: 'Sobha Realty',
                      location: 'Dubai Creek Harbor',
                      total: 8500,
                      deduction: 6800,
                      deductionLabel: 'Outsourced Cost',
                    ),
                    
                    _buildHistoryCard(
                      context,
                      isOwnCrane: true,
                      client: 'Damac Hills',
                      location: 'Al Qudra Road',
                      total: 2800,
                      deduction: 320,
                      deductionLabel: 'Fuel Cost',
                    ),
                    
                    _buildHistoryCard(
                      context,
                      isOwnCrane: false,
                      client: 'Azizi Developments',
                      location: 'Al Furjan',
                      total: 12000,
                      deduction: 10200,
                      deductionLabel: 'Outsourced Cost',
                    ),
                    
                    const SizedBox(height: 40),
                  ],
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
              'WORK REPORTS',
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

  Widget _buildHistoryCard(
    BuildContext context, {
    required bool isOwnCrane,
    required String client,
    required String location,
    required double total,
    required double deduction,
    required String deductionLabel,
  }) {
    final net = total - deduction;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WorkEntryDetailsPage(
                  isOwnCrane: isOwnCrane,
                  client: client,
                  location: location,
                  total: total,
                  deduction: deduction,
                  deductionLabel: deductionLabel,
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.deepNavyBlue.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isOwnCrane ? Icons.architecture_rounded : Icons.handshake_rounded,
                            color: AppTheme.deepNavyBlue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                client.toUpperCase(),
                                style: const TextStyle(
                                  color: AppTheme.deepNavyBlue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                location,
                                style: TextStyle(
                                  color: AppTheme.deepNavyBlue.withValues(alpha: 0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: AppTheme.deepNavyBlue),
                      ],
                    ),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: Colors.white, thickness: 1),
                    ),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCalculationCol(isOwnCrane ? 'Gross Total' : 'Total Quotation', 'AED ${total.toStringAsFixed(0)}'),
                        _buildCalculationCol(deductionLabel, '(-) AED ${deduction.toStringAsFixed(0)}', isDeduction: true),
                        _buildCalculationCol(isOwnCrane ? 'NET PROFIT' : 'NET COMMISSION', 'AED ${net.toStringAsFixed(0)}', isNet: true),
                      ],
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

  Widget _buildCalculationCol(String label, String value, {bool isDeduction = false, bool isNet = false}) {
    Color valColor = AppTheme.deepNavyBlue;
    if (isDeduction) valColor = Colors.orange.shade900;
    if (isNet) valColor = Colors.green.shade900;
    
    return Column(
      crossAxisAlignment: isNet ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: AppTheme.deepNavyBlue.withValues(alpha: 0.6),
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valColor,
            fontSize: isNet ? 18 : 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

