import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/services/pdf_service.dart';
import '../../data/models/quotation_model.dart';

class QuotationDetailPage extends ConsumerWidget {
  final QuotationModel quotation;

  const QuotationDetailPage({super.key, required this.quotation});

  void _handleShare(BuildContext context) async {
    try {
      final pdfBytes = await PdfService.generateInvoice(quotation);
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'Invoice_${quotation.clientName.replaceAll(' ', '_')}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = quotation.status == 'completed'
        ? Colors.green
        : (quotation.status == 'cancelled' ? Colors.red : Colors.orange);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Quotation Details', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: () => _handleShare(context),
            tooltip: 'Export as PDF',
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.lavenderBlueGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(statusColor),
                const SizedBox(height: 24),
                _buildInfoSection(),
                const SizedBox(height: 24),
                _buildEntriesTable(),
                const SizedBox(height: 24),
                _buildFinancialSummary(),
                const SizedBox(height: 40),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quotation.clientName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'ID: ${quotation.id.toUpperCase()}',
                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor),
            ),
            child: Text(
              quotation.status.toUpperCase(),
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.location_on_outlined, 'Site Location', quotation.siteLocation),
          const Divider(height: 24, color: Colors.white24),
          _buildInfoRow(Icons.calendar_today_outlined, 'Work Date', DateFormat('dd MMM yyyy').format(quotation.workDate)),
          const Divider(height: 24, color: Colors.white24),
          _buildInfoRow(Icons.construction_outlined, 'Service Type', quotation.serviceType),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.lavenderPrimary, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.6))),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
          ],
        ),
      ],
    );
  }

  Widget _buildEntriesTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 12),
          child: Text('SERVICES RENDERED', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: quotation.entries.length,
          itemBuilder: (context, index) {
            final entry = quotation.entries[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.serviceName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Duration: ${entry.duration}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  ),
                  Text(
                    'AED ${entry.price.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.lavenderPrimary),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFinancialSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Total Amount', 'AED ${quotation.totalAmount.toStringAsFixed(0)}'),
          const SizedBox(height: 12),
          _buildSummaryRow('Advance Paid', '- AED ${quotation.advancePaid.toStringAsFixed(0)}', isNegative: true),
          const Divider(height: 32, color: Colors.white24),
          _buildSummaryRow('Balance Due', 'AED ${quotation.balanceAmount.toStringAsFixed(0)}', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isNegative = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isNegative ? Colors.redAccent : (isTotal ? AppTheme.lavenderPrimary : Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _handleShare(context),
            icon: const Icon(Icons.share),
            label: const Text('SHARE INVOICE'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
