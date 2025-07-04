import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_mate/src/features/screens/sales/provider/sales_provider.dart';

import '../../providers/theme_provider.dart';
import '../../screens/stock/provider/stock_provider.dart';
import 'models/sale_model.dart';
import 'screen/all_sales_screen.dart';

class SalesScreen extends StatefulWidget {
  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
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
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF2D3748),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Product Name Field
                      TextField(
                        controller: _productController,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF2D3748),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Product (e.g., Soda 500ml)',
                          labelStyle: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF2D3748)
                              : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF667EEA),
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Stock Information Display
                      Consumer<StockProvider>(
                        builder: (context, stockProvider, child) {
                          final stock = stockProvider.getStockByName(_productController.text);
                          if (stock != null) {
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF2D3748) : Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: stock.isLowStock ? Colors.orange : Colors.blue,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 16,
                                        color: stock.isLowStock ? Colors.orange : Colors.blue,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Stock Information',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: stock.isLowStock ? Colors.orange : Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Available: ${stock.remainingStock} ${stock.unit}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark ? Colors.white70 : Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Profit/Unit: \$${stock.profitPerUnit.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark ? Colors.white70 : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (stock.isLowStock)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '⚠️ Low stock alert!',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      const SizedBox(height: 16),

                      // Price Field
                      TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF2D3748),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Price (Ksh)',
                          labelStyle: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF2D3748)
                              : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF667EEA),
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF2D3748),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          labelStyle: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF2D3748)
                              : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF667EEA),
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Payment Method Selection
                      Text(
                        'Payment Method',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF2D3748),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(
                                () =>
                                    _selectedPaymentMethod = PaymentMethod.cash,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      _selectedPaymentMethod ==
                                          PaymentMethod.cash
                                      ? const Color(0xFF667EEA)
                                      : (isDark
                                            ? const Color(0xFF2D3748)
                                            : Colors.grey[200]),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.money,
                                      color:
                                          _selectedPaymentMethod ==
                                              PaymentMethod.cash
                                          ? Colors.white
                                          : (isDark
                                                ? Colors.grey[400]
                                                : Colors.grey[600]),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Cash',
                                      style: TextStyle(
                                        color:
                                            _selectedPaymentMethod ==
                                                PaymentMethod.cash
                                            ? Colors.white
                                            : (isDark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600]),
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
                              onTap: () => setState(
                                () => _selectedPaymentMethod =
                                    PaymentMethod.mpesa,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      _selectedPaymentMethod ==
                                          PaymentMethod.mpesa
                                      ? const Color(0xFF00C851)
                                      : (isDark
                                            ? const Color(0xFF2D3748)
                                            : Colors.grey[200]),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.phone_android,
                                      color:
                                          _selectedPaymentMethod ==
                                              PaymentMethod.mpesa
                                          ? Colors.white
                                          : (isDark
                                                ? Colors.grey[400]
                                                : Colors.grey[600]),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'M-Pesa',
                                      style: TextStyle(
                                        color:
                                            _selectedPaymentMethod ==
                                                PaymentMethod.mpesa
                                            ? Colors.white
                                            : (isDark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600]),
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

                if (salesProvider.todaySales.isNotEmpty) ...[
                  // Simple Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Recent Sales Text with Transaction Count
                      Row(
                        children: [
                          Text(
                            'Recent Sales',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF2D3748),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF667EEA).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${salesProvider.todaySales.length}',
                              style: TextStyle(
                                color: const Color(0xFF667EEA),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // View All Button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AllSalesScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
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

                  ...(salesProvider.todaySales
                        ..sort((a, b) => b.dateTime.compareTo(a.dateTime)))
                      .take(3)
                      .toList()
                      .asMap()
                      .entries
                      .map((entry) {
                        final index = entry.key;
                        final sale = entry.value;

                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Dismissible(
                            key: Key(sale.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF6B6B),
                                    Color(0xFFEE5A52),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onDismissed: (direction) async {
                              await salesProvider.deleteSale(sale.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${sale.productName} deleted successfully',
                                      ),
                                    ],
                                  ),
                                  backgroundColor: const Color(0xFF00C851),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E1E1E)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.grey[800]!
                                      : Colors.grey[200]!,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      isDark ? 0.3 : 0.08,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors:
                                            sale.paymentMethod ==
                                                PaymentMethod.mpesa
                                            ? [
                                                const Color(0xFF00C851),
                                                const Color(0xFF00A843),
                                              ]
                                            : [
                                                const Color(0xFF667EEA),
                                                const Color(0xFF764BA2),
                                              ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              (sale.paymentMethod ==
                                                          PaymentMethod.mpesa
                                                      ? const Color(0xFF00C851)
                                                      : const Color(0xFF667EEA))
                                                  .withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      sale.paymentMethod == PaymentMethod.mpesa
                                          ? Icons.phone_android
                                          : Icons.account_balance_wallet,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  // Product Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          sale.productName,
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF2D3748),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              size: 14,
                                              color: isDark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${sale.dateTime.hour.toString().padLeft(2, '0')}:${sale.dateTime.minute.toString().padLeft(2, '0')}',
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.grey[400]
                                                    : Colors.grey[600],
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    (sale.paymentMethod ==
                                                                PaymentMethod
                                                                    .mpesa
                                                            ? const Color(
                                                                0xFF00C851,
                                                              )
                                                            : const Color(
                                                                0xFF667EEA,
                                                              ))
                                                        .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                sale.paymentMethod ==
                                                        PaymentMethod.mpesa
                                                    ? 'M-PESA'
                                                    : 'CASH',
                                                style: TextStyle(
                                                  color:
                                                      sale.paymentMethod ==
                                                          PaymentMethod.mpesa
                                                      ? const Color(0xFF00C851)
                                                      : const Color(0xFF667EEA),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Ksh ${sale.price.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          color: const Color(0xFF00C851),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF00C851,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          'PAID',
                                          style: TextStyle(
                                            color: const Color(0xFF00C851),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      })
                      .toList(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _addSale() async {
    if (_productController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _quantityController.text.isEmpty) {
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
    final quantity = double.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid quantity'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Check stock availability
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    final stock = stockProvider.getStockByName(_productController.text);
    
    if (stock != null) {
      if (stock.remainingStock < quantity.toInt()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Insufficient stock! Available: ${stock.remainingStock}'),
            backgroundColor: Colors.orange[400],
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    } else {
      // Product not in stock - show warning but allow sale
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Product not found in stock. Sale will be recorded without stock tracking.'),
          backgroundColor: Colors.orange[400],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    final sale = Sale(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productName: _productController.text,
      price: price,
      quantity: quantity,
      dateTime: DateTime.now(),
      paymentMethod: _selectedPaymentMethod,
    );

    try {
      await Provider.of<SalesProvider>(context, listen: false).addSale(sale);

      _productController.clear();
      _priceController.clear();
      _quantityController.clear();

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
    _quantityController.dispose();
    super.dispose();
  }
}
