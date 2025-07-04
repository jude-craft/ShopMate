import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../screens/reports/model/report_model.dart';
import '../sales/sales_db.dart';
import '../stocks/stocks_db.dart';
import '../../screens/sales/models/sale_model.dart';

class ReportsDatabaseHelper {
  static final ReportsDatabaseHelper _instance =
      ReportsDatabaseHelper._internal();
  static Database? _database;

  ReportsDatabaseHelper._internal();

  factory ReportsDatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'reports.db');
    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    // Create reports cache table for performance
    await db.execute('''
      CREATE TABLE IF NOT EXISTS reports_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        period TEXT NOT NULL,
        total_sales REAL NOT NULL,
        total_profit REAL NOT NULL,
        total_transactions INTEGER NOT NULL,
        total_items_sold INTEGER NOT NULL,
        sales_trend REAL NOT NULL,
        profit_trend REAL NOT NULL,
        last_updated TEXT NOT NULL
      )
    ''');

    // Create product performance cache
    await db.execute('''
      CREATE TABLE IF NOT EXISTS product_performance_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        period TEXT NOT NULL,
        product_name TEXT NOT NULL,
        units_sold INTEGER NOT NULL,
        revenue REAL NOT NULL,
        profit REAL NOT NULL,
        last_updated TEXT NOT NULL
      )
    ''');
  }

  // Get report summary for a specific period
  Future<ReportSummary> getReportSummary(String period) async {
    try {
      final salesDb = DatabaseHelper();
      final stockDb = DatabaseService();

      final dateRange = _getDateRange(period);
      final currentSales = await _getSalesInRange(
        salesDb,
        dateRange['start']!,
        dateRange['end']!,
      );

      // Get previous period for trend calculation
      final previousRange = _getPreviousDateRange(period);
      final previousSales = await _getSalesInRange(
        salesDb,
        previousRange['start']!,
        previousRange['end']!,
      );

      // Calculate current period totals
      final totalSales = currentSales.fold<double>(
        0.0,
        (sum, sale) => sum + sale.price,
      );
      final totalTransactions = currentSales.length;
      final totalItemsSold = currentSales.fold<int>(
        0,
        (sum, sale) => sum + sale.quantity.toInt(),
      );

      // Calculate profit from stock data
      double totalProfit = 0.0;
      for (var sale in currentSales) {
        final stock = await stockDb.getStockByName(sale.productName);
        if (stock != null) {
          final profitPerUnit = stock.profitPerUnit;
          totalProfit += profitPerUnit * sale.quantity;
        } else {
          // Assume 30% profit margin if stock not found
          totalProfit += sale.price * 0.3;
        }
      }

      // Calculate previous period totals for trend
      final previousTotalSales = previousSales.fold<double>(
        0.0,
        (sum, sale) => sum + sale.price,
      );
      double previousTotalProfit = 0.0;
      for (var sale in previousSales) {
        final stock = await stockDb.getStockByName(sale.productName);
        if (stock != null) {
          final profitPerUnit = stock.profitPerUnit;
          previousTotalProfit += profitPerUnit * sale.quantity;
        } else {
          previousTotalProfit += sale.price * 0.3;
        }
      }

      // Calculate trends
      final salesTrend = previousTotalSales > 0
          ? ((totalSales - previousTotalSales) / previousTotalSales) * 100
          : 0.0;
      final profitTrend = previousTotalProfit > 0
          ? ((totalProfit - previousTotalProfit) / previousTotalProfit) * 100
          : 0.0;

      return ReportSummary(
        totalSales: totalSales,
        totalProfit: totalProfit,
        totalTransactions: totalTransactions,
        totalItemsSold: totalItemsSold,
        salesTrend: salesTrend,
        profitTrend: profitTrend,
      );
    } catch (e) {
      print('Error getting report summary: $e');
      return ReportSummary(
        totalSales: 0.0,
        totalProfit: 0.0,
        totalTransactions: 0,
        totalItemsSold: 0,
        salesTrend: 0.0,
        profitTrend: 0.0,
      );
    }
  }

  // Get sales chart data
  Future<List<ChartData>> getSalesChartData(String period) async {
    try {
      final salesDb = DatabaseHelper();
      final dateRange = _getDateRange(period);
      final sales = await _getSalesInRange(
        salesDb,
        dateRange['start']!,
        dateRange['end']!,
      );

      Map<String, double> groupedData = {};

      for (var sale in sales) {
        String key = _getChartKey(sale.dateTime, period);
        groupedData[key] = (groupedData[key] ?? 0) + sale.price;
      }

      return groupedData.entries.map((entry) {
        return ChartData(label: entry.key, value: entry.value);
      }).toList();
    } catch (e) {
      print('Error getting sales chart data: $e');
      return [];
    }
  }

  // Get recent transactions
  Future<List<TransactionModel>> getRecentTransactions({int limit = 10}) async {
    try {
      final salesDb = DatabaseHelper();
      final salesData = await salesDb.getAllSales();

      return salesData.take(limit).map((saleData) {
        return TransactionModel(
          id: saleData['id']?.toString() ?? '',
          amount: (saleData['price'] as num?)?.toDouble() ?? 0.0,
          date: _formatDate(saleData['dateTime']?.toString() ?? ''),
          itemCount: (saleData['quantity'] as num?)?.toInt() ?? 1,
        );
      }).toList();
    } catch (e) {
      print('Error getting recent transactions: $e');
      return [];
    }
  }

  // Get top performing products
  Future<List<ProductPerformance>> getTopProducts(
    String period, {
    int limit = 10,
  }) async {
    try {
      final salesDb = DatabaseHelper();
      final stockDb = DatabaseService();
      final dateRange = _getDateRange(period);
      final sales = await _getSalesInRange(
        salesDb,
        dateRange['start']!,
        dateRange['end']!,
      );

      // Group sales by product
      Map<String, ProductData> productMap = {};

      for (var sale in sales) {
        if (productMap.containsKey(sale.productName)) {
          productMap[sale.productName]!.revenue += sale.price;
          productMap[sale.productName]!.unitsSold += sale.quantity.toInt();
        } else {
          productMap[sale.productName] = ProductData(
            name: sale.productName,
            revenue: sale.price,
            unitsSold: sale.quantity.toInt(),
          );
        }
      }

      // Convert to ProductPerformance list and calculate profit
      List<ProductPerformance> topProducts = [];
      for (var entry in productMap.entries) {
        final stock = await stockDb.getStockByName(entry.key);
        double profit = 0.0;

        if (stock != null) {
          profit = stock.profitPerUnit * entry.value.unitsSold;
        } else {
          // Assume 30% profit margin if stock not found
          profit = entry.value.revenue * 0.3;
        }

        topProducts.add(
          ProductPerformance(
            id: entry.key.hashCode,
            name: entry.key,
            unitsSold: entry.value.unitsSold,
            revenue: entry.value.revenue,
            profit: profit,
          ),
        );
      }

      // Sort by revenue and take top products
      topProducts.sort((a, b) => b.revenue.compareTo(a.revenue));
      return topProducts.take(limit).toList();
    } catch (e) {
      print('Error getting top products: $e');
      return [];
    }
  }

  // Helper methods
  Future<List<Sale>> _getSalesInRange(
    DatabaseHelper salesDb,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final salesData = await salesDb.getSalesByDateRange(start, end);
      return salesData.map((map) => Sale.fromMap(map)).toList();
    } catch (e) {
      print('Error getting sales in range: $e');
      return [];
    }
  }

  Map<String, DateTime?> _getDateRange(String period) {
    final now = DateTime.now();
    DateTime start;
    DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (period) {
      case 'Today':
        start = DateTime(now.year, now.month, now.day);
        break;
      case 'Week':
        start = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(start.year, start.month, start.day);
        break;
      case 'Month':
        start = DateTime(now.year, now.month, 1);
        break;
      case 'Year':
        start = DateTime(now.year, 1, 1);
        break;
      default:
        start = DateTime(now.year, now.month, now.day);
    }

    return {'start': start, 'end': end};
  }

  Map<String, DateTime?> _getPreviousDateRange(String period) {
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    switch (period) {
      case 'Today':
        start = DateTime(now.year, now.month, now.day - 1);
        end = DateTime(now.year, now.month, now.day - 1, 23, 59, 59);
        break;
      case 'Week':
        start = now.subtract(Duration(days: now.weekday + 6));
        start = DateTime(start.year, start.month, start.day);
        end = now.subtract(Duration(days: now.weekday));
        end = DateTime(end.year, end.month, end.day, 23, 59, 59);
        break;
      case 'Month':
        start = DateTime(now.year, now.month - 1, 1);
        end = DateTime(now.year, now.month, 0, 23, 59, 59);
        break;
      case 'Year':
        start = DateTime(now.year - 1, 1, 1);
        end = DateTime(now.year - 1, 12, 31, 23, 59, 59);
        break;
      default:
        start = DateTime(now.year, now.month, now.day - 1);
        end = DateTime(now.year, now.month, now.day - 1, 23, 59, 59);
    }

    return {'start': start, 'end': end};
  }

  String _getChartKey(DateTime dateTime, String period) {
    switch (period) {
      case 'Today':
        return '${dateTime.hour.toString().padLeft(2, '0')}:00';
      case 'Week':
        return '${dateTime.day}/${dateTime.month}';
      case 'Month':
        return '${dateTime.day}/${dateTime.month}';
      case 'Year':
        return '${dateTime.month}/${dateTime.year}';
      default:
        return '${dateTime.day}/${dateTime.month}';
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}

// Helper class for product data aggregation
class ProductData {
  String name;
  double revenue;
  int unitsSold;

  ProductData({
    required this.name,
    required this.revenue,
    required this.unitsSold,
  });
}
