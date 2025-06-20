import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Database helper class
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
      version: 1,
      onCreate: _createTable,
    );
  }

  Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sales(
        id TEXT PRIMARY KEY,
        productName TEXT NOT NULL,
        price REAL NOT NULL,
        dateTime TEXT NOT NULL,
        paymentMethod TEXT NOT NULL
      )
    ''');
  }

  // Insert a new sale
  Future<int> insertSale(Map<String, dynamic> sale) async {
    final db = await database;
    return await db.insert('sales', sale);
  }

  // Get all sales
  Future<List<Map<String, dynamic>>> getAllSales() async {
    final db = await database;
    return await db.query('sales', orderBy: 'dateTime DESC');
  }

  // Get sales for today
  Future<List<Map<String, dynamic>>> getTodaySales() async {
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
  }

  // Get sales by payment method for today
  Future<List<Map<String, dynamic>>> getTodaySalesByPaymentMethod(String paymentMethod) async {
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
  }

  // Delete a sale
  Future<int> deleteSale(String id) async {
    final db = await database;
    return await db.delete('sales', where: 'id = ?', whereArgs: [id]);
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}