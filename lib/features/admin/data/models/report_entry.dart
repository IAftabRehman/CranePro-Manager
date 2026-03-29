class ReportEntry {
  final DateTime date;
  final String clientName;
  final String serviceType;
  final double income;
  final double expense;
  final double profit;

  const ReportEntry({
    required this.date,
    required this.clientName,
    required this.serviceType,
    required this.income,
    required this.expense,
    required this.profit,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'clientName': clientName,
      'serviceType': serviceType,
      'income': income,
      'expense': expense,
      'profit': profit,
    };
  }

  factory ReportEntry.fromMap(Map<String, dynamic> map) {
    return ReportEntry(
      date: DateTime.parse(map['date']),
      clientName: map['clientName'] ?? '',
      serviceType: map['serviceType'] ?? '',
      income: (map['income'] ?? 0.0).toDouble(),
      expense: (map['expense'] ?? 0.0).toDouble(),
      profit: (map['profit'] ?? 0.0).toDouble(),
    );
  }
}
