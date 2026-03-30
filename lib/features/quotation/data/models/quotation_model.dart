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
    this.serviceName = '50 Ton Crane',
    this.duration = '1 Day',
    this.location = '',
    this.price = 0.0,
    DateTime? startDate,
  }) : startDate = startDate ?? DateTime.now();

  String get formattedDate => DateFormat('MMM dd, yyyy').format(startDate);
}

class QuotationModel {
  final String quotationId;
  final String operatorId;
  final String clientName;
  final String siteLocation;
  final String serviceType;
  final double totalAmount;
  final double advancePaid;
  final double balanceAmount;
  final QuotationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime workDate;
  final String? pdfUrl;
  final bool isMidnightUpdateRequired;

  // Keep these for UI compatibility if needed
  final String companyName;
  final List<QuotationServiceEntry> entries;
  final List<String> terms;
  final String? cancellationReason;

  QuotationModel({
    required this.quotationId,
    required this.operatorId,
    required this.clientName,
    required this.siteLocation,
    required this.serviceType,
    required this.totalAmount,
    this.advancePaid = 0.0,
    required this.balanceAmount,
    this.status = QuotationStatus.pending,
    required this.createdAt,
    required this.updatedAt,
    required this.workDate,
    this.pdfUrl,
    this.isMidnightUpdateRequired = true,
    this.companyName = '',
    this.entries = const [],
    this.terms = const [],
    this.cancellationReason,
  });

  QuotationModel copyWith({
    String? clientName,
    String? siteLocation,
    String? serviceType,
    double? totalAmount,
    double? advancePaid,
    double? balanceAmount,
    QuotationStatus? status,
    DateTime? updatedAt,
    DateTime? workDate,
    String? pdfUrl,
    bool? isMidnightUpdateRequired,
    String? cancellationReason,
  }) {
    return QuotationModel(
      quotationId: quotationId,
      operatorId: operatorId,
      clientName: clientName ?? this.clientName,
      siteLocation: siteLocation ?? this.siteLocation,
      serviceType: serviceType ?? this.serviceType,
      totalAmount: totalAmount ?? this.totalAmount,
      advancePaid: advancePaid ?? this.advancePaid,
      balanceAmount: balanceAmount ?? this.balanceAmount,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workDate: workDate ?? this.workDate,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      isMidnightUpdateRequired: isMidnightUpdateRequired ?? this.isMidnightUpdateRequired,
      companyName: companyName,
      entries: entries,
      terms: terms,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quotationId': quotationId,
      'operatorId': operatorId,
      'clientName': clientName,
      'siteLocation': siteLocation,
      'serviceType': serviceType,
      'totalAmount': totalAmount,
      'advancePaid': advancePaid,
      'balanceAmount': balanceAmount,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'workDate': Timestamp.fromDate(workDate),
      'pdfUrl': pdfUrl,
      'isMidnightUpdateRequired': isMidnightUpdateRequired,
      'companyName': companyName,
      'cancellationReason': cancellationReason,
    };
  }

  factory QuotationModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return QuotationModel(
      quotationId: docId ?? map['quotationId'] ?? '',
      operatorId: map['operatorId'] ?? '',
      clientName: map['clientName'] ?? '',
      siteLocation: map['siteLocation'] ?? '',
      serviceType: map['serviceType'] ?? '',
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      advancePaid: (map['advancePaid'] as num?)?.toDouble() ?? 0.0,
      balanceAmount: (map['balanceAmount'] as num?)?.toDouble() ?? 0.0,
      status: QuotationStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => QuotationStatus.pending,
      ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      workDate: (map['workDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      pdfUrl: map['pdfUrl'],
      isMidnightUpdateRequired: map['isMidnightUpdateRequired'] ?? true,
      companyName: map['companyName'] ?? '',
      cancellationReason: map['cancellationReason'],
    );
  }

  double get totalPrice => entries.fold(0.0, (sum, item) => sum + item.price);
}
