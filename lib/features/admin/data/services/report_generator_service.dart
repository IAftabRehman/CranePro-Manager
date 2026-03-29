import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:extend_crane_services/features/admin/data/models/report_entry.dart';

class ReportGeneratorService {
  Future<void> generateAndSharePDF({
    required DateTimeRange range,
    required List<ReportEntry> entries,
    required String companyName,
  }) async {
    final pdf = pw.Document();
    final logoImage = pw.MemoryImage(
      (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List(),
    );

    final totalIncome = entries.fold(0.0, (val, e) => val + e.income);
    final totalExpense = entries.fold(0.0, (val, e) => val + e.expense);
    final netProfit = totalIncome - totalExpense;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(companyName, logoImage, range),
          pw.SizedBox(height: 32),
          _buildSummarySection(totalIncome, totalExpense, netProfit),
          pw.SizedBox(height: 32),
          _buildReportTable(entries),
          pw.SizedBox(height: 60),
          _buildFooter(),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf");
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'Financial Report: ${DateFormat('MMM dd, yyyy').format(range.start)} - ${DateFormat('MMM dd, yyyy').format(range.end)}');
  }

  pw.Widget _buildHeader(String companyName, pw.MemoryImage logo, DateTimeRange range) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Image(logo, width: 80),
            pw.SizedBox(height: 12),
            pw.Text(companyName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('FINANCIAL REPORT', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
            pw.Text(
              '${DateFormat('MMM dd, yyyy').format(range.start)} - ${DateFormat('MMM dd, yyyy').format(range.end)}',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildSummarySection(double income, double expense, double profit) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('TOTAL REVENUE', income, PdfColors.indigo900),
          _buildSummaryItem('TOTAL EXPENSE', expense, PdfColors.red900),
          _buildSummaryItem('NET PROFIT', profit, PdfColors.green900),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryItem(String label, double value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
        pw.SizedBox(height: 4),
        pw.Text('${NumberFormat('#,###').format(value)} AED', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: color)),
      ],
    );
  }

  pw.Widget _buildReportTable(List<ReportEntry> entries) {
    const headers = ['Date', 'Client', 'Service', 'Income', 'Expense', 'Profit'];
    
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: entries.map((e) => [
        DateFormat('dd/MM/yy').format(e.date),
        e.clientName,
        e.serviceType,
        '${e.income}',
        '${e.expense}',
        '${e.profit}',
      ]).toList(),
      headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo900),
      cellStyle: const pw.TextStyle(fontSize: 9),
      rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5))),
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey50),
      cellHeight: 25,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
      },
    );
  }

  pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 12),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Generated by CranePro Manager', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
            pw.Text('Page 1 of 1', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
          ],
        ),
      ],
    );
  }

  Future<void> generateAndShareCSV({
    required DateTimeRange range,
    required List<ReportEntry> entries,
  }) async {
    String csv = 'Date,Client,Service,Income,Expense,Profit\n';
    for (var e in entries) {
      csv += '${DateFormat('dd/MM/yy').format(e.date)},${e.clientName},${e.serviceType},${e.income},${e.expense},${e.profit}\n';
    }

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv");
    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(file.path)], text: 'Financial Data Export (.csv)');
  }
}
