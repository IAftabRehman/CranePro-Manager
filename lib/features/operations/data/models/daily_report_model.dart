import 'package:intl/intl.dart';

enum DailyReportStatus { completed, cancelled, delayed }
enum ExecutionType { ownCrane, outsourced }

class DailyReport {
  final DateTime date;
  final DailyReportStatus status;
  final ExecutionType executionType;
  final double fuelExpense;
  final double commissionEarned;
  final double partnerPayment;
  final String noWorkReason;

  DailyReport({
    required this.date,
    required this.status,
    required this.executionType,
    this.fuelExpense = 0.0,
    this.commissionEarned = 0.0,
    this.partnerPayment = 0.0,
    this.noWorkReason = '',
  });

  String get formattedDate => DateFormat('MMM dd, yyyy').format(date);
  
  bool get isPending => status == DailyReportStatus.delayed;
}
