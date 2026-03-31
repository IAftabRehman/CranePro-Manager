class CraneModel {
  final String id;
  final String craneNumber;
  final String model;
  final double capacity;
  final String status;
  final String? assignedOperatorId;

  CraneModel({
    required this.id,
    required this.craneNumber,
    required this.model,
    required this.capacity,
    this.status = 'Active',
    this.assignedOperatorId,
  });

  Map<String, dynamic> toMap() {
    return {
      'craneNumber': craneNumber,
      'model': model,
      'capacity': capacity,
      'status': status,
      'assignedOperatorId': assignedOperatorId,
    };
  }

  factory CraneModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return CraneModel(
      id: docId ?? '',
      craneNumber: map['craneNumber'] ?? '',
      model: map['model'] ?? '',
      capacity: (map['capacity'] ?? 10.0).toDouble(),
      status: map['status'] ?? 'Active',
      assignedOperatorId: map['assignedOperatorId'],
    );
  }

  CraneModel copyWith({
    String? id,
    String? craneNumber,
    String? model,
    double? capacity,
    String? status,
    String? assignedOperatorId,
  }) {
    return CraneModel(
      id: id ?? this.id,
      craneNumber: craneNumber ?? this.craneNumber,
      model: model ?? this.model,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      assignedOperatorId: assignedOperatorId ?? this.assignedOperatorId,
    );
  }
}
