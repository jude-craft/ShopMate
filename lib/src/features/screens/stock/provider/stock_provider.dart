import 'package:flutter/foundation.dart';
import '../../../backend/stocks/stocks_db.dart';
import '../model/stock_model.dart';

class StockProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

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
    _setLoading(true);
    try {
      _stocks = await _databaseService.getAllStocks();
      _error = '';
    } catch (e) {
      _error = 'Failed to load stocks: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  // Add new stock
  Future<bool> addStock(Stock stock) async {
    try {
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
    }
  }

  // Update existing stock
  Future<bool> updateStock(Stock stock) async {
    try {
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
    }
  }

  // Delete stock
  Future<bool> deleteStock(int id) async {
    try {
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
  }

  // Update sold quantity (called from sales)
  Future<bool> updateSoldQuantity(int stockId, int quantitySold) async {
    try {
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
  }

  // Clear all stock data
  Future<bool> clearAllStock() async {
    try {
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

  // Search stocks from database
  Future<List<Stock>> searchStocks(String query) async {
    try {
      return await _databaseService.searchStocks(query);
    } catch (e) {
      _error = 'Failed to search stocks: $e';
      debugPrint(_error);
      return [];
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

  // Get all categories from database
  Future<List<String>> getAllCategoriesFromDB() async {
    try {
      return await _databaseService.getAllCategories();
    } catch (e) {
      _error = 'Failed to get categories: $e';
      debugPrint(_error);
      return [];
    }
  }

  // Get all categories from current loaded stocks
  List<String> getAllCategories() {
    final categories = _stocks.map((stock) => stock.category).toSet().toList();
    categories.sort();
    return categories;
  }

  // Get all suppliers from database
  Future<List<String>> getAllSuppliersFromDB() async {
    try {
      return await _databaseService.getAllSuppliers();
    } catch (e) {
      _error = 'Failed to get suppliers: $e';
      debugPrint(_error);
      return [];
    }
  }

  // Get low stock alerts from database
  Future<List<Stock>> getLowStockAlertsFromDB() async {
    try {
      return await _databaseService.getLowStockItems();
    } catch (e) {
      _error = 'Failed to get low stock alerts: $e';
      debugPrint(_error);
      return [];
    }
  }

  // Get low stock alerts from current stocks
  List<Stock> getLowStockAlerts() {
    return _stocks.where((stock) => stock.isLowStock || stock.isOutOfStock).toList();
  }

  // Get out of stock alerts from database
  Future<List<Stock>> getOutOfStockAlertsFromDB() async {
    try {
      return await _databaseService.getOutOfStockItems();
    } catch (e) {
      _error = 'Failed to get out of stock alerts: $e';
      debugPrint(_error);
      return [];
    }
  }

  // Get expiry alerts from database
  Future<List<Stock>> getExpiryAlertsFromDB() async {
    try {
      final expired = await _databaseService.getExpiredItems();
      final expiringSoon = await _databaseService.getExpiringSoonItems();
      return [...expired, ...expiringSoon];
    } catch (e) {
      _error = 'Failed to get expiry alerts: $e';
      debugPrint(_error);
      return [];
    }
  }

  // Get expiry alerts from current stocks
  List<Stock> getExpiryAlerts() {
    return _stocks.where((stock) => stock.isExpired || stock.isExpiringSoon).toList();
  }

  // Get expired items from database
  Future<List<Stock>> getExpiredItemsFromDB() async {
    try {
      return await _databaseService.getExpiredItems();
    } catch (e) {
      _error = 'Failed to get expired items: $e';
      debugPrint(_error);
      return [];
    }
  }

  // Get expiring soon items from database
  Future<List<Stock>> getExpiringSoonItemsFromDB() async {
    try {
      return await _databaseService.getExpiringSoonItems();
    } catch (e) {
      _error = 'Failed to get expiring soon items: $e';
      debugPrint(_error);
      return [];
    }
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

  // Get stock statistics from database
  Future<Map<String, dynamic>> getStockStatisticsFromDB() async {
    try {
      return await _databaseService.getStockStatistics();
    } catch (e) {
      _error = 'Failed to get stock statistics: $e';
      debugPrint(_error);
      return getStockStatistics(); // Fallback to local calculation
    }
  }

  // Get stock statistics from current loaded stocks
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

  // Backup stocks data
  Future<List<Map<String, dynamic>>> backupStocks() async {
    try {
      return await _databaseService.backupStocks();
    } catch (e) {
      _error = 'Failed to backup stocks: $e';
      debugPrint(_error);
      return [];
    }
  }

  // Restore stocks from backup
  Future<bool> restoreStocks(List<Map<String, dynamic>> stocksData) async {
    try {
      final success = await _databaseService.restoreStocks(stocksData);
      if (success) {
        await loadStocks(); // Reload stocks after restore
      }
      return success;
    } catch (e) {
      _error = 'Failed to restore stocks: $e';
      debugPrint(_error);
      return false;
    }
  }

  // Initialize database and load initial data
  Future<void> initializeDatabase() async {
    try {
      // Initialize database connection
      await _databaseService.database;

      // Load initial stock data
      await loadStocks();

      debugPrint('Stock database initialized successfully');
    } catch (e) {
      _error = 'Failed to initialize database: $e';
      debugPrint(_error);
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Refresh stocks from database
  Future<void> refreshStocks() async {
    await loadStocks();
  }

  @override
  void dispose() {
    _databaseService.close();
    super.dispose();
  }
}