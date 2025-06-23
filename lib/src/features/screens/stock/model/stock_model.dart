class Stock {
  final int? id;
  final String productName;
  final String category;
  final double buyingPrice;
  final double sellingPrice;
  final int quantity;
  final int minStockLevel;
  final String unit;
  final DateTime dateAdded;
  final DateTime? expiryDate;
  final String? description;
  final String? supplier;
  int soldQuantity;

  Stock({
    this.id,
    required this.productName,
    required this.category,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.quantity,
    this.minStockLevel = 5,
    this.unit = 'pieces',
    required this.dateAdded,
    this.expiryDate,
    this.description,
    this.supplier,
    this.soldQuantity = 0,
  });

  // Calculate remaining stock
  int get remainingStock => quantity - soldQuantity;

  // Check if stock is low
  bool get isLowStock => remainingStock <= minStockLevel && remainingStock > 0;

  // Check if out of stock
  bool get isOutOfStock => remainingStock <= 0;

  // Calculate profit per unit
  double get profitPerUnit => sellingPrice - buyingPrice;

  // Calculate total profit from sold items
  double get totalProfit => soldQuantity * profitPerUnit;

  // Calculate total investment
  double get totalInvestment => quantity * buyingPrice;

  // Calculate current stock value
  double get currentStockValue => remainingStock * buyingPrice;

  // Check if product is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  // Check if product is expiring soon (within 7 days)
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final daysUntilExpiry = expiryDate!.difference(now).inDays;
    return daysUntilExpiry <= 7 && daysUntilExpiry > 0;
  }

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'category': category,
      'buyingPrice': buyingPrice,
      'sellingPrice': sellingPrice,
      'quantity': quantity,
      'minStockLevel': minStockLevel,
      'unit': unit,
      'dateAdded': dateAdded.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'description': description,
      'supplier': supplier,
      'soldQuantity': soldQuantity,
    };
  }

  // Create Stock from Map (database)
  factory Stock.fromMap(Map<String, dynamic> map) {
    return Stock(
      id: map['id'],
      productName: map['productName'] ?? '',
      category: map['category'] ?? '',
      buyingPrice: (map['buyingPrice'] ?? 0).toDouble(),
      sellingPrice: (map['sellingPrice'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
      minStockLevel: map['minStockLevel'] ?? 5,
      unit: map['unit'] ?? 'pieces',
      dateAdded: DateTime.parse(map['dateAdded']),
      expiryDate: map['expiryDate'] != null ? DateTime.parse(map['expiryDate']) : null,
      description: map['description'],
      supplier: map['supplier'],
      soldQuantity: map['soldQuantity'] ?? 0,
    );
  }

  // Create a copy with updated values
  Stock copyWith({
    int? id,
    String? productName,
    String? category,
    double? buyingPrice,
    double? sellingPrice,
    int? quantity,
    int? minStockLevel,
    String? unit,
    DateTime? dateAdded,
    DateTime? expiryDate,
    String? description,
    String? supplier,
    int? soldQuantity,
  }) {
    return Stock(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      category: category ?? this.category,
      buyingPrice: buyingPrice ?? this.buyingPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      quantity: quantity ?? this.quantity,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      unit: unit ?? this.unit,
      dateAdded: dateAdded ?? this.dateAdded,
      expiryDate: expiryDate ?? this.expiryDate,
      description: description ?? this.description,
      supplier: supplier ?? this.supplier,
      soldQuantity: soldQuantity ?? this.soldQuantity,
    );
  }

  @override
  String toString() {
    return 'Stock{id: $id, productName: $productName, remainingStock: $remainingStock, totalProfit: $totalProfit}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Stock && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}