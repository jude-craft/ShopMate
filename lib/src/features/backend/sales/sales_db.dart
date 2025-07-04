import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'sales.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _createTable,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sales(
        id TEXT PRIMARY KEY,
        productName TEXT NOT NULL,
        price REAL NOT NULL,
        quantity REAL NOT NULL,
        dateTime TEXT NOT NULL,
        paymentMethod TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS sales');
      await _createTable(db, newVersion);
    }


    if (oldVersion < 3) {
      var tableInfo = await db.rawQuery("PRAGMA table_info(sales)");
      bool hasQuantityColumn = tableInfo.any((column) => column['name'] == 'quantity');

      if (!hasQuantityColumn) {
        await db.execute('ALTER TABLE sales ADD COLUMN quantity REAL NOT NULL DEFAULT 1.0');
      }
    }
  }

  // Insert a new sale
  Future<int> insertSale(Map<String, dynamic> sale) async {
    try {
      final db = await database;
      print('Inserting sale: $sale');
      return await db.insert('sales', sale);
    } catch (e) {
      print('Error inserting sale: $e');
      rethrow;
    }
  }

  // Get all sales
  Future<List<Map<String, dynamic>>> getAllSales() async {
    try {
      final db = await database;
      return await db.query('sales', orderBy: 'dateTime DESC');
    } catch (e) {
      print('Error getting all sales: $e');
      return [];
    }
  }

  // Get sales for today
  Future<List<Map<String, dynamic>>> getTodaySales() async {
    try {
      final db = await database;
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      return await db.query(
        'sales',
        where: 'dateTime BETWEEN ? AND ?',
        whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
        orderBy: 'dateTime DESC',
      );
    } catch (e) {
      print('Error getting today sales: $e');
      return [];
    }
  }

  // Get sales by payment method for today
  Future<List<Map<String, dynamic>>> getTodaySalesByPaymentMethod(String paymentMethod) async {
    try {
      final db = await database;
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      return await db.query(
        'sales',
        where: 'dateTime BETWEEN ? AND ? AND paymentMethod = ?',
        whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String(), paymentMethod],
        orderBy: 'dateTime DESC',
      );
    } catch (e) {
      print('Error getting today sales by payment method: $e');
      return [];
    }
  }

  // Delete a sale
  Future<int> deleteSale(String id) async {
    try {
      final db = await database;
      return await db.delete('sales', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('Error deleting sale: $e');
      rethrow;
    }
  }

  // Get recent sales
  Future<List<Map<String, dynamic>>> getRecentSales(int limit) async {
    try {
      final db = await database;
      return await db.query(
        'sales',
        orderBy: 'dateTime DESC',
        limit: limit,
      );
    } catch (e) {
      print('Error getting recent sales: $e');
      return [];
    }
  }

  // Close database
  Future<void> close() async {
    final db = await _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  Future<void> clearAllSales() async {
    try {
      final db = await database;
      await db.delete('sales');
    } catch (e) {
      print('Error clearing sales: $e');
    }
  }
  Future<List<Map<String, dynamic>>> getSalesByDateRange(
      DateTime startDate,
      DateTime endDate
      ) async {
    final db = await database;
    final startTimestamp = startDate.millisecondsSinceEpoch;
    final endTimestamp = endDate.millisecondsSinceEpoch;

    return await db.query(
      'sales',
      where: 'dateTime >= ? AND dateTime <= ?',
      whereArgs: [startTimestamp, endTimestamp],
      orderBy: 'dateTime DESC',
    );
  }

  // Get sales for a specific date
  Future<List<Map<String, dynamic>>> getSalesForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return await getSalesByDateRange(startOfDay, endOfDay);
  }

  // Get sales for a specific month
  Future<List<Map<String, dynamic>>> getSalesForMonth(DateTime date) async {
    final startOfMonth = DateTime(date.year, date.month, 1);
    final endOfMonth = DateTime(date.year, date.month + 1, 0, 23, 59, 59);

    return await getSalesByDateRange(startOfMonth, endOfMonth);
  }

  // Get sales statistics for a date range
  Future<Map<String, dynamic>> getSalesStats(
      DateTime startDate,
      DateTime endDate
      ) async {
    final db = await database;
    final startTimestamp = startDate.millisecondsSinceEpoch;
    final endTimestamp = endDate.millisecondsSinceEpoch;

    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as count,
        SUM(price) as total,
        SUM(CASE WHEN paymentMethod = 'mpesa' THEN price ELSE 0 END) as mpesa_total,
        SUM(CASE WHEN paymentMethod = 'cash' THEN price ELSE 0 END) as cash_total
      FROM sales 
      WHERE dateTime >= ? AND dateTime <= ?
    ''', [startTimestamp, endTimestamp]);

    return result.first;
  }
  
}