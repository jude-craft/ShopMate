import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'shopmate.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    // Products table
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        barcode TEXT UNIQUE,
        cost_price REAL NOT NULL,
        selling_price REAL NOT NULL,
        stock_quantity INTEGER NOT NULL DEFAULT 0,
        min_stock_level INTEGER NOT NULL DEFAULT 5,
        category TEXT,
        description TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Sales table
    await db.execute('''
      CREATE TABLE sales(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total_amount REAL NOT NULL,
        total_profit REAL NOT NULL,
        payment_method TEXT NOT NULL,
        customer_name TEXT,
        customer_phone TEXT,
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Sale items table
    await db.execute('''
      CREATE TABLE sale_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        unit_cost REAL NOT NULL,
        subtotal REAL NOT NULL,
        profit REAL NOT NULL,
        FOREIGN KEY (sale_id) REFERENCES sales (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // Insert sample products
    await _insertSampleData(db);
  }

  Future<void> _insertSampleData(Database db) async {
    final now = DateTime.now().toIso8601String();

    await db.insert('products', {
      'name': 'Coca Cola 500ml',
      'barcode': '123456789',
      'cost_price': 25.0,
      'selling_price': 35.0,
      'stock_quantity': 50,
      'min_stock_level': 10,
      'category': 'Beverages',
      'description': 'Refreshing cola drink',
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('products', {
      'name': 'Bread Loaf',
      'barcode': '987654321',
      'cost_price': 40.0,
      'selling_price': 55.0,
      'stock_quantity': 20,
      'min_stock_level': 5,
      'category': 'Bakery',
      'description': 'Fresh white bread',
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('products', {
      'name': 'Milk 1L',
      'barcode': '456789123',
      'cost_price': 60.0,
      'selling_price': 80.0,
      'stock_quantity': 8,
      'min_stock_level': 10,
      'category': 'Dairy',
      'description': 'Fresh cow milk',
      'created_at': now,
      'updated_at': now,
    });
  }

  // Product operations
  Future<int> insertProduct(Map<String, dynamic> product) async {
    final db = await database;
    return await db.insert('products', product);
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await database;
    return await db.query('products', orderBy: 'name ASC');
  }

  Future<Map<String, dynamic>?> getProductById(int id) async {
    final db = await database;
    final result = await db.query('products', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    final db = await database;
    final result = await db.query('products', where: 'barcode = ?', whereArgs: [barcode]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    final db = await database;
    return await db.query(
      'products',
      where: 'name LIKE ? OR barcode LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
  }

  Future<int> updateProduct(int id, Map<String, dynamic> product) async {
    final db = await database;
    return await db.update('products', product, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateProductStock(int productId, int newQuantity) async {
    final db = await database;
    return await db.update(
      'products',
      {'stock_quantity': newQuantity, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  Future<List<Map<String, dynamic>>> getLowStockProducts() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT * FROM products 
      WHERE stock_quantity <= min_stock_level 
      ORDER BY stock_quantity ASC
    ''');
  }

  // Sales operations
  Future<int> insertSale(Map<String, dynamic> sale) async {
    final db = await database;
    return await db.insert('sales', sale);
  }

  Future<int> insertSaleItem(Map<String, dynamic> saleItem) async {
    final db = await database;
    return await db.insert('sale_items', saleItem);
  }

  Future<List<Map<String, dynamic>>> getAllSales() async {
    final db = await database;
    return await db.query('sales', orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> getSaleItems(int saleId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT si.*, p.name as product_name 
      FROM sale_items si
      JOIN products p ON si.product_id = p.id
      WHERE si.sale_id = ?
    ''', [saleId]);
  }

  Future<Map<String, dynamic>> getSalesReport(DateTime startDate, DateTime endDate) async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_sales,
        COALESCE(SUM(total_amount), 0) as total_revenue,
        COALESCE(SUM(total_profit), 0) as total_profit
      FROM sales 
      WHERE created_at BETWEEN ? AND ?
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    return result.first;
  }

  Future<List<Map<String, dynamic>>> getTopSellingProducts(int limit) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        p.name,
        p.selling_price,
        SUM(si.quantity) as total_sold,
        SUM(si.subtotal) as total_revenue,
        SUM(si.profit) as total_profit
      FROM sale_items si
      JOIN products p ON si.product_id = p.id
      GROUP BY p.id, p.name, p.selling_price
      ORDER BY total_sold DESC
      LIMIT ?
    ''', [limit]);
  }

  Future<void> deleteDatabase() async {
    String path = join(await getDatabasesPath(), 'shopmate.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}