import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';
import 'package:extend_crane_services/shared/global_widgets/premium_background.dart';
import 'package:extend_crane_services/features/quotation/data/models/quotation_model.dart';
import 'package:extend_crane_services/features/settings/presentation/providers/business_profile_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'dart:io' show File;
import 'package:extend_crane_services/core/utils/file_saver.dart' as fs;

class PdfPreviewPage extends ConsumerStatefulWidget {
  final QuotationModel data;

  const PdfPreviewPage({super.key, required this.data});

  @override
  ConsumerState<PdfPreviewPage> createState() => _PdfPreviewPageState();
}

class _PdfPreviewPageState extends ConsumerState<PdfPreviewPage> {
  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();
    final profile = ref.read(businessProfileProvider);
    
    // Load logo from profile path (mocking asset for now as per plan)
    final logo = await rootBundle.load('assets/images/logo.png');
    final logoImage = pw.MemoryImage(logo.buffer.asUint8List());
    
    // Derived Date
    final quoteDateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final startDateStr = widget.data.entries.isNotEmpty
        ? DateFormat('yyyy-MM-dd').format(widget.data.entries.first.startDate)
        : quoteDateStr;

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(55),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Section
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

              // Business Info from Provider
              pw.Expanded(
                child: pw.Column(
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
                                  ),
                                ),
                                pw.TextSpan(
                                  text: widget.data.clientName.trim(),
                                  style: pw.TextStyle(
                                    fontSize: 13,
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
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13),
                        ),
                        pw.Text(
                          profile.businessName,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      children: [
                        pw.Text(
                          'Address: ',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                        ),
                        pw.Text(
                          profile.address,
                          style: const pw.TextStyle(fontSize: 12),
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
                        pw.Text(
                          profile.email,
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.blue,
                            decoration: pw.TextDecoration.underline,
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
                        pw.Text(
                          profile.website,
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.blue,
                            decoration: pw.TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Main Table (Entries)
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.black, width: 1.0),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.cyan100),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Service Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                      ),
                      if (widget.data.entries.any((e) => e.duration.isNotEmpty))
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Duration', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                        ),
                      if (widget.data.entries.any((e) => e.location.isNotEmpty))
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Location', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                        ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Price (AED)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  ...widget.data.entries.map(
                    (e) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(e.serviceName.isEmpty ? '-' : e.serviceName, style: const pw.TextStyle(fontSize: 12)),
                        ),
                        if (widget.data.entries.any((entry) => entry.duration.isNotEmpty))
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(e.duration, style: const pw.TextStyle(fontSize: 12)),
                          ),
                        if (widget.data.entries.any((entry) => entry.location.isNotEmpty))
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(e.location, style: const pw.TextStyle(fontSize: 12)),
                          ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(e.price.toStringAsFixed(0), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 10),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Total: ${widget.data.totalPrice.toStringAsFixed(0)} AED',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                ),
              ),
              pw.SizedBox(height: 30),

              // Terms & Conditions
              if (widget.data.terms.isNotEmpty) ...[
                pw.Text(
                  'Terms & Conditions:',
                  style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline),
                ),
                pw.SizedBox(height: 12),
                ...List.generate(
                  widget.data.terms.length,
                  (i) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 6),
                    child: pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          pw.TextSpan(text: '${i + 1}. ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                          pw.TextSpan(text: widget.data.terms[i], style: const pw.TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              pw.Spacer(),

              pw.Center(
                child: pw.Text('We look forward to serving you', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
              ),
              pw.SizedBox(height: 30),

              pw.Align(
                alignment: pw.Alignment.bottomRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Authorized Signature', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(
                      profile.businessName,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
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
          Expanded(
            child: Container(
              color: Colors.transparent,
              padding: isTablet ? const EdgeInsets.all(32.0) : EdgeInsets.zero,
              child: PdfPreview(
                build: (format) => _generatePdf(format),
                useActions: false,
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
          decoration: const BoxDecoration(
            color: Color(0x0DFFFFFF),
            border: Border(
              top: BorderSide(color: Color(0x1AFFFFFF)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PdfActionButton(
                icon: Icons.download,
                label: 'Save',
                theme: theme,
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    final pdfBytes = await _generatePdf(PdfPageFormat.a4);
                    final filename = 'Quotation_${widget.data.clientName.replaceAll(" ", "_")}.pdf';
                    if (kIsWeb) {
                      await fs.saveFileWeb(pdfBytes, filename);
                      if (mounted) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Download started successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } else {
                      final directory = await getApplicationDocumentsDirectory();
                      final file = File('${directory.path}/$filename');
                      await file.writeAsBytes(pdfBytes);
                      if (mounted) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Saved to Documents: ${file.path}'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Error saving PDF: $e'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  }
                },
              ),
              PdfActionButton(
                icon: Icons.share,
                label: 'Share',
                theme: theme,
                isPrimary: true,
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    final pdfBytes = await _generatePdf(PdfPageFormat.a4);
                    final filename = 'Quotation_${widget.data.clientName.replaceAll(" ", "_")}.pdf';
                    await Printing.sharePdf(
                      bytes: pdfBytes,
                      filename: filename,
                    );
                  } catch (e) {
                    if (mounted) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Error sharing PDF: $e'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  }
                },
              ),
              PdfActionButton(
                icon: Icons.print,
                label: 'Print',
                theme: theme,
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    final pdfBytes = await _generatePdf(PdfPageFormat.a4);
                    await Printing.layoutPdf(
                      onLayout: (PdfPageFormat format) async => pdfBytes,
                      name: 'Quotation_${widget.data.clientName.replaceAll(" ", "_")}',
                    );
                  } catch (e) {
                    if (mounted) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Error printing PDF: $e'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PdfActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;
  final bool isPrimary;
  final VoidCallback onTap;

  const PdfActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.theme,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPrimary ? theme.colorScheme.secondary : Colors.white;
    final textColor = isPrimary ? theme.colorScheme.primary : Colors.white;
    // Level 5: Cache the responsive check to avoid computing it twice per build.
    final isMobile = Responsive.isMobile(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 12 : 16,
          horizontal: isMobile ? 24 : 48,
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

