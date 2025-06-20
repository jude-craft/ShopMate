import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../backend/sales/sales_db.dart';
import '../../providers/theme_provider.dart';


class Sale {
  final String id;
  final String productName;
  final double price;
  final DateTime dateTime;
  final PaymentMethod paymentMethod;

  Sale({
    required this.id,
    required this.productName,
    required this.price,
    required this.dateTime,
    required this.paymentMethod,
  });

  // Convert Sale to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'price': price,
      'dateTime': dateTime.toIso8601String(),
      'paymentMethod': paymentMethod.toString().split('.').last,
    };
  }

  // Create Sale from Map (database)
  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      productName: map['productName'],
      price: map['price'],
      dateTime: DateTime.parse(map['dateTime']),
      paymentMethod: map['paymentMethod'] == 'mpesa'
          ? PaymentMethod.mpesa
          : PaymentMethod.cash,
    );
  }
}

enum PaymentMethod { mpesa, cash }

class SalesProvider extends ChangeNotifier {
  List<Sale> _sales = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Sale> get sales => _sales;

  // Initialize and load sales from database
  Future<void> initializeDatabase() async {
    await loadSalesFromDatabase();
  }

  // Load all sales from database
  Future<void> loadSalesFromDatabase() async {
    try {
      final salesData = await _dbHelper.getAllSales();
      _sales = salesData.map((map) => Sale.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading sales: $e');
    }
  }

  // Add sale to both local list and database
  Future<void> addSale(Sale sale) async {
    try {
      await _dbHelper.insertSale(sale.toMap());
      _sales.insert(0, sale); // Add to beginning for recent-first order
      notifyListeners();
    } catch (e) {
      print('Error adding sale: $e');
      throw e;
    }
  }

  // Delete sale from both local list and database
  Future<void> deleteSale(String saleId) async {
    try {
      await _dbHelper.deleteSale(saleId);
      _sales.removeWhere((sale) => sale.id == saleId);
      notifyListeners();
    } catch (e) {
      print('Error deleting sale: $e');
      throw e;
    }
  }

  double get totalSalesToday {
    final today = DateTime.now();
    return _sales
        .where((sale) =>
    sale.dateTime.day == today.day &&
        sale.dateTime.month == today.month &&
        sale.dateTime.year == today.year)
        .fold(0.0, (sum, sale) => sum + sale.price);
  }

  double get mpesaSalesToday {
    final today = DateTime.now();
    return _sales
        .where((sale) =>
    sale.dateTime.day == today.day &&
        sale.dateTime.month == today.month &&
        sale.dateTime.year == today.year &&
        sale.paymentMethod == PaymentMethod.mpesa)
        .fold(0.0, (sum, sale) => sum + sale.price);
  }

  double get cashSalesToday {
    final today = DateTime.now();
    return _sales
        .where((sale) =>
    sale.dateTime.day == today.day &&
        sale.dateTime.month == today.month &&
        sale.dateTime.year == today.year &&
        sale.paymentMethod == PaymentMethod.cash)
        .fold(0.0, (sum, sale) => sum + sale.price);
  }

  List<Sale> get todaySales {
    final today = DateTime.now();
    return _sales
        .where((sale) =>
    sale.dateTime.day == today.day &&
        sale.dateTime.month == today.month &&
        sale.dateTime.year == today.year)
        .toList();
  }

  Map<String, double> get productTotals {
    Map<String, double> totals = {};
    for (var sale in _sales) {
      totals[sale.productName] = (totals[sale.productName] ?? 0) + sale.price;
    }
    return totals;
  }
}

class AllSalesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, SalesProvider>(
      builder: (context, themeProvider, salesProvider, child) {
        final isDark = themeProvider.isDarkMode;
        final today = DateTime.now();
        final todayFormatted = '${today.day}/${today.month}/${today.year}';

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
          appBar: AppBar(
            elevation: 0,
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            title: Text(
              'All Sales - $todayFormatted',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF2D3748),
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isDark ? Colors.white : const Color(0xFF2D3748),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: salesProvider.todaySales.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 64,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No sales recorded today',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: salesProvider.todaySales.length,
            itemBuilder: (context, index) {
              final sale = salesProvider.todaySales.reversed.toList()[index];
              return Dismissible(
                key: Key(sale.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) async {
                  await salesProvider.deleteSale(sale.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${sale.productName} deleted')),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: sale.paymentMethod == PaymentMethod.mpesa
                              ? const Color(0xFF00C851).withOpacity(0.1)
                              : const Color(0xFF667EEA).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          sale.paymentMethod == PaymentMethod.mpesa
                              ? Icons.phone_android
                              : Icons.money,
                          color: sale.paymentMethod == PaymentMethod.mpesa
                              ? const Color(0xFF00C851)
                              : const Color(0xFF667EEA),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sale.productName,
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF2D3748),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${sale.dateTime.hour.toString().padLeft(2, '0')}:${sale.dateTime.minute.toString().padLeft(2, '0')} • ${sale.paymentMethod == PaymentMethod.mpesa ? 'M-Pesa' : 'Cash'}',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Ksh ${sale.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF2D3748),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// Sales Screen
class SalesScreen extends StatefulWidget {
  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, SalesProvider>(
      builder: (context, themeProvider, salesProvider, child) {
        final isDark = themeProvider.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
          appBar: AppBar(
            elevation: 0,
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            title: Text(
              'Sales',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF2D3748),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Today's Summary Card - Enhanced with payment method breakdown
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF2D3748), const Color(0xFF4A5568)]
                          : [const Color(0xFF667EEA), const Color(0xFF764BA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Sales',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ksh ${salesProvider.totalSalesToday.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Payment method breakdown
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.phone_android,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'M-Pesa',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Ksh ${salesProvider.mpesaSalesToday.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.money,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Cash',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Ksh ${salesProvider.cashSalesToday.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${salesProvider.todaySales.length} transactions',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Add Sale Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add New Sale',
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF2D3748),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Product Name Field
                      TextField(
                        controller: _productController,
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF2D3748),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Product (e.g., Soda 500ml)',
                          labelStyle: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF2D3748) : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Price Field
                      TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF2D3748),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Price (Ksh)',
                          labelStyle: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF2D3748) : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Payment Method Selection
                      Text(
                        'Payment Method',
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF2D3748),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedPaymentMethod = PaymentMethod.cash),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _selectedPaymentMethod == PaymentMethod.cash
                                      ? const Color(0xFF667EEA)
                                      : (isDark ? const Color(0xFF2D3748) : Colors.grey[200]),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.money,
                                      color: _selectedPaymentMethod == PaymentMethod.cash
                                          ? Colors.white
                                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Cash',
                                      style: TextStyle(
                                        color: _selectedPaymentMethod == PaymentMethod.cash
                                            ? Colors.white
                                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedPaymentMethod = PaymentMethod.mpesa),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _selectedPaymentMethod == PaymentMethod.mpesa
                                      ? const Color(0xFF00C851)
                                      : (isDark ? const Color(0xFF2D3748) : Colors.grey[200]),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.phone_android,
                                      color: _selectedPaymentMethod == PaymentMethod.mpesa
                                          ? Colors.white
                                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'M-Pesa',
                                      style: TextStyle(
                                        color: _selectedPaymentMethod == PaymentMethod.mpesa
                                            ? Colors.white
                                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Add Sale Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _addSale,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667EEA),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Add Sale',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Recent Sales with View All option
                if (salesProvider.todaySales.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Sales',
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF2D3748),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AllSalesScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF667EEA).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'View All',
                            style: TextStyle(
                              color: const Color(0xFF667EEA),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...salesProvider.todaySales.reversed.take(3).map((sale) =>
                      Dismissible(
                        key: Key(sale.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) async {
                          await salesProvider.deleteSale(sale.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${sale.productName} deleted')),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: sale.paymentMethod == PaymentMethod.mpesa
                                      ? const Color(0xFF00C851).withOpacity(0.1)
                                      : const Color(0xFF667EEA).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  sale.paymentMethod == PaymentMethod.mpesa
                                      ? Icons.phone_android
                                      : Icons.money,
                                  color: sale.paymentMethod == PaymentMethod.mpesa
                                      ? const Color(0xFF00C851)
                                      : const Color(0xFF667EEA),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sale.productName,
                                      style: TextStyle(
                                        color: isDark ? Colors.white : const Color(0xFF2D3748),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '${sale.dateTime.hour.toString().padLeft(2, '0')}:${sale.dateTime.minute.toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Ksh ${sale.price.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: isDark ? Colors.white : const Color(0xFF2D3748),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ).toList(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _addSale() async { // Add async here
    if (_productController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all fields'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final price = double.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid price'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final sale = Sale(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productName: _productController.text,
      price: price,
      dateTime: DateTime.now(),
      paymentMethod: _selectedPaymentMethod,
    );

    try {
      await Provider.of<SalesProvider>(context, listen: false).addSale(sale); // Add await here

      _productController.clear();
      _priceController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sale added successfully!'),
          backgroundColor: Colors.green[400],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error adding sale. Please try again.'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _productController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}