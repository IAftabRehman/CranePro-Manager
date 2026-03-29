import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/features/reports/presentation/widgets/viewer_report_header.dart';
import 'package:intl/intl.dart';

class MaintenanceLogViewerPage extends StatefulWidget {
  const MaintenanceLogViewerPage({super.key});

  @override
  State<MaintenanceLogViewerPage> createState() => _MaintenanceLogViewerPageState();
}

class _MaintenanceLogViewerPageState extends State<MaintenanceLogViewerPage> {
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
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
                      title: 'Maintenance Log',
                      summaryLabel: 'Total Maintenance ${DateFormat('MMMM').format(DateTime.now())}',
                      summaryValue: 'AED 4,850',
                      fromDate: _fromDate,
                      toDate: _toDate,
                      onSelectDateRange: _selectDateRange,
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'REPAIR & SERVICE HISTORY',
                      style: TextStyle(
                        color: AppTheme.deepNavyBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildMaintenanceTile('Oil & Filter Change', '25 Oct 2026', 1250),
                    _buildMaintenanceTile('Hydraulic Pipe Repair', '22 Oct 2026', 1800),
                    _buildMaintenanceTile('Tyre Replacement (Front)', '18 Oct 2026', 1500),
                    _buildMaintenanceTile('Air Filter Service', '10 Oct 2026', 300),
                    
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
              'MAINTENANCE',
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

  Widget _buildMaintenanceTile(String description, String date, double amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.build_circle_rounded, color: Colors.orange.shade900, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    color: AppTheme.deepNavyBlue,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    color: AppTheme.deepNavyBlue.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'AED ${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              color: AppTheme.deepNavyBlue,
              fontSize: 20, // TASK 4: Big Font Size
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
