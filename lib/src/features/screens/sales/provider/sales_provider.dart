import 'package:flutter/material.dart';
import '../../../backend/sales/sales_db.dart';
import '../models/sale_model.dart';


class SalesProvider extends ChangeNotifier {
  List<Sale> _sales = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Sale> get sales => _sales;

  // Initialize and load sales from database
  Future<void> initializeDatabase() async {
    await loadSalesFromDatabase();
  }

  // Load all sales from database
  Future<void> loadSalesFromDatabase() async {
    try {
      final salesData = await _dbHelper.getAllSales();
      _sales = salesData.map((map) => Sale.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading sales: $e');
    }
  }

  // Add sale to both local list and database
  Future<void> addSale(Sale sale) async {
    try {
      await _dbHelper.insertSale(sale.toMap());
      _sales.insert(0, sale);
      notifyListeners();
    } catch (e) {
      print('Error adding sale: $e');
      throw e;
    }
  }

  // Delete sale from both local list and database
  Future<void> deleteSale(String saleId) async {
    try {
      await _dbHelper.deleteSale(saleId);
      _sales.removeWhere((sale) => sale.id == saleId);
      notifyListeners();
    } catch (e) {
      print('Error deleting sale: $e');
      throw e;
    }
  }

  double get totalSalesToday {
    final today = DateTime.now();
    return _sales
        .where(
          (sale) =>
      sale.dateTime.day == today.day &&
          sale.dateTime.month == today.month &&
          sale.dateTime.year == today.year,
    )
        .fold(0.0, (sum, sale) => sum + sale.price);
  }

  double get mpesaSalesToday {
    final today = DateTime.now();
    return _sales
        .where(
          (sale) =>
      sale.dateTime.day == today.day &&
          sale.dateTime.month == today.month &&
          sale.dateTime.year == today.year &&
          sale.paymentMethod == PaymentMethod.mpesa,
    )
        .fold(0.0, (sum, sale) => sum + sale.price);
  }

  double get cashSalesToday {
    final today = DateTime.now();
    return _sales
        .where(
          (sale) =>
      sale.dateTime.day == today.day &&
          sale.dateTime.month == today.month &&
          sale.dateTime.year == today.year &&
          sale.paymentMethod == PaymentMethod.cash,
    )
        .fold(0.0, (sum, sale) => sum + sale.price);
  }

  List<Sale> get todaySales {
    final today = DateTime.now();
    return _sales
        .where(
          (sale) =>
      sale.dateTime.day == today.day &&
          sale.dateTime.month == today.month &&
          sale.dateTime.year == today.year,
    )
        .toList();
  }

  Map<String, double> get productTotals {
    Map<String, double> totals = {};
    for (var sale in _sales) {
      totals[sale.productName] = (totals[sale.productName] ?? 0) + sale.price;
    }
    return totals;
  }
}

