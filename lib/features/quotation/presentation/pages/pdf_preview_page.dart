import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';

class PdfPreviewPage extends StatefulWidget {
  const PdfPreviewPage({super.key});

  @override
  State<PdfPreviewPage> createState() => _PdfPreviewPageState();
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  bool _includeSignature = false;

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('CranePro Services', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                      pw.Text('Heavy Lifting & Equipment Rental', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('QUOTATION', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.amber700)),
                      pw.Text('Date: Oct 26, 2026', style: const pw.TextStyle(fontSize: 12)),
                      pw.Text('Quote #: QT-2026-1042', style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              
              // Client Details
              pw.Text('Client Information', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              pw.Text('Company: Emaar Constructions'),
              pw.Text('Location: Downtown Dubai Site A'),
              pw.SizedBox(height: 20),

              // Job Details
              pw.Text('Crane & Pricing Details', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Equipment:'),
                  pw.Text('50 Ton Crane (Model XC-50)'),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Duration:'),
                  pw.Text('8 Hours (1 Shift)'),
                ],
              ),
              pw.SizedBox(height: 20),

              // Financials
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                child: pw.Column(
                  children: [
                    pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Base Rent'), pw.Text('AED 4,500.00')]),
                    pw.SizedBox(height: 5),
                    pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('VAT (5%)'), pw.Text('AED 225.00')]),
                    pw.Divider(),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, 
                      children: [
                        pw.Text('Grand Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)), 
                        pw.Text('AED 4,725.00', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ]
                    ),
                  ],
                ),
              ),
              
              pw.Spacer(),
              
              // Signature Block
              if (_includeSignature)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Container(
                          height: 50,
                          width: 150,
                        ), // Signature Placeholder gap
                        pw.SizedBox(height: 5),
                        pw.Container(width: 150, height: 1, color: PdfColors.black),
                        pw.SizedBox(height: 2),
                        pw.Text('Authorized Signature', style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  void _showShareSheet() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Share Quotation via', style: theme.textTheme.displayLarge?.copyWith(fontSize: 18)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareIcon(Icons.message, 'WhatsApp', Colors.green),
                  _buildShareIcon(Icons.email, 'Email', Colors.blue),
                  _buildShareIcon(Icons.link, 'Copy Link', Colors.grey[700]!),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareIcon(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quotation Preview'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Signature Toggle Header
          Container(
            color: theme.colorScheme.surface,
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.scale(context, 16).clamp(16.0, 32.0),
              vertical: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Include Digital Signature',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: _includeSignature,
                  activeTrackColor: theme.colorScheme.secondary,
                  onChanged: (val) {
                    setState(() {
                      _includeSignature = val;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // PDF Viewer utilizing InteractiveViewer internally via PdfPreview
          Expanded(
            child: Container(
              color: Colors.grey[200],
              padding: isTablet ? const EdgeInsets.all(32.0) : EdgeInsets.zero,
              child: PdfPreview(
                build: (format) => _generatePdf(format),
                useActions: false, // Disable default printing package actions
                canChangeOrientation: false,
                canChangePageFormat: false,
                allowPrinting: false,
                allowSharing: false,
                pdfFileName: 'Quotation_QT-2026-1042.pdf',
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 16,
            horizontal: Responsive.scale(context, 16).clamp(16.0, 32.0),
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(Icons.download, 'Save', theme),
              _buildActionButton(Icons.share, 'Share', theme, isPrimary: true, onTap: _showShareSheet),
              _buildActionButton(Icons.print, 'Print', theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, ThemeData theme, {bool isPrimary = false, VoidCallback? onTap}) {
    final color = isPrimary ? theme.colorScheme.secondary : theme.colorScheme.primary;
    final textColor = isPrimary ? theme.colorScheme.primary : theme.colorScheme.surface;
    
    return InkWell(
      onTap: onTap ?? () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label action triggered')));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: Responsive.isMobile(context) ? 12 : 16,
          horizontal: Responsive.isMobile(context) ? 24 : 48,
        ),
        decoration: BoxDecoration(
          color: isPrimary ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isPrimary ? textColor : color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? textColor : color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
