import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';
import 'package:extend_crane_services/shared/global_widgets/premium_background.dart';
import 'package:extend_crane_services/features/quotation/data/models/quotation_model.dart';

class PdfPreviewPage extends StatefulWidget {
  final QuotationData data;

  const PdfPreviewPage({super.key, required this.data});

  @override
  State<PdfPreviewPage> createState() => _PdfPreviewPageState();
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  bool _includeSignature = false;

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();
    final logo = await rootBundle.load('assets/images/logo.png');
    final logoImage = pw.MemoryImage(logo.buffer.asUint8List());
    final primaryColor = PdfColors.blue900;

    // Derived Date
    final quoteDateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final startDateStr = widget.data.entries.isNotEmpty
        ? DateFormat('yyyy-MM-dd').format(widget.data.entries.first.startDate)
        : quoteDateStr;

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(55),
        // Increased margins for breathing room
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // TASK 1: Header Section (Top)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(logoImage, height: 60),
                  pw.Expanded(
                    child: pw.Center(
                      child: pw.Text(
                        'QUOTATION',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 50),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Quotation Date: $quoteDateStr',
                    style: const pw.TextStyle(
                      fontSize: 13,
                      color: PdfColors.grey900,
                    ),
                  ),
                  pw.Text(
                    'Starting Date: $startDateStr',
                    style: const pw.TextStyle(
                      fontSize: 13,
                      color: PdfColors.grey900,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // TASK 2: Service Provider & Recipient Info
              pw.Expanded(child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (widget.data.clientName.trim().isNotEmpty)
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.RichText(
                          text: pw.TextSpan(
                            children: [
                              pw.TextSpan(
                                text: 'Quotation To: ',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 13,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.TextSpan(
                                text: widget.data.clientName.trim(),
                                style: pw.TextStyle(
                                  fontSize: 13,
                                  color: PdfColors.black,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    children: [
                      pw.Text(
                        'Quotation From: ',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      pw.Text(
                        'Bahadar Transport and Crane Services',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 13,
                          color: PdfColors.black,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    children: [
                      pw.Text(
                        'Address: ',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      pw.Text(
                        'Musaffah-M26 Abu Dhabi, UAE',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.black,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    children: [
                      pw.Text(
                        'Email: ',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                      pw.UrlLink(
                        destination: 'mailto:info@bahadartransport.com',
                        child: pw.Text(
                          'info@bahadartransport.com',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.blue,
                            decoration: pw.TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    children: [
                      pw.Text(
                        'Web: ',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                      pw.UrlLink(
                        destination: 'https://bahadartransport.com',
                        child: pw.Text(
                          'bahadartransport.com',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.blue,
                            decoration: pw.TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),),

              pw.SizedBox(height: 30),

              // TASK 3: Main Table (Entries) with Dynamic Columns
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.black, width: 1.0),
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.cyan100),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Service Name',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (widget.data.entries.any((e) => e.duration.isNotEmpty))
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Duration',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      if (widget.data.entries.any((e) => e.location.isNotEmpty))
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Location',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Price (AED)',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Table Rows
                  ...widget.data.entries.map(
                    (e) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            e.serviceName.isEmpty ? '-' : e.serviceName,
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                        ),
                        if (widget.data.entries.any(
                          (entry) => entry.duration.isNotEmpty,
                        ))
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              e.duration,
                              style: const pw.TextStyle(fontSize: 12),
                            ),
                          ),
                        if (widget.data.entries.any(
                          (entry) => entry.location.isNotEmpty,
                        ))
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              e.location,
                              style: const pw.TextStyle(fontSize: 12),
                            ),
                          ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            e.price.toStringAsFixed(0),
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Grand Total Area
              pw.SizedBox(height: 10),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  child: pw.Text(
                    'Total: ${widget.data.totalPrice.toStringAsFixed(0)} AED',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(height: 30),

              // TASK 4: Terms & Conditions
              if (widget.data.terms.isNotEmpty) ...[
                pw.Text(
                  'Terms & Conditions:',
                  style: pw.TextStyle(
                    fontSize: 15,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
                pw.SizedBox(height: 12),
                ...List.generate(
                  widget.data.terms.length,
                  (i) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 6),
                    child: pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          pw.TextSpan(
                            text: '${i + 1}. ',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          pw.TextSpan(
                            text: widget.data.terms[i],
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              pw.Spacer(),

              // TASK 4: Closing Line & Signature
              pw.Center(
                child: pw.Text(
                  'We look forward to serving you',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              pw.SizedBox(height: 30),

              pw.Align(
                alignment: pw.Alignment.bottomRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Chief Executive Officer',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      'Bahadar Khan',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Share Quotation via',
                style: theme.textTheme.displayLarge?.copyWith(fontSize: 18),
              ),
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
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = Responsive.isTablet(context);

    return PremiumScaffold(
      appBar: AppBar(
        title: const Text(
          'Quotation Preview',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Signature Toggle Header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.scale(context, 16).clamp(16.0, 32.0),
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Include Digital Signature',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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
              color: Colors.transparent,
              padding: isTablet ? const EdgeInsets.all(32.0) : EdgeInsets.zero,
              child: PdfPreview(
                build: (format) => _generatePdf(format),
                useActions: false,
                // Disable default printing package actions
                canChangeOrientation: false,
                canChangePageFormat: false,
                allowPrinting: false,
                allowSharing: false,
                pdfFileName:
                    'Quotation_${widget.data.clientName.replaceAll(" ", "_")}.pdf',
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
            color: Colors.white.withValues(alpha: 0.05),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(Icons.download, 'Save', theme),
              _buildActionButton(
                Icons.share,
                'Share',
                theme,
                isPrimary: true,
                onTap: _showShareSheet,
              ),
              _buildActionButton(Icons.print, 'Print', theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    ThemeData theme, {
    bool isPrimary = false,
    VoidCallback? onTap,
  }) {
    final color = isPrimary ? theme.colorScheme.secondary : Colors.white;
    final textColor = isPrimary ? theme.colorScheme.primary : Colors.white;

    return InkWell(
      onTap:
          onTap ??
          () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('$label action triggered')));
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
