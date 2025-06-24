/*// database/report_database_helper.dart
import 'package:sqflite/sqflite.dart';
import '../../screens/reports/model/report_model.dart';


class ReportDatabaseHelper {
  static Database? _database;

  // Get database instance (assuming you already have this set up)
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    // This should connect to your existing database
    // Update the path to match your existing database
    String path = 'shopmate.db';
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  static Future<void> _createTables(Database db, int version) async {
    // Assuming you already have sales and products tables
    // Add any additional tables if needed
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER,
        quantity INTEGER,
        unit_price REAL,
        total_amount REAL,
        profit REAL,
        sale_date TEXT,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        cost_price REAL,
        selling_price REAL,
        stock_quantity INTEGER,
        created_at TEXT
      )
    ''');
  }

  // Get report summary for a specific period
  static Future<ReportSummary> getReportSummary(String period) async {
    final db = await database;
    final dateFilter = _getDateFilter(period);

    // Get total sales and profit
    final salesResult = await db.rawQuery('''
      SELECT
        COALESCE(SUM(total_amount), 0) as total_sales,
        COALESCE(SUM(profit), 0) as total_profit,
        COUNT(*) as total_transactions,
        COALESCE(SUM(quantity), 0) as total_items_sold
      FROM sales
      WHERE sale_date >= ?
    ''', [dateFilter]);

    // Get previous period data for trend calculation
    final previousDateFilter = _getPreviousDateFilter(period);
    final previousSalesResult = await db.rawQuery('''
      SELECT
        COALESCE(SUM(total_amount), 0) as prev_sales,
        COALESCE(SUM(profit), 0) as prev_profit
      FROM sales
      WHERE sale_date >= ? AND sale_date < ?
    ''', [previousDateFilter, dateFilter]);

    final current = salesResult.first;
    final previous = previousSalesResult.first;

    // Calculate trends
    final currentSales = (current['total_sales'] as num).toDouble();
    final prevSales = (previous['prev_sales'] as num).toDouble();
    final currentProfit = (current['total_profit'] as num).toDouble();
    final prevProfit = (previous['prev_profit'] as num).toDouble();

    final salesTrend = prevSales > 0 ? ((currentSales - prevSales) / prevSales) * 100 : 0.0;
    final profitTrend = prevProfit > 0 ? ((currentProfit - prevProfit) / prevProfit) * 100 : 0.0;

    return ReportSummary(
      totalSales: currentSales,
      totalProfit: currentProfit,
      totalTransactions: (current['total_transactions'] as num).toInt(),
      totalItemsSold: (current['total_items_sold'] as num).toInt(),
      salesTrend: salesTrend,
      profitTrend: profitTrend,
    );
  }

  // Get sales chart data
  static Future<List<ChartData>> getSalesChartData(String period) async {
    final db = await database;
    final dateFilter = _getDateFilter(period);

    String groupBy;
    String dateFormat;

    switch (period) {
      case 'Today':
        groupBy = "strftime('%H', sale_date)";
        dateFormat = '%H:00';
        break;
      case 'Week':
        groupBy = "DATE(sale_date)";
        dateFormat = '%m/%d';
        break;
      case 'Month':
        groupBy = "DATE(sale_date)";
        dateFormat = '%m/%d';
        break;
      case 'Year':
        groupBy = "strftime('%Y-%m', sale_date)";
        dateFormat = '%m/%Y';
        break;
      default:
        groupBy = "DATE(sale_date)";
        dateFormat = '%m/%d';
    }

    final result = await db.rawQuery('''
      SELECT
        $groupBy as period,
        COALESCE(SUM(total_amount), 0) as total_sales
      FROM sales
      WHERE sale_date >= ?
      GROUP BY $groupBy
      ORDER BY period
    ''', [dateFilter]);

    return result.map((row) {
      String label;
      if (period == 'Today') {
        label = '${row['period']}:00';
      } else if (period == 'Year') {
        label = row['period'].toString();
      } else {
        label = row['period'].toString().substring(5); // Remove year part
      }

      return ChartData(
        label: label,
        value: (row['total_sales'] as num).toDouble(),
      );
    }).toList();
  }

  // Get recent transactions
  static Future<List<TransactionModel>> getRecentTransactions({int limit = 10}) async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT
        id,
        total_amount as amount,
        sale_date as date,
        quantity as item_count
      FROM sales
      ORDER BY sale_date DESC
      LIMIT ?
    ''', [limit]);

    return result.map((row) => TransactionModel.fromMap(row)).toList();
  }

  // Get top performing products
  static Future<List<ProductPerformance>> getTopProducts(String period, {int limit = 10}) async {
    final db = await database;
    final dateFilter = _getDateFilter(period);

    final result = await db.rawQuery('''
      SELECT
        p.id,
        p.name,
        COALESCE(SUM(s.quantity), 0) as units_sold,
        COALESCE(SUM(s.total_amount), 0) as revenue,
        COALESCE(SUM(s.profit), 0) as profit
      FROM products p
      LEFT JOIN sales s ON p.id = s.product_id AND s.sale_date >= ?
      GROUP BY p.id, p.name
      HAVING units_sold > 0
      ORDER BY revenue DESC
      LIMIT ?
    ''', [dateFilter, limit]);

    return result.map((row) => ProductPerformance.fromMap(row)).toList();
  }

  // Get top products chart data
  static Future<List<ChartData>> getTopProductsChartData(String period, {int limit = 5}) async {
    final products = await getTopProducts(period, limit: limit);

    return products.map((product) => ChartData(
      label: product.name.length > 8 ? '${product.name.substring(0, 8)}...' : product.name,
      value: product.revenue,
    )).toList();
  }

  // Helper method to get date filter based on period
  static String _getDateFilter(String period) {
    final now = DateTime.now();
    DateTime filterDate;

    switch (period) {
      case 'Today':
        filterDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Week':
        filterDate = now.subtract(Duration(days: now.weekday - 1));
        filterDate = DateTime(filterDate.year, filterDate.month, filterDate.day);
        break;
      case 'Month':
        filterDate = DateTime(now.year, now.month, 1);
        break;
      case 'Year':
        filterDate = DateTime(now.year, 1, 1);
        break;
      default:
        filterDate = DateTime(now.year, now.month, now.day);
    }

    return filterDate.toIso8601String();
  }

  // Helper method to get previous period date filter for trend calculation
  static String _getPreviousDateFilter(String period) {
    final now = DateTime.now();
    DateTime filterDate;

    switch (period) {
      case 'Today':
        filterDate = DateTime(now.year, now.month, now.day - 1);
        break;
      case 'Week':
        filterDate = now.subtract(Duration(days: now.weekday - 1 + 7));
        filterDate = DateTime(filterDate.year, filterDate.month, filterDate.day);
        break;
      case 'Month':
        filterDate = DateTime(now.year, now.month - 1, 1);
        break;
      case 'Year':
        filterDate = DateTime(now.year - 1, 1, 1);
        break;
      default:
        filterDate = DateTime(now.year, now.month, now.day - 1);
    }

    return filterDate.toIso8601String();
  }

  // Get sales data for a specific date range
  static Future<List<Map<String, dynamic>>> getSalesInDateRange(
      DateTime startDate,
      DateTime endDate
      ) async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT s.*, p.name as product_name
      FROM sales s
      LEFT JOIN products p ON s.product_id = p.id
      WHERE s.sale_date >= ? AND s.sale_date <= ?
      ORDER BY s.sale_date DESC
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    return result;
  }

  // Get low stock products for dashboard alerts
  static Future<List<Map<String, dynamic>>> getLowStockProducts({int threshold = 10}) async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT * FROM products
      WHERE stock_quantity <= ?
      ORDER BY stock_quantity ASC
    ''', [threshold]);

    return result;
  }

  // Get profit margin analysis
  static Future<List<Map<String, dynamic>>> getProfitMarginAnalysis(String period) async {
    final db = await database;
    final dateFilter = _getDateFilter(period);

    final result = await db.rawQuery('''
      SELECT
        p.name,
        COALESCE(SUM(s.quantity), 0) as units_sold,
        COALESCE(SUM(s.total_amount), 0) as revenue,
        COALESCE(SUM(s.profit), 0) as total_profit,
        CASE
          WHEN SUM(s.total_amount) > 0
          THEN (SUM(s.profit) / SUM(s.total_amount)) * 100
          ELSE 0
        END as profit_margin_percentage
      FROM products p
      LEFT JOIN sales s ON p.id = s.product_id AND s.sale_date >= ?
      GROUP BY p.id, p.name
      HAVING units_sold > 0
      ORDER BY profit_margin_percentage DESC
    ''', [dateFilter]);

    return result;
  }
}
 */