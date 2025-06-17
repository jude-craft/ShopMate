class Sale {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double total;
  final DateTime date;

  Sale({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    required this.date,
  });

  Sale copyWith({
    String? id,
    String? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    double? total,
    DateTime? date,
  }) {
    return Sale(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      total: total ?? this.total,
      date: date ?? this.date,
    );
  }
}