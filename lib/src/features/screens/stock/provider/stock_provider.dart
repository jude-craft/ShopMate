import 'package:flutter/foundation.dart';
import '../model/stock_model.dart';

class StockProvider extends ChangeNotifier {
  //final DatabaseService _databaseService = DatabaseService();

  List<Stock> _stocks = [];
  bool _isLoading = false;
  String _error = '';

  // Getters
  List<Stock> get stocks => _stocks;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Get low stock count
  int get lowStockCount => _stocks.where((stock) => stock.isLowStock).length;

  // Get out of stock count
  int get outOfStockCount => _stocks.where((stock) => stock.isOutOfStock).length;

  // Get expired products count
  int get expiredCount => _stocks.where((stock) => stock.isExpired).length;

  // Get expiring soon count
  int get expiringSoonCount => _stocks.where((stock) => stock.isExpiringSoon).length;

  // Load all stocks from database
  Future<void> loadStocks() async {
   // _setLoading(true);
   /* try {
      _stocks = await _databaseService.getAllStocks();
      _error = '';
    } catch (e) {
      _error = 'Failed to load stocks: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    } */
  }

  // Add new stock
  Future<bool> addStock(Stock stock) async {
    /* try {
       final id = await _databaseService.insertStock(stock);
      if (id > 0) {
        final newStock = stock.copyWith(id: id);
        _stocks.add(newStock);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to add stock: $e';
      debugPrint(_error);
      return false;
    } */
    return false;
  }

  // Update existing stock
  Future<bool> updateStock(Stock stock) async {
    /*try {
      final success = await _databaseService.updateStock(stock);
      if (success) {
        final index = _stocks.indexWhere((s) => s.id == stock.id);
        if (index != -1) {
          _stocks[index] = stock;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to update stock: $e';
      debugPrint(_error);
      return false;
    } */
    return false;
  }

  // Delete stock
  Future<bool> deleteStock(int id) async {
    /*try {
      final success = await _databaseService.deleteStock(id);
      if (success) {
        _stocks.removeWhere((stock) => stock.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to delete stock: $e';
      debugPrint(_error);
      return false;
    }
     */
    return true;
  }

  // Update sold quantity (called from sales)
  Future<bool> updateSoldQuantity(int stockId, int quantitySold) async {
    /*try {
      final stockIndex = _stocks.indexWhere((stock) => stock.id == stockId);
      if (stockIndex == -1) return false;

      final stock = _stocks[stockIndex];
      final updatedStock = stock.copyWith(
        soldQuantity: stock.soldQuantity + quantitySold,
      );

      final success = await _databaseService.updateStock(updatedStock);
      if (success) {
        _stocks[stockIndex] = updatedStock;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to update sold quantity: $e';
      debugPrint(_error);
      return false;
    }
     */
    return false;
  }

  // Clear all stock data
  Future<bool> clearAllStock() async {
    /*try {
      final success = await _databaseService.clearAllStocks();
      if (success) {
        _stocks.clear();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to clear stocks: $e';
      debugPrint(_error);
      return false;
    }
     */
    return true;
  }

  // Get stock by ID
  Stock? getStockById(int id) {
    try {
      return _stocks.firstWhere((stock) => stock.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get stock by product name
  Stock? getStockByName(String productName) {
    try {
      return _stocks.firstWhere(
            (stock) => stock.productName.toLowerCase() == productName.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Get filtered stocks based on search and filters
  List<Stock> getFilteredStocks({
    String searchQuery = '',
    String sortBy = 'name',
    bool showLowStock = false,
  }) {
    List<Stock> filtered = _stocks;

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((stock) {
        return stock.productName.toLowerCase().contains(searchQuery.toLowerCase()) ||
            stock.category.toLowerCase().contains(searchQuery.toLowerCase()) ||
            stock.supplier?.toLowerCase().contains(searchQuery.toLowerCase()) == true;
      }).toList();
    }

    // Apply low stock filter
    if (showLowStock) {
      filtered = filtered.where((stock) => stock.isLowStock || stock.isOutOfStock).toList();
    }

    // Apply sorting
    switch (sortBy) {
      case 'name':
        filtered.sort((a, b) => a.productName.compareTo(b.productName));
        break;
      case 'quantity':
        filtered.sort((a, b) => a.remainingStock.compareTo(b.remainingStock));
        break;
      case 'date':
        filtered.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        break;
    }

    return filtered;
  }

  // Get stocks by category
  List<Stock> getStocksByCategory(String category) {
    return _stocks.where((stock) => stock.category == category).toList();
  }

  // Get all categories
  List<String> getAllCategories() {
    final categories = _stocks.map((stock) => stock.category).toSet().toList();
    categories.sort();
    return categories;
  }

  // Get low stock alerts
  List<Stock> getLowStockAlerts() {
    return _stocks.where((stock) => stock.isLowStock || stock.isOutOfStock).toList();
  }

  // Get expiry alerts
  List<Stock> getExpiryAlerts() {
    return _stocks.where((stock) => stock.isExpired || stock.isExpiringSoon).toList();
  }

  // Calculate total investment
  double getTotalInvestment() {
    return _stocks.fold(0.0, (sum, stock) => sum + stock.totalInvestment);
  }

  // Calculate total current value
  double getTotalCurrentValue() {
    return _stocks.fold(0.0, (sum, stock) => sum + stock.currentStockValue);
  }

  // Calculate total profit
  double getTotalProfit() {
    return _stocks.fold(0.0, (sum, stock) => sum + stock.totalProfit);
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Get stock statistics for reports
  Map<String, dynamic> getStockStatistics() {
    return {
      'totalProducts': _stocks.length,
      'lowStockItems': lowStockCount,
      'outOfStockItems': outOfStockCount,
      'expiredItems': expiredCount,
      'expiringSoonItems': expiringSoonCount,
      'totalInvestment': getTotalInvestment(),
      'currentStockValue': getTotalCurrentValue(),
      'totalProfit': getTotalProfit(),
      'categories': getAllCategories().length,
    };
  }
}