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
            colorScheme: const ColorScheme.light(
              primary: AppTheme.deepNavyBlue,
              onPrimary: Colors.white,
              onSurface: AppTheme.deepNavyBlue,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppTheme.deepNavyBlue),
            ),
          ),
          child: child!,
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
          const SnackBar(content: Text('Report Generated Successfully!'), backgroundColor: Colors.green),
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
      ReportEntry(date: DateTime.now().subtract(const Duration(days: 1)), clientName: 'Emaar Sites', serviceType: '50 Ton Crane', income: 15000, expense: 2500, profit: 12500),
      ReportEntry(date: DateTime.now().subtract(const Duration(days: 3)), clientName: 'Binladin Group', serviceType: 'Monthly Lease', income: 85000, expense: 12000, profit: 73000),
      ReportEntry(date: DateTime.now().subtract(const Duration(days: 5)), clientName: 'Al-Fajr Projects', serviceType: '100 Ton Crane', income: 25000, expense: 5000, profit: 20000),
      ReportEntry(date: DateTime.now().subtract(const Duration(days: 7)), clientName: 'Dubai Metro', serviceType: 'Emergency Repair', income: 12000, expense: 3000, profit: 9000),
    ];
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
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildDateSelector(),
                      const SizedBox(height: 32),
                      _buildFilterSection(),
                      const SizedBox(height: 60),
                      _isGenerating 
                        ? const CircularProgressIndicator(color: AppTheme.deepNavyBlue)
                        : Column(
                            children: [
                              CraneButton(
                                text: 'GENERATE PDF REPORT',
                                onPressed: _generatePDF,
                                icon: Icons.picture_as_pdf_outlined,
                              ),
                              const SizedBox(height: 20),
                              TextButton.icon(
                                onPressed: _generateCSV,
                                icon: const Icon(Icons.table_view_outlined, color: AppTheme.deepNavyBlue),
                                label: const Text(
                                  'Export to Excel (.csv)',
                                  style: TextStyle(color: AppTheme.deepNavyBlue, fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.deepNavyBlue),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'PROFESSIONAL EXPORT HUB',
              style: TextStyle(
                color: AppTheme.deepNavyBlue,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _selectDateRange,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, color: AppTheme.deepNavyBlue, size: 32),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SELECTED RANGE',
                    style: TextStyle(color: AppTheme.deepNavyBlue.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                  ),
                  Text(
                    _selectedRange == null 
                      ? 'No Range Selected' 
                      : '${DateFormat('MMM dd').format(_selectedRange!.start)} - ${DateFormat('MMM dd').format(_selectedRange!.end)}',
                    style: const TextStyle(color: AppTheme.deepNavyBlue, fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_right_rounded, color: AppTheme.deepNavyBlue),
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
          'REPORT FILTERS',
          style: TextStyle(color: AppTheme.deepNavyBlue, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
        const SizedBox(height: 20),
        _buildFilterToggle('INCLUDE QUOTATIONS', _includeQuotations, (v) => setState(() => _includeQuotations = v)),
        _buildFilterToggle('INCLUDE DIRECT WORK', _includeDirectWork, (v) => setState(() => _includeDirectWork = v)),
        _buildFilterToggle('MAINTENANCE EXPENSES', _includeMaintenance, (v) => setState(() => _includeMaintenance = v)),
        _buildFilterToggle('PARTNER PAYMENTS', _includePartners, (v) => setState(() => _includePartners = v)),
      ],
    );
  }

  Widget _buildFilterToggle(String label, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: SwitchListTile(
        title: Text(label, style: const TextStyle(color: AppTheme.deepNavyBlue, fontSize: 12, fontWeight: FontWeight.w800)),
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.deepNavyBlue,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      ),
    );
  }
}
