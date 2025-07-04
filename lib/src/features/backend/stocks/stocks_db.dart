import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../screens/stock/model/stock_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  // Database configuration
  static const String _databaseName = 'shopmate.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String _stockTable = 'stocks';

  // Get database instance
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // Initialize database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Create tables
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_stockTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productName TEXT NOT NULL,
        category TEXT NOT NULL,
        buyingPrice REAL NOT NULL,
        sellingPrice REAL NOT NULL,
        quantity INTEGER NOT NULL,
        minStockLevel INTEGER NOT NULL DEFAULT 5,
        unit TEXT NOT NULL DEFAULT 'pieces',
        dateAdded TEXT NOT NULL,
        expiryDate TEXT,
        description TEXT,
        supplier TEXT,
        soldQuantity INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_stock_name ON $_stockTable(productName)');
    await db.execute('CREATE INDEX idx_stock_category ON $_stockTable(category)');
    await db.execute('CREATE INDEX idx_stock_expiry ON $_stockTable(expiryDate)');
  }

  // Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future database schema changes
    if (oldVersion < newVersion) {
      // For Adding new columns or tables for future versions
      // await db.execute('ALTER TABLE stocks ADD COLUMN newColumn TEXT');
    }
  }

  // Insert new stock
  Future<int> insertStock(Stock stock) async {
    final db = await database;
    try {
      final id = await db.insert(
        _stockTable,
        stock.toMap()..remove('id'),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id;
    } catch (e) {
      throw DatabaseException('Failed to insert stock: $e');
    }
  }

  // Get all stocks
  Future<List<Stock>> getAllStocks() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _stockTable,
        orderBy: 'productName ASC',
      );
      return maps.map((map) => Stock.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException('Failed to get all stocks: $e');
    }
  }

  // Get stock by ID
  Future<Stock?> getStockById(int id) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _stockTable,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return Stock.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw DatabaseException('Failed to get stock by ID: $e');
    }
  }

  // Update stock
  Future<bool> updateStock(Stock stock) async {
    final db = await database;
    try {
      final count = await db.update(
        _stockTable,
        stock.toMap(),
        where: 'id = ?',
        whereArgs: [stock.id],
      );
      return count > 0;
    } catch (e) {
      throw DatabaseException('Failed to update stock: $e');
    }
  }

  // Delete stock
  Future<bool> deleteStock(int id) async {
    final db = await database;
    try {
      final count = await db.delete(
        _stockTable,
        where: 'id = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      throw DatabaseException('Failed to delete stock: $e');
    }
  }

  // Search stocks by name or category
  Future<List<Stock>> searchStocks(String query) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _stockTable,
        where: 'productName LIKE ? OR category LIKE ? OR supplier LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
        orderBy: 'productName ASC',
      );
      return maps.map((map) => Stock.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException('Failed to search stocks: $e');
    }
  }

  // Get stocks by category
  Future<List<Stock>> getStocksByCategory(String category) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _stockTable,
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'productName ASC',
      );
      return maps.map((map) => Stock.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException('Failed to get stocks by category: $e');
    }
  }

  // Get low stock items
  Future<List<Stock>> getLowStockItems() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT * FROM $_stockTable 
        WHERE (quantity - soldQuantity) <= minStockLevel 
        AND (quantity - soldQuantity) > 0
        ORDER BY (quantity - soldQuantity) ASC
      ''');
      return maps.map((map) => Stock.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException('Failed to get low stock items: $e');
    }
  }

  // Get out of stock items
  Future<List<Stock>> getOutOfStockItems() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT * FROM $_stockTable 
        WHERE (quantity - soldQuantity) <= 0
        ORDER BY productName ASC
      ''');
      return maps.map((map) => Stock.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException('Failed to get out of stock items: $e');
    }
  }

  // Get expired items
  Future<List<Stock>> getExpiredItems() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _stockTable,
        where: 'expiryDate IS NOT NULL AND expiryDate < ?',
        whereArgs: [now],
        orderBy: 'expiryDate ASC',
      );
      return maps.map((map) => Stock.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException('Failed to get expired items: $e');
    }
  }

  // Get items expiring soon (within 7 days)
  Future<List<Stock>> getExpiringSoonItems() async {
    final db = await database;
    final now = DateTime.now();
    final sevenDaysFromNow = now.add(const Duration(days: 7)).toIso8601String();
    final nowString = now.toIso8601String();

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _stockTable,
        where: 'expiryDate IS NOT NULL AND expiryDate > ? AND expiryDate <= ?',
        whereArgs: [nowString, sevenDaysFromNow],
        orderBy: 'expiryDate ASC',
      );
      return maps.map((map) => Stock.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException('Failed to get expiring soon items: $e');
    }
  }

  // Get all unique categories
  Future<List<String>> getAllCategories() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT DISTINCT category FROM $_stockTable 
        WHERE category IS NOT NULL AND category != ''
        ORDER BY category ASC
      ''');
      return maps.map((map) => map['category'] as String).toList();
    } catch (e) {
      throw DatabaseException('Failed to get categories: $e');
    }
  }

  // Get all unique suppliers
  Future<List<String>> getAllSuppliers() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT DISTINCT supplier FROM $_stockTable 
        WHERE supplier IS NOT NULL AND supplier != ''
        ORDER BY supplier ASC
      ''');
      return maps.map((map) => map['supplier'] as String).toList();
    } catch (e) {
      throw DatabaseException('Failed to get suppliers: $e');
    }
  }

  // Update sold quantity for a specific stock
  Future<bool> updateSoldQuantity(int stockId, int additionalSoldQuantity) async {
    final db = await database;
    try {
      final count = await db.rawUpdate('''
        UPDATE $_stockTable 
        SET soldQuantity = soldQuantity + ? 
        WHERE id = ?
      ''', [additionalSoldQuantity, stockId]);
      return count > 0;
    } catch (e) {
      throw DatabaseException('Failed to update sold quantity: $e');
    }
  }

  // Get stock statistics
  Future<Map<String, dynamic>> getStockStatistics() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> totalProducts = await db.rawQuery('''
        SELECT COUNT(*) as count FROM $_stockTable
      ''');

      final List<Map<String, dynamic>> lowStock = await db.rawQuery('''
        SELECT COUNT(*) as count FROM $_stockTable 
        WHERE (quantity - soldQuantity) <= minStockLevel AND (quantity - soldQuantity) > 0
      ''');

      final List<Map<String, dynamic>> outOfStock = await db.rawQuery('''
        SELECT COUNT(*) as count FROM $_stockTable 
        WHERE (quantity - soldQuantity) <= 0
      ''');

      final now = DateTime.now().toIso8601String();
      final List<Map<String, dynamic>> expired = await db.rawQuery('''
        SELECT COUNT(*) as count FROM $_stockTable 
        WHERE expiryDate IS NOT NULL AND expiryDate < ?
      ''', [now]);

      final sevenDaysFromNow = DateTime.now().add(const Duration(days: 7)).toIso8601String();
      final List<Map<String, dynamic>> expiringSoon = await db.rawQuery('''
        SELECT COUNT(*) as count FROM $_stockTable 
        WHERE expiryDate IS NOT NULL AND expiryDate > ? AND expiryDate <= ?
      ''', [now, sevenDaysFromNow]);

      final List<Map<String, dynamic>> investment = await db.rawQuery('''
        SELECT SUM(quantity * buyingPrice) as total FROM $_stockTable
      ''');

      final List<Map<String, dynamic>> currentValue = await db.rawQuery('''
        SELECT SUM((quantity - soldQuantity) * buyingPrice) as total FROM $_stockTable
      ''');

      final List<Map<String, dynamic>> profit = await db.rawQuery('''
        SELECT SUM(soldQuantity * (sellingPrice - buyingPrice)) as total FROM $_stockTable
      ''');

      final List<Map<String, dynamic>> categoriesCount = await db.rawQuery('''
        SELECT COUNT(DISTINCT category) as count FROM $_stockTable 
        WHERE category IS NOT NULL AND category != ''
      ''');

      return {
        'totalProducts': totalProducts.first['count'] ?? 0,
        'lowStockItems': lowStock.first['count'] ?? 0,
        'outOfStockItems': outOfStock.first['count'] ?? 0,
        'expiredItems': expired.first['count'] ?? 0,
        'expiringSoonItems': expiringSoon.first['count'] ?? 0,
        'totalInvestment': investment.first['total'] ?? 0.0,
        'currentStockValue': currentValue.first['total'] ?? 0.0,
        'totalProfit': profit.first['total'] ?? 0.0,
        'totalCategories': categoriesCount.first['count'] ?? 0,
      };
    } catch (e) {
      throw DatabaseException('Failed to get stock statistics: $e');
    }
  }

  // Clear all stocks (useful for testing or reset)
  Future<bool> clearAllStocks() async {
    final db = await database;
    try {
      final count = await db.delete(_stockTable);
      return count >= 0;
    } catch (e) {
      throw DatabaseException('Failed to clear all stocks: $e');
    }
  }

  // Backup database (returns all data as JSON-compatible maps)
  Future<List<Map<String, dynamic>>> backupStocks() async {
    final db = await database;
    try {
      return await db.query(_stockTable);
    } catch (e) {
      throw DatabaseException('Failed to backup stocks: $e');
    }
  }

  // Restore from backup
  Future<bool> restoreStocks(List<Map<String, dynamic>> stocksData) async {
    final db = await database;
    try {
      await db.transaction((txn) async {
        // Clear existing data
        await txn.delete(_stockTable);

        // Insert backup data
        for (final stockData in stocksData) {
          await txn.insert(_stockTable, stockData);
        }
      });
      return true;
    } catch (e) {
      throw DatabaseException('Failed to restore stocks: $e');
    }
  }
  Future<Stock?> getStockByName(String productName) async {
  final db = await database;
  try {
    final List<Map<String, dynamic>> maps = await db.query(
      _stockTable,
      where: 'productName = ?',
      whereArgs: [productName],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Stock.fromMap(maps.first);
    }
    return null;
  } catch (e) {
    throw DatabaseException('Failed to get stock by name: $e');
  }
}

  // Close database
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

// Custom exception for database operations
class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}