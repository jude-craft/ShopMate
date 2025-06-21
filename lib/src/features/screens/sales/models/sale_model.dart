class Sale {
  final String id;
  final String productName;
  final double price;
  final double quantity;
  final DateTime dateTime;
  final PaymentMethod paymentMethod;

  Sale({
    required this.id,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.dateTime,
    required this.paymentMethod,
  });

  // Convert Sale to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'dateTime': dateTime.toIso8601String(),
      'paymentMethod': paymentMethod.toString().split('.').last,
    };
  }

  // Create Sale from Map (database)
  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      productName: map['productName'],
      price: map['price'],
      quantity: map['quantity'],
      dateTime: DateTime.parse(map['dateTime']),
      paymentMethod: map['paymentMethod'] == 'mpesa'
          ? PaymentMethod.mpesa
          : PaymentMethod.cash,
    );
  }
}

enum PaymentMethod { mpesa, cash }
