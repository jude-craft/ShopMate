import 'package:flutter/material.dart';
import '../../../backend/reports/reports_db.dart';
import '../model/report_model.dart';

class ReportProvider extends ChangeNotifier {
  final ReportsDatabaseHelper _reportsDb = ReportsDatabaseHelper();
  bool _isLoading = false;
  String _currentPeriod = 'Today';

  // Data properties
  double _totalSales = 0.0;
  double _totalProfit = 0.0;
  int _totalTransactions = 0;
  int _totalItemsSold = 0;
  double _salesTrend = 0.0;
  double _profitTrend = 0.0;

  List<ChartData> _salesChartData = [];
  List<ChartData> _topProductsData = [];
  List<TransactionModel> _recentTransactions = [];
  List<ProductPerformance> _topProducts = [];

  // Getters
  bool get isLoading => _isLoading;
  double get totalSales => _totalSales;
  double get totalProfit => _totalProfit;
  int get totalTransactions => _totalTransactions;
  int get totalItemsSold => _totalItemsSold;
  double get salesTrend => _salesTrend;
  double get profitTrend => _profitTrend;
  List<ChartData> get salesChartData => _salesChartData;
  List<ChartData> get topProductsData => _topProductsData;
  List<TransactionModel> get recentTransactions => _recentTransactions;
  List<ProductPerformance> get topProducts => _topProducts;

  // Load all reports data
  Future<void> loadReports() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadSummaryData();
      await _loadChartData();
      await _loadTransactions();
      await _loadTopProducts();
    } catch (e) {
      print('Error loading reports: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter reports by period
  Future<void> filterByPeriod(String period) async {
    _currentPeriod = period;
    await loadReports();
  }

  // Load summary data based on current period
  Future<void> _loadSummaryData() async {
    try {
      final reportSummary = await _reportsDb.getReportSummary(_currentPeriod);
      
      _totalSales = reportSummary.totalSales;
      _totalProfit = reportSummary.totalProfit;
      _totalTransactions = reportSummary.totalTransactions;
      _totalItemsSold = reportSummary.totalItemsSold;
      _salesTrend = reportSummary.salesTrend;
      _profitTrend = reportSummary.profitTrend;

    } catch (e) {
      print('Error loading summary data: $e');
    }
  }

  // Load chart data
  Future<void> _loadChartData() async {
    try {
      _salesChartData = await _reportsDb.getSalesChartData(_currentPeriod);
      _topProductsData = await _generateTopProductsChartData();
    } catch (e) {
      print('Error loading chart data: $e');
    }
  }

  // Load recent transactions
  Future<void> _loadTransactions() async {
    try {
      _recentTransactions = await _reportsDb.getRecentTransactions(limit: 10);
    } catch (e) {
      print('Error loading transactions: $e');
    }
  }

  // Load top products
  Future<void> _loadTopProducts() async {
    try {
      _topProducts = await _reportsDb.getTopProducts(_currentPeriod, limit: 10);
    } catch (e) {
      print('Error loading top products: $e');
    }
  }

  // Generate top products chart data
  Future<List<ChartData>> _generateTopProductsChartData() async {
    try {
      final topProductsData = _topProducts.take(5).map((product) {
        String label = product.name.length > 8
            ? '${product.name.substring(0, 8)}...'
            : product.name;
        return ChartData(label: label, value: product.revenue);
      }).toList();

      return topProductsData;
    } catch (e) {
      print('Error generating top products chart data: $e');
      return [];
    }
  }
}