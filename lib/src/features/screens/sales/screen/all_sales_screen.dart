import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/sales.dart';
import '../../../providers/theme_provider.dart';
import '../models/sale_model.dart';
import '../provider/sales_provider.dart';
import '../sell_screen.dart';



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
              final sale = salesProvider.todaySales.reversed
                  .toList()[index];
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
                    SnackBar(
                      content: Text('${sale.productName} deleted'),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E1E1E)
                        : Colors.white,
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
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF2D3748),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              sale.quantity.toStringAsFixed(0),
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            'Ksh ${sale.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.green
                                  : Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${sale.dateTime.hour.toString().padLeft(2, '0')}:${sale.dateTime.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
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
