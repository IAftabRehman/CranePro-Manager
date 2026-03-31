import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String id;
  final String operatorId;
  final String category; // 'Fuel', 'Maintenance', 'Salary', 'Other'
  final double amount;
  final String description;
  final DateTime date;
  final String? attachmentUrl;

  ExpenseModel({
    required this.id,
    required this.operatorId,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
    this.attachmentUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'operatorId': operatorId,
      'category': category,
      'amount': amount,
      'description': description,
      'date': Timestamp.fromDate(date),
      'attachmentUrl': attachmentUrl,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return ExpenseModel(
      id: docId ?? map['id'] ?? '',
      operatorId: map['operatorId'] ?? '',
      category: map['category'] ?? 'Other',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
      date: map['date'] is Timestamp 
          ? (map['date'] as Timestamp).toDate() 
          : DateTime.now(),
      attachmentUrl: map['attachmentUrl'],
    );
  }

  ExpenseModel copyWith({
    String? category,
    double? amount,
    String? description,
    DateTime? date,
    String? attachmentUrl,
  }) {
    return ExpenseModel(
      id: id,
      operatorId: operatorId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
    );
  }
}
