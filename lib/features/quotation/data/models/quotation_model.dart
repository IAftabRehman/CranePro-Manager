import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

enum QuotationStatus { pending, completed, cancelled }

class QuotationServiceEntry {
  String serviceName;
  String duration;
  String location;
  double price;
  DateTime startDate;

  QuotationServiceEntry({
    this.serviceName = 'Standard Service',
    this.duration = '1 Day',
    this.location = '',
    this.price = 0.0,
    DateTime? startDate,
  }) : startDate = startDate ?? DateTime.now();

  String get formattedDate => DateFormat('MMM dd, yyyy').format(startDate);

  Map<String, dynamic> toMap() {
    return {
      'serviceName': serviceName,
      'duration': duration,
      'location': location,
      'price': price,
      'startDate': Timestamp.fromDate(startDate),
    };
  }

  factory QuotationServiceEntry.fromMap(Map<String, dynamic> map) {
    return QuotationServiceEntry(
      serviceName: map['serviceName'] ?? '',
      duration: map['duration'] ?? '',
      location: map['location'] ?? '',
      price: double.parse((map['price'] ?? 0.0).toString()),
      startDate: map['startDate'] is Timestamp 
          ? (map['startDate'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }
}

class QuotationModel {
  final String id;
  final String operatorId;
  final String clientName;
  final String siteLocation;
  final String serviceType;
  final double totalAmount;
  final double advancePaid;
  final double balanceAmount;
  final double commission;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime workDate;
  final bool isMidnightUpdateRequired;
  
  // UI & Business Logic Fields
  final String companyName;
  final List<QuotationServiceEntry> entries;
  final List<String> terms;
  final String? cancellationReason;
  final String? pdfUrl;

  QuotationModel({
    required this.id,
    required this.operatorId,
    required this.clientName,
    required this.siteLocation,
    required this.serviceType,
    required this.totalAmount,
    this.advancePaid = 0.0,
    required this.balanceAmount,
    this.commission = 0.0,
    this.status = 'pending',
    required this.createdAt,
    required this.updatedAt,
    required this.workDate,
    this.isMidnightUpdateRequired = true,
    this.companyName = '',
    this.entries = const [],
    this.terms = const [],
    this.cancellationReason,
    this.pdfUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'operatorId': operatorId,
      'clientName': clientName,
      'siteLocation': siteLocation,
      'serviceType': serviceType,
      'totalAmount': totalAmount,
      'advancePaid': advancePaid,
      'balanceAmount': totalAmount - advancePaid,
      'commission': commission,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'workDate': Timestamp.fromDate(workDate),
      'isMidnightUpdateRequired': isMidnightUpdateRequired,
      'companyName': companyName,
      'entries': entries.map((e) => e.toMap()).toList(),
      'terms': terms,
      'cancellationReason': cancellationReason,
      'pdfUrl': pdfUrl,
    };
  }

  factory QuotationModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    final double total = double.parse((map['totalAmount'] ?? 0.0).toString());
    final double advance = double.parse((map['advancePaid'] ?? 0.0).toString());
    final double comm = double.parse((map['commission'] ?? 0.0).toString());

    return QuotationModel(
      id: docId ?? map['id'] ?? '',
      operatorId: map['operatorId'] ?? '',
      clientName: map['clientName'] ?? '',
      siteLocation: map['siteLocation'] ?? '',
      serviceType: map['serviceType'] ?? '',
      totalAmount: total,
      advancePaid: advance,
      balanceAmount: total - advance,
      commission: comm,
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : DateTime.now(),
      workDate: map['workDate'] is Timestamp 
          ? (map['workDate'] as Timestamp).toDate() 
          : DateTime.now(),
      isMidnightUpdateRequired: map['isMidnightUpdateRequired'] ?? true,
      companyName: map['companyName'] ?? '',
      entries: (map['entries'] as List? ?? [])
          .map((e) => QuotationServiceEntry.fromMap(e as Map<String, dynamic>))
          .toList(),
      terms: List<String>.from(map['terms'] ?? []),
      cancellationReason: map['cancellationReason'],
      pdfUrl: map['pdfUrl'],
    );
  }

  QuotationModel copyWith({
    String? clientName,
    String? siteLocation,
    String? serviceType,
    double? totalAmount,
    double? advancePaid,
    double? commission,
    String? status,
    DateTime? updatedAt,
    DateTime? workDate,
    bool? isMidnightUpdateRequired,
    String? companyName,
    List<QuotationServiceEntry>? entries,
    List<String>? terms,
    String? cancellationReason,
    String? pdfUrl,
  }) {
    final double newTotal = totalAmount ?? this.totalAmount;
    final double newAdvance = advancePaid ?? this.advancePaid;

    return QuotationModel(
      id: id,
      operatorId: operatorId,
      clientName: clientName ?? this.clientName,
      siteLocation: siteLocation ?? this.siteLocation,
      serviceType: serviceType ?? this.serviceType,
      totalAmount: newTotal,
      advancePaid: newAdvance,
      balanceAmount: newTotal - newAdvance,
      commission: commission ?? this.commission,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workDate: workDate ?? this.workDate,
      isMidnightUpdateRequired: isMidnightUpdateRequired ?? this.isMidnightUpdateRequired,
      companyName: companyName ?? this.companyName,
      entries: entries ?? this.entries,
      terms: terms ?? this.terms,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      pdfUrl: pdfUrl ?? this.pdfUrl,
    );
  }

  double get totalPrice => entries.fold(0.0, (acc, item) => acc + item.price);

  bool get shouldShowAlert {
    int durationDays = 1;
    if (entries.isNotEmpty) {
      final durStr = entries.first.duration.toLowerCase();
      if (durStr.contains('3 day')) {
        durationDays = 3;
      } else if (durStr.contains('2 day')) {
        durationDays = 2;
      } else if (durStr.contains('1 day')) {
        durationDays = 1;
      } else {
        final match = RegExp(r'(\d+)\s*day').firstMatch(durStr);
        if (match != null) {
          durationDays = int.tryParse(match.group(1) ?? '') ?? 1;
        }
      }
    }

    int thresholdHours = 10;
    if (durationDays == 3) {
      thresholdHours = 40;
    } else if (durationDays == 2) {
      thresholdHours = 20;
    } else {
      thresholdHours = 10;
    }

    final elapsedHours = DateTime.now().difference(workDate).inHours;
    return elapsedHours >= thresholdHours;
  }
}
