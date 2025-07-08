import 'package:flutter/material.dart';
import '../../sales/provider/sales_provider.dart';
import '../../stock/provider/stock_provider.dart';
import '../model/report_model.dart';

class ReportProvider extends ChangeNotifier {
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
  List<ProductPerformance> _topProducts = [];

  // Getters
  bool get isLoading => _isLoading;
  double get totalSales => _totalSales;
  double get totalProfit => _totalProfit;
  int get totalTransactions => _totalTransactions;
  num get totalItemsSold => _totalItemsSold;
  double get salesTrend => _salesTrend;
  double get profitTrend => _profitTrend;
  List<ChartData> get salesChartData => _salesChartData;
  List<ChartData> get topProductsData => _topProductsData;
  List<ProductPerformance> get topProducts => _topProducts;

  // Providers (must be set from outside)
  late SalesProvider salesProvider;
  late StockProvider stockProvider;

  void setProviders({required SalesProvider sales, required StockProvider stock}) {
    salesProvider = sales;
    stockProvider = stock;
  }

  // Load all reports data
  Future<void> loadReports() async {
    _isLoading = true;
    notifyListeners();

    try {
      _loadSummaryData();
      _loadChartData();
      _loadTopProducts();
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
  void _loadSummaryData() {
    dynamic sales = _getSalesForPeriod();
    _totalSales = sales.fold(0.0, (sum, sale) => sum + (sale.price as double));
    _totalTransactions = sales.length;
    _totalItemsSold = sales.fold(0, (sum, sale) => sum + sale.quantity());
    _totalProfit = _calculateTotalProfit(sales);
    _salesTrend = _calculateSalesTrend(sales);
    _profitTrend = _calculateProfitTrend(sales);
  }

  // Load chart data
  void _loadChartData() {
    _salesChartData = _generateSalesTrendChartData();
    _topProductsData = _generateTopProductsChartData();
  }

  // Load top products
  void _loadTopProducts() {
    _topProducts = _generateProductPerformanceList();
  }

  // --- Helper Methods ---

  List get _allSales => salesProvider.sales;

  List get _allStocks => stockProvider.stocks;

  // Get sales for the selected period
  List _getSalesForPeriod() {
    final now = DateTime.now();
    switch (_currentPeriod) {
      case 'Today':
        return salesProvider.getSalesForDate(now);
      case 'Week':
      case 'This Week':
        final start = now.subtract(Duration(days: now.weekday - 1));
        final end = start.add(const Duration(days: 6));
        return salesProvider.getSalesBetweenDates(start, end);
      case 'Month':
      case 'This Month':
        return salesProvider.getSalesForMonth(now);
      case 'Year':
      case 'This Year':
        return salesProvider.getSalesForYear(now);
      default:
        return salesProvider.getSalesForDate(now);
    }
  }

  // Calculate total profit for a list of sales
  double _calculateTotalProfit(List sales) {
    double totalProfit = 0.0;
    for (var sale in sales) {
      final stock = stockProvider.getStockByName(sale.productName);
      if (stock != null && stock.profitPerUnit != null) {
        final profitPerUnit = stock.profitPerUnit;
        totalProfit += profitPerUnit * sale.quantity;
      } else {
        totalProfit += sale.price * 0.3; // fallback margin
      }
    }
    return totalProfit;
  }

  // Calculate sales trend (compare with previous period)
  double _calculateSalesTrend(List sales) {
    // For simplicity, compare with previous period of same length
    final now = DateTime.now();
    List prevSales = [];
    switch (_currentPeriod) {
      case 'Today':
        prevSales = salesProvider.getSalesForDate(now.subtract(const Duration(days:1)));
        break;
      case 'Week':
      case 'This Week':
        final start = now.subtract(Duration(days: now.weekday - 1 + 7));
        final end = start.add(const Duration(days: 6));
        prevSales = salesProvider.getSalesBetweenDates(start, end);
        break;
      case 'Month':
      case 'This Month':
        final prevMonth = DateTime(now.year, now.month - 1, 1);
        prevSales = salesProvider.getSalesForMonth(prevMonth);
        break;
      case 'Year':
      case 'This Year':
        final prevYear = DateTime(now.year - 1, 1, 1);
        prevSales = salesProvider.getSalesForYear(prevYear);
        break;
      default:
        prevSales = [];
    }
    final currentTotal = sales.fold(0.0, (sum, sale) => sum + (sale.price as double));
    final prevTotal = prevSales.fold(0.0, (sum, sale) => sum + (sale.price as double));
    if (prevTotal == 0) return 0.0;
    return ((currentTotal - prevTotal) / prevTotal) * 100;
  }

  // Calculate profit trend (compare with previous period)
  double _calculateProfitTrend(List sales) {
    final now = DateTime.now();
    List prevSales = [];
    switch (_currentPeriod) {
      case 'Today':
        prevSales = salesProvider.getSalesForDate(now.subtract(const Duration(days:1)));
        break;
      case 'Week':
      case 'This Week':
        final start = now.subtract(Duration(days: now.weekday - 1 + 7));
        final end = start.add(const Duration(days: 6));
        prevSales = salesProvider.getSalesBetweenDates(start, end);
        break;
      case 'Month':
      case 'This Month':
        final prevMonth = DateTime(now.year, now.month - 1, 1);
        prevSales = salesProvider.getSalesForMonth(prevMonth);
        break;
      case 'Year':
      case 'This Year':
        final prevYear = DateTime(now.year - 1, 1, 1);
        prevSales = salesProvider.getSalesForYear(prevYear);
        break;
      default:
        prevSales = [];
    }
    final currentProfit = _calculateTotalProfit(sales);
    final prevProfit = _calculateTotalProfit(prevSales);
    if (prevProfit == 0) return 0.0;
    return ((currentProfit - prevProfit) / prevProfit) * 100;
  }

  // Generate sales trend chart data
  List<ChartData> _generateSalesTrendChartData() {
    final sales = _getSalesForPeriod();
    Map<String, double> grouped = {};
    if (_currentPeriod == 'Today') {
      // Group by hour
      for (var sale in sales) {
        final hour = sale.dateTime.hour;
        final label = '${hour.toString().padLeft(2, '0')}:00';
        grouped[label] = (grouped[label] ?? 0) + (sale.price as double);
      }
    } else if (_currentPeriod.contains('Week')) {
      // Group by day
      for (var sale in sales) {
        final weekday = sale.dateTime.weekday;
        final label = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];
        grouped[label] = (grouped[label] ?? 0) + (sale.price as double);
      }
    } else if (_currentPeriod.contains('Month')) {
      // Group by day
      for (var sale in sales) {
        final day = sale.dateTime.day;
        final label = day.toString();
        grouped[label] = (grouped[label] ?? 0) + (sale.price as double);
      }
    } else if (_currentPeriod.contains('Year')) {
      // Group by month
      for (var sale in sales) {
        final month = sale.dateTime.month;
        final label = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][month - 1];
        grouped[label] = (grouped[label] ?? 0) + (sale.price as double);
      }
    }
    return grouped.entries.map((e) => ChartData(label: e.key, value: e.value)).toList();
  }

