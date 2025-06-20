class Product {
  final int? id;
  final String name;
  final String? barcode;
  final double costPrice;
  final double sellingPrice;
  final int stockQuantity;
  final int minStockLevel;
  final String? category;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    this.id,
    required this.name,
    this.barcode,
    required this.costPrice,
    required this.sellingPrice,
    required this.stockQuantity,
    this.minStockLevel = 5,
    this.category,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  double get profit => sellingPrice - costPrice;
  double get profitMargin => ((sellingPrice - costPrice) / costPrice) * 100;
  bool get isLowStock => stockQuantity <= minStockLevel;

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      barcode: map['barcode'],
      costPrice: map['cost_price'].toDouble(),
      sellingPrice: map['selling_price'].toDouble(),
      stockQuantity: map['stock_quantity'],
      minStockLevel: map['min_stock_level'] ?? 5,
      category: map['category'],
      description: map['description'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'stock_quantity': stockQuantity,
      'min_stock_level': minStockLevel,
      'category': category,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Product copyWith({
    int? id,
    String? name,
    String? barcode,
    double? costPrice,
    double? sellingPrice,
    int? stockQuantity,
    int? minStockLevel,
    String? category,
    String? description,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      category: category ?? this.category,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Sale Item Model
class SaleItem {
  final int? id;
  final int? saleId;
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double unitCost;
  final double subtotal;
  final double profit;

  SaleItem({
    this.id,
    this.saleId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.unitCost,
    required this.subtotal,
    required this.profit,
  });

  factory SaleItem.fromProduct(Product product, int quantity) {
    final subtotal = product.sellingPrice * quantity;
    final profit = (product.sellingPrice - product.costPrice) * quantity;

    return SaleItem(
      productId: product.id!,
      productName: product.name,
      quantity: quantity,
      unitPrice: product.sellingPrice,
      unitCost: product.costPrice,
      subtotal: subtotal,
      profit: profit,
    );
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      id: map['id'],
      saleId: map['sale_id'],
      productId: map['product_id'],
      productName: map['product_name'] ?? '',
      quantity: map['quantity'],
      unitPrice: map['unit_price'].toDouble(),
      unitCost: map['unit_cost'].toDouble(),
      subtotal: map['subtotal'].toDouble(),
      profit: map['profit'].toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'unit_cost': unitCost,
      'subtotal': subtotal,
      'profit': profit,
    };
  }

  SaleItem copyWith({
    int? quantity,
  }) {
    final newSubtotal = unitPrice * (quantity ?? this.quantity);
    final newProfit = (unitPrice - unitCost) * (quantity ?? this.quantity);

    return SaleItem(
      id: id,
      saleId: saleId,
      productId: productId,
      productName: productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice,
      unitCost: unitCost,
      subtotal: newSubtotal,
      profit: newProfit,
    );
  }
}

// Sale Model
class Sale {
  final int? id;
  final double totalAmount;
  final double totalProfit;
  final String paymentMethod;
  final String? customerName;
  final String? customerPhone;
  final String? notes;
  final DateTime createdAt;
  final List<SaleItem> items;

  Sale({
    this.id,
    required this.totalAmount,
    required this.totalProfit,
    required this.paymentMethod,
    this.customerName,
    this.customerPhone,
    this.notes,
    required this.createdAt,
    this.items = const [],
  });

  factory Sale.fromItems({
    List<SaleItem> items = const [],
    required String paymentMethod,
    String? customerName,
    String? customerPhone,
    String? notes,
  }) {
    final totalAmount = items.fold(0.0, (sum, item) => sum + item.subtotal);
    final totalProfit = items.fold(0.0, (sum, item) => sum + item.profit);

    return Sale(
      totalAmount: totalAmount,
      totalProfit: totalProfit,
      paymentMethod: paymentMethod,
      customerName: customerName,
      customerPhone: customerPhone,
      notes: notes,
      createdAt: DateTime.now(),
      items: items,
    );
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      totalAmount: map['total_amount'].toDouble(),
      totalProfit: map['total_profit'].toDouble(),
      paymentMethod: map['payment_method'],
      customerName: map['customer_name'],
      customerPhone: map['customer_phone'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total_amount': totalAmount,
      'total_profit': totalProfit,
      'payment_method': paymentMethod,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// Enums
enum PaymentMethod {
  cash('Cash'),
  card('Card'),
  mobile('Mobile Money'),
  credit('Credit');

  const PaymentMethod(this.label);
  final String label;
}