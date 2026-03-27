import 'package:intl/intl.dart';

enum QuotationStatus { pending, completed, cancelled }

class QuotationServiceEntry {
  String serviceName;
  String duration;
  String location;
  double price;
  DateTime startDate;

  QuotationServiceEntry({
    this.serviceName = '50 Ton Crane',
    this.duration = '1 Day',
    this.location = '',
    this.price = 0.0,
    DateTime? startDate,
  }) : startDate = startDate ?? DateTime.now();

  String get formattedDate => DateFormat('MMM dd, yyyy').format(startDate);
}

class QuotationData {
  String clientName;
  String companyName;
  List<QuotationServiceEntry> entries;
  List<String> terms;
  QuotationStatus status;

  QuotationData({
    this.clientName = '',
    this.companyName = '',
    List<QuotationServiceEntry>? entries,
    List<String>? terms,
    this.status = QuotationStatus.pending,
  })  : entries = entries ?? [QuotationServiceEntry()],
        terms = terms ?? [];

  double get totalPrice => entries.fold(0, (sum, item) => sum + item.price);
}
