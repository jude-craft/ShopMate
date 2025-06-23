import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';
import 'model/stock_model.dart';
import 'provider/stock_provider.dart';
import 'widgets/add_stock_dialog.dart';
import 'widgets/stock_card.dart';


class StockScreen extends StatefulWidget {
  const StockScreen({Key? key}) : super(key: key);

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  String _searchQuery = '';
  String _sortBy = 'name'; // name, quantity, date
  bool _showLowStock = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockProvider>().loadStocks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        title: Text(
          'Stock Management',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showLowStock ? Icons.warning : Icons.warning_outlined,
              color: _showLowStock ? Colors.orange : (isDark ? Colors.white70 : Colors.black54),
            ),
            onPressed: () {
              setState(() {
                _showLowStock = !_showLowStock;
              });
            },
            tooltip: 'Show Low Stock Items',
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.sort,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
              const PopupMenuItem(value: 'quantity', child: Text('Sort by Quantity')),
              const PopupMenuItem(value: 'date', child: Text('Sort by Date')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),

          // Stock Summary Cards
          Consumer<StockProvider>(
            builder: (context, stockProvider, child) {
              return Container(
                height: 100,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Total Products',
                        stockProvider.stocks.length.toString(),
                        Icons.inventory,
                        Colors.blue,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        'Low Stock',
                        stockProvider.lowStockCount.toString(),
                        Icons.warning,
                        Colors.orange,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        'Out of Stock',
                        stockProvider.outOfStockCount.toString(),
                        Icons.error,
                        Colors.red,
                        isDark,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Stock List
          Expanded(
            child: Consumer<StockProvider>(
              builder: (context, stockProvider, child) {
                if (stockProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<Stock> filteredStocks = stockProvider.getFilteredStocks(
                  searchQuery: _searchQuery,
                  sortBy: _sortBy,
                  showLowStock: _showLowStock,
                );

                if (filteredStocks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 80,
                          color: isDark ? Colors.white24 : Colors.black26,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _showLowStock ? 'No low stock items' : 'No products found',
                          style: TextStyle(
                            fontSize: 18,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredStocks.length,
                  itemBuilder: (context, index) {
                    return StockCard(
                      stock: filteredStocks[index],
                      onEdit: () => _showEditDialog(filteredStocks[index]),
                      onDelete: () => _showDeleteDialog(filteredStocks[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStockDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Stock'),
        backgroundColor: isDark ? Colors.blue[700] : Colors.blue,
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddStockDialog() {
    showDialog(
      context: context,
      builder: (context) => AddStockDialog(),
    );
  }

  void _showEditDialog(Stock stock) {
    showDialog(
      context: context,
      builder: (context) => AddStockDialog(stock: stock),
    );
  }

  void _showDeleteDialog(Stock stock) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Stock'),
        content: Text('Are you sure you want to delete "${stock.productName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<StockProvider>().deleteStock(stock.id!);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}