import 'package:cloud_firestore/cloud_firestore.dart';

class WorkOrderModel {
  final String id;
  final String workOrderId;
  final String operatorId;
  final String operatorName;
  final String clientName;
  final String siteLocation;
  final String status;
  final DateTime createdAt;

  WorkOrderModel({
    required this.id,
    required this.workOrderId,
    required this.operatorId,
    required this.operatorName,
    required this.clientName,
    required this.siteLocation,
    this.status = 'pending_approval',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workOrderId': workOrderId,
      'operatorId': operatorId,
      'operatorName': operatorName,
      'clientName': clientName,
      'siteLocation': siteLocation,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory WorkOrderModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return WorkOrderModel(
      id: docId ?? map['id'] ?? '',
      workOrderId: map['workOrderId'] ?? '',
      operatorId: map['operatorId'] ?? '',
      operatorName: map['operatorName'] ?? '',
      clientName: map['clientName'] ?? '',
      siteLocation: map['siteLocation'] ?? '',
      status: map['status'] ?? 'pending_approval',
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }
}
