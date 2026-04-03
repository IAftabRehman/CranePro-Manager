class PendingItem {
  final String id;
  final String clientName;
  final String location;
  final double totalPrice;
  final String type; // 'quotation' or 'work_order'
  final DateTime createdAt;

  PendingItem({
    required this.id,
    required this.clientName,
    required this.location,
    required this.totalPrice,
    required this.type,
    required this.createdAt,
  });
}
