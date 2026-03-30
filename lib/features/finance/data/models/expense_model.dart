import 'package:cloud_firestore/cloud_firestore.dart';

enum ExpenseCategory { fuel, maintenance, fine, other }

class ExpenseModel {
  final String expenseId;
  final String operatorId;
  final ExpenseCategory category;
  final double amount;
  final String description;
  final String? craneId;
  final DateTime date;
  final String? attachmentUrl;

  ExpenseModel({
    required this.expenseId,
    required this.operatorId,
    required this.category,
    required this.amount,
    required this.description,
    this.craneId,
    required this.date,
    this.attachmentUrl,
  }) : assert(amount >= 0, 'Amount must be non-negative');

  ExpenseModel copyWith({
    String? operatorId,
    ExpenseCategory? category,
    double? amount,
    String? description,
    String? craneId,
    DateTime? date,
    String? attachmentUrl,
  }) {
    return ExpenseModel(
      expenseId: expenseId,
      operatorId: operatorId ?? this.operatorId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      craneId: craneId ?? this.craneId,
      date: date ?? this.date,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'expenseId': expenseId,
      'operatorId': operatorId,
      'category': category.name,
      'amount': amount,
      'description': description,
      'craneId': craneId,
      'date': Timestamp.fromDate(date),
      'attachmentUrl': attachmentUrl,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return ExpenseModel(
      expenseId: docId ?? map['expenseId'] ?? '',
      operatorId: map['operatorId'] ?? '',
      category: ExpenseCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => ExpenseCategory.other,
      ),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
      craneId: map['craneId'],
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      attachmentUrl: map['attachmentUrl'],
    );
  }
}