  // Generate top products chart data
  List<ChartData> _generateTopProductsChartData() {
    final sales = _getSalesForPeriod();
    Map<String, double> productTotals = {};
    for (var sale in sales) { // Assuming sale.price is double
      productTotals[sale.productName] = (productTotals[sale.productName] ?? 0) + sale.price;
    }
    var sorted = productTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).map((e) {
      String label = e.key.length > 8 ? '${e.key.substring(0, 8)}...' : e.key;
      return ChartData(label: label, value: e.value);
    }).toList();
  }

  // Generate product performance list
  List<ProductPerformance> _generateProductPerformanceList() {
    final sales = _getSalesForPeriod();
    Map<String, ProductPerformance> performance = {};
    for (var sale in sales) { // Assuming sale.price is double
      final stock = stockProvider.getStockByName(sale.productName);
      final profit = stock != null && stock.profitPerUnit != null ? stock.profitPerUnit! * sale.quantity : (sale.price as double) * 0.3;
      if (performance.containsKey(sale.productName)) {
        final prev = performance[sale.productName]!;
        performance[sale.productName] = ProductPerformance(
          id: prev.id,
          name: prev.name,
          unitsSold: prev.unitsSold + sale.quantity.toInt(),
          revenue: prev.revenue + (sale.price as double),
          profit: prev.profit + profit,
        );
      } else {
        performance[sale.productName] = ProductPerformance(
          id: stock?.id ?? 0,
          name: sale.productName,
          unitsSold: sale.quantity.toInt(),
          revenue: (sale.price as double),
          profit: profit,
        );
      }
    }
    var list = performance.values.toList();
    list.sort((a, b) => b.revenue.compareTo(a.revenue));
    return list;
  }
}