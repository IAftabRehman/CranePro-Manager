enum CommissionStatus { unpaid, paid }

class CommissionModel {
  final String partnerId;
  final String quotationId;
  final double commissionAmount;
  final CommissionStatus status;

  CommissionModel({
    required this.partnerId,
    required this.quotationId,
    required this.commissionAmount,
    this.status = CommissionStatus.unpaid,
  }) : assert(commissionAmount >= 0, 'Commission amount must be non-negative');

  Map<String, dynamic> toMap() {
    return {
      'partnerId': partnerId,
      'quotationId': quotationId,
      'commissionAmount': commissionAmount,
      'status': status.name,
    };
  }

  factory CommissionModel.fromMap(Map<String, dynamic> map) {
    return CommissionModel(
      partnerId: map['partnerId'] ?? '',
      quotationId: map['quotationId'] ?? '',
      commissionAmount: (map['commissionAmount'] as num?)?.toDouble() ?? 0.0,
      status: CommissionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => CommissionStatus.unpaid,
      ),
    );
  }
}
