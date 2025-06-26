import 'package:flutter/material.dart';
import '../models/product.dart';
import '../screens/sales/models/sale_model.dart';

class ShopProvider with ChangeNotifier {
  List<Product> _products = [];





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


    notifyListeners();
  }

  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }

  void addSale(Sale sale) {
    notifyListeners();
  }
}
