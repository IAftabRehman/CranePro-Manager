import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:extend_crane_services/core/themes/app_theme.dart';
import 'package:extend_crane_services/shared/global_widgets/custom_button.dart';
import 'package:extend_crane_services/features/admin/data/models/report_entry.dart';
import 'package:extend_crane_services/features/admin/data/services/report_generator_service.dart';

class AdminExportPage extends StatefulWidget {
  const AdminExportPage({super.key});

  @override
  State<AdminExportPage> createState() => _AdminExportPageState();
}

class _AdminExportPageState extends State<AdminExportPage> {
  DateTimeRange? _selectedRange;
  bool _includeQuotations = true;
  bool _includeDirectWork = true;
  bool _includeMaintenance = true;
  bool _includePartners = true;
  bool _isGenerating = false;

  final ReportGeneratorService _reportService = ReportGeneratorService();

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedRange,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            // Text aur Selection colors
            colorScheme: const ColorScheme.light(
              primary: AppTheme.deepNavyBlue,
              // Selected dates
              onPrimary: Colors.red,
              // Text on selected dates
              surface: Colors.transparent,
              // Calendar background transparent rakhein
              onSurface: Colors.black, // Default dates color
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.transparent,
              // Inner background transparent
              rangeSelectionBackgroundColor: Colors.red.withValues(alpha: 0.4),
              dayStyle: const TextStyle(fontWeight: FontWeight.w900),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.deepNavyBlue,
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
          // Yahan hum Gradient apply kar rahe hain
          child: Container(
            decoration: const BoxDecoration(
              gradient:
                  AppTheme.lavenderBlueGradient, // Aapka specific gradient
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedRange = picked);
    }
  }

  Future<void> _generatePDF() async {
    if (_selectedRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date range first')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      // 1. Generate realistic mock data for the range
      final data = _generateMockReportData();

      // 2. Generate and Share File
      await _reportService.generateAndSharePDF(
        range: _selectedRange!,
        entries: data,
        companyName: 'BAHADAR TRANSPORT',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report Generated Successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _generateCSV() async {
    if (_selectedRange == null) return;
    setState(() => _isGenerating = true);

    try {
      final data = _generateMockReportData();
      await _reportService.generateAndShareCSV(
        range: _selectedRange!,
        entries: data,
      );
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  List<ReportEntry> _generateMockReportData() {
    return [
      ReportEntry(
        date: DateTime.now().subtract(const Duration(days: 1)),
        clientName: 'Emaar Sites',
        serviceType: '50 Ton Crane',
        income: 15000,
        expense: 2500,
        profit: 12500,
      ),
      ReportEntry(
        date: DateTime.now().subtract(const Duration(days: 3)),
        clientName: 'Binladin Group',
        serviceType: 'Monthly Lease',
        income: 85000,
        expense: 12000,
        profit: 73000,
      ),
      ReportEntry(
        date: DateTime.now().subtract(const Duration(days: 5)),
        clientName: 'Al-Fajr Projects',
        serviceType: '100 Ton Crane',
        income: 25000,
        expense: 5000,
        profit: 20000,
      ),
      ReportEntry(
        date: DateTime.now().subtract(const Duration(days: 7)),
        clientName: 'Dubai Metro',
        serviceType: 'Emergency Repair',
        income: 12000,
        expense: 3000,
        profit: 9000,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildDateSelector(),
          const SizedBox(height: 32),
          _buildFilterSection(),
          const SizedBox(height: 20),
          _isGenerating
              ? const CircularProgressIndicator(color: AppTheme.deepNavyBlue)
              : Column(
                  children: [
                    CraneButton(
                      text: 'Generate Report',
                      onPressed: _generatePDF,
                      icon: null,
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: _generateCSV,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                        shadowColor: Colors.black,
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.table_view_outlined, size: 25),
                          const SizedBox(width: 10),
                          Text('Export to Excel (.csv)'),
                        ],
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _selectDateRange,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              color: AppTheme.deepNavyBlue,
              size: 32,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Range',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    _selectedRange == null
                        ? 'No Range Selected'
                        : '${DateFormat('MMM dd').format(_selectedRange!.start)} - ${DateFormat('MMM dd').format(_selectedRange!.end)}',
                    style: const TextStyle(
                      color: AppTheme.deepNavyBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_right_rounded,
              color: AppTheme.deepNavyBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Report Filters',
          style: TextStyle(
            color: AppTheme.deepNavyBlue,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        _buildFilterToggle(
          'INCLUDE QUOTATIONS',
          _includeQuotations,
          (v) => setState(() => _includeQuotations = v),
        ),
        _buildFilterToggle(
          'INCLUDE DIRECT WORK',
          _includeDirectWork,
          (v) => setState(() => _includeDirectWork = v),
        ),
        _buildFilterToggle(
          'MAINTENANCE EXPENSES',
          _includeMaintenance,
          (v) => setState(() => _includeMaintenance = v),
        ),
        _buildFilterToggle(
          'PARTNER PAYMENTS',
          _includePartners,
          (v) => setState(() => _includePartners = v),
        ),
      ],
    );
  }

  Widget _buildFilterToggle(
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: SwitchListTile(
        title: Text(
          label,
          style: const TextStyle(
            color: AppTheme.deepNavyBlue,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.deepNavyBlue,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      ),
    );
  }
}

