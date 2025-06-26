import 'package:flutter/foundation.dart';

import '../model/report_model.dart';


class ReportProvider with ChangeNotifier {
  bool _isLoading = false;
  String _currentPeriod = 'Today';

  // Report data
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
  String get currentPeriod => _currentPeriod;
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

  // Load all report data
  Future<void> loadReports() async {
    _setLoading(true);

    try {
      await Future.wait([
        _loadReportSummary(),
        _loadSalesChartData(),
        _loadRecentTransactions(),
        _loadTopProducts(),
        _loadTopProductsChartData(),
      ]);
    } catch (e) {
      debugPrint('Error loading reports: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Filter reports by period
  Future<void> filterByPeriod(String period) async {
    if (_currentPeriod == period) return;

    _currentPeriod = period;
    await loadReports();
  }

  // Load report summary
  Future<void> _loadReportSummary() async {
    /*try {
      final summary = await ReportDatabaseHelper.getReportSummary(_currentPeriod);
      _totalSales = summary.totalSales;
      _totalProfit = summary.totalProfit;
      _totalTransactions = summary.totalTransactions;
      _totalItemsSold = summary.totalItemsSold;
      _salesTrend = summary.salesTrend;
      _profitTrend = summary.profitTrend;
    } catch (e) {
      debugPrint('Error loading report summary: $e');
      _resetSummaryData();
    }

     */
  }

  // Load sales chart data
  Future<void> _loadSalesChartData() async {
    /* try {
      _salesChartData = await ReportDatabaseHelper.getSalesChartData(_currentPeriod);
    } catch (e) {
      debugPrint('Error loading sales chart data: $e');
      _salesChartData = [];
    }

     */
  }

  // Load recent transactions
  Future<void> _loadRecentTransactions() async {
   /* try {
      _recentTransactions = await ReportDatabaseHelper.getRecentTransactions(limit: 10);
    } catch (e) {
      debugPrint('Error loading recent transactions: $e');
      _recentTransactions = [];
    }

    */
  }

  // Load top products
  Future<void> _loadTopProducts() async {
    /*try {
      _topProducts = await ReportDatabaseHelper.getTopProducts(_currentPeriod, limit: 10);
    } catch (e) {
      debugPrint('Error loading top products: $e');
      _topProducts = [];
    }

     */
  }

  // Load top products chart data
  Future<void> _loadTopProductsChartData() async {
    /*try {
      _topProductsData = await ReportDatabaseHelper.getTopProductsChartData(_currentPeriod, limit: 5);
    } catch (e) {
      debugPrint('Error loading top products chart data: $e');
      _topProductsData = [];
    }

     */
  }

  // Get profit margin analysis
  Future<List<Map<String, dynamic>>> getProfitMarginAnalysis() async {
    /*try {
      return await ReportDatabaseHelper.getProfitMarginAnalysis(_currentPeriod);
    } catch (e) {
      debugPrint('Error loading profit margin analysis: $e');
      return [];
    }

     */
    return [];
  }

  // Get low stock alerts
  Future<List<Map<String, dynamic>>> getLowStockAlerts({int threshold = 10}) async {
    /*try {
      return await ReportDatabaseHelper.getLowStockProducts(threshold: threshold);
    } catch (e) {
      debugPrint('Error loading low stock alerts: $e');
      return [];
    }

     */
    return [];
  }

  // Get sales data for export
  Future<List<Map<String, dynamic>>> getSalesDataForExport(
      DateTime startDate,
      DateTime endDate
      ) async {
    try {
      //return await ReportDatabaseHelper.getSalesInDateRange(startDate, endDate);
    } catch (e) {
      debugPrint('Error loading sales data for export: $e');
      return [];
    }
    return [];
  }

  Future<void> refresh() async {
    await loadReports();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _resetSummaryData() {
    _totalSales = 0.0;
    _totalProfit = 0.0;
    _totalTransactions = 0;
    _totalItemsSold = 0;
    _salesTrend = 0.0;
    _profitTrend = 0.0;
  }

  // Get formatted currency
  String getFormattedCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  // Get formatted percentage
  String getFormattedPercentage(double percentage) {
    final sign = percentage >= 0 ? '+' : '';
    return '$sign${percentage.toStringAsFixed(1)}%';
  }

  // Check if data is available
  bool get hasData => _totalSales > 0 || _totalTransactions > 0;

  // Get period display name
  String get periodDisplayName {
    switch (_currentPeriod) {
      case 'Today':
        return 'Today';
      case 'Week':
        return 'This Week';
      case 'Month':
        return 'This Month';
      case 'Year':
        return 'This Year';
      default:
        return _currentPeriod;
    }
  }

  // Get comparison period name
  String get comparisonPeriodName {
    switch (_currentPeriod) {
      case 'Today':
        return 'Yesterday';
      case 'Week':
        return 'Last Week';
      case 'Month':
        return 'Last Month';
      case 'Year':
        return 'Last Year';
      default:
        return 'Previous Period';
    }
  }
}