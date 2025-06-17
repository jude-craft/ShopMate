import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/sales.dart';

class ShopProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Sale> _sales = [];

  List<Product> get products => _products;
  List<Sale> get sales => _sales;

  // Today's sales
  List<Sale> get todaySales {
    final today = DateTime.now();
    return _sales.where((sale) {
      return sale.date.day == today.day &&
          sale.date.month == today.month &&
          sale.date.year == today.year;
    }).toList();
  }

  // Today's revenue
  double get todayRevenue {
    return todaySales.fold(0.0, (sum, sale) => sum + sale.total);
  }

  // Low stock products (less than 5 items)
  List<Product> get lowStockProducts {
    return _products.where((product) => product.stock < 5).toList();
  }

  // Total products count
  int get totalProducts => _products.length;

  // Initialize with sample data
  void initializeSampleData() {
    _products = [
      Product(
        id: '1',
        name: 'Coca Cola 500ml',
        price: 50.0,
        stock: 24,
        category: 'Beverages',
      ),
      Product(
        id: '2',
        name: 'Bread Loaf',
        price: 80.0,
        stock: 3,
        category: 'Bakery',
      ),
      Product(
        id: '3',
        name: 'Milk 1L',
        price: 120.0,
        stock: 15,
        category: 'Dairy',
      ),
    ];

    // Sample sales for today
    final now = DateTime.now();
    _sales = [
      Sale(
        id: '1',
        productId: '1',
        productName: 'Coca Cola 500ml',
        quantity: 2,
        unitPrice: 50.0,
        total: 100.0,
        date: now.subtract(const Duration(hours: 2)),
      ),
      Sale(
        id: '2',
        productId: '3',
        productName: 'Milk 1L',
        quantity: 1,
        unitPrice: 120.0,
        total: 120.0,
        date: now.subtract(const Duration(hours: 1)),
      ),
    ];
    notifyListeners();
  }

  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }

  void addSale(Sale sale) {
    _sales.add(sale);
    notifyListeners();
  }
}
