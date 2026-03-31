import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../features/quotation/data/models/quotation_model.dart';

class PdfService {
  static Future<Uint8List> generateInvoice(QuotationModel quotation) async {
    final pdf = pw.Document();

    // Load logo if available, or just use text if not
    pw.Widget logo;
    try {
      final logoData = await rootBundle.load('assets/images/logo.png');
      final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
      logo = pw.Image(logoImage, height: 60);
    } catch (_) {
      logo = pw.Text('LOGO', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold));
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header: Company Branding
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'BAHADAR TRANSPORT &',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                    ),
                    pw.Text(
                      'HEAVY EQUIPMENT RENTAL',
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Contact: +971 XXX XXX XXXX', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('Email: info@bahadartransport.com', style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
                logo,
              ],
            ),
            pw.Divider(height: 32, thickness: 2, color: PdfColors.blue900),

            // Invoice Title & Info
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Invoice To:', quotation.clientName, isBold: true),
                    _buildInfoRow('Location:', quotation.siteLocation),
                    _buildInfoRow('Service Type:', quotation.serviceType),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('INVOICE / QUOTATION', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                    pw.SizedBox(height: 8),
                    _buildInfoRow('ID:', quotation.id.substring(0, 8).toUpperCase()),
                    _buildInfoRow('Date:', DateFormat('dd MMM yyyy').format(quotation.workDate)),
                    _buildInfoRow('Status:', quotation.status.toUpperCase()),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 32),

            // Service Breakdown Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(1),
              },
              children: [
                // Table Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.blue900),
                  children: [
                    _buildTableCell('Description', isHeader: true),
                    _buildTableCell('Duration', isHeader: true),
                    _buildTableCell('Amount (AED)', isHeader: true),
                  ],
                ),
                // Data Rows
                ...quotation.entries.map((entry) => pw.TableRow(
                      children: [
                        _buildTableCell(entry.serviceName),
                        _buildTableCell(entry.duration),
                        _buildTableCell(entry.price.toStringAsFixed(2), align: pw.Alignment.centerRight),
                      ],
                    )),
              ],
            ),

            // Financial Summary
            pw.SizedBox(height: 24),
            pw.Row(
              children: [
                pw.Spacer(flex: 2),
                pw.Expanded(
                  flex: 1,
                  child: pw.Column(
                    children: [
                      _buildSummaryRow('Subtotal:', quotation.totalAmount.toStringAsFixed(2)),
                      _buildSummaryRow('Advance Paid:', '- ${quotation.advancePaid.toStringAsFixed(2)}', color: PdfColors.red900),
                      pw.Divider(),
                      _buildSummaryRow('Balance Due:', quotation.balanceAmount.toStringAsFixed(2), isTotal: true),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 48),
            // Footer
            pw.Center(
              child: pw.Text('Thank you for your business!', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, fontItalic: pw.Font.timesItalic())),
            ),
            pw.SizedBox(height: 64),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildSignatureLine('Customer Signature'),
                _buildSignatureLine('Authorized Signature'),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(text: '$label ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
            pw.TextSpan(text: value, style: pw.TextStyle(fontSize: 10, fontWeight: isBold ? pw.FontWeight.bold : null)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false, pw.Alignment align = pw.Alignment.centerLeft}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Align(
        alignment: align,
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 10,
            color: isHeader ? PdfColors.white : PdfColors.black,
            fontWeight: isHeader ? pw.FontWeight.bold : null,
          ),
        ),
      ),
    );
  }

  static pw.Widget _buildSummaryRow(String label, String value, {bool isTotal = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: isTotal ? 12 : 10)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: isTotal ? 12 : 10,
              color: color ?? (isTotal ? PdfColors.blue900 : PdfColors.black),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSignatureLine(String label) {
    return pw.Column(
      children: [
        pw.Container(width: 150, decoration: pw.BoxDecoration(
           border: const pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1))),
        ),
        pw.SizedBox(height: 4),
        pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
      ],
    );
  }
}
