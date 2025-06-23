import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/theme_provider.dart';
import '../model/stock_model.dart';


class StockCard extends StatelessWidget {
  final Stock stock;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const StockCard({
    Key? key,
    required this.stock,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        border: _getBorderColor(),
      ),
      child: InkWell(
        onTap: () => _showStockDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with product name and status
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stock.productName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stock.category,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(isDark),
                  PopupMenuButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: const [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: const [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Stock information
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Remaining',
                      '${stock.remainingStock} ${stock.unit}',
                      Icons.inventory,
                      _getQuantityColor(),
                      isDark,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Sold',
                      '${stock.soldQuantity} ${stock.unit}',
                      Icons.trending_up,
                      Colors.green,
                      isDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Price information
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Buy Price',
                      '\$${stock.buyingPrice.toStringAsFixed(2)}',
                      Icons.money,
                      Colors.orange,
                      isDark,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Sell Price',
                      '\$${stock.sellingPrice.toStringAsFixed(2)}',
                      Icons.money,
                      Colors.blue,
                      isDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Profit and progress bar
              Row(
                children: [
                  Text(
                    'Profit: \${stock.totalProfit.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: stock.totalProfit >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  const Spacer(),
                  if (stock.expiryDate != null)
                    Text(
                      'Exp: ${_formatDate(stock.expiryDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: stock.isExpired
                            ? Colors.red
                            : stock.isExpiringSoon
                            ? Colors.orange
                            : (isDark ? Colors.white70 : Colors.black54),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // Progress bar
              LinearProgressIndicator(
                value: stock.quantity > 0 ? stock.remainingStock / stock.quantity : 0,
                backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(_getQuantityColor()),
                minHeight: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isDark) {
    String status;
    Color color;

    if (stock.isOutOfStock) {
      status = 'Out of Stock';
      color = Colors.red;
    } else if (stock.isLowStock) {
      status = 'Low Stock';
      color = Colors.orange;
    } else if (stock.isExpired) {
      status = 'Expired';
      color = Colors.red;
    } else if (stock.isExpiringSoon) {
      status = 'Expiring Soon';
      color = Colors.orange;
    } else {
      status = 'In Stock';
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, Color color, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getQuantityColor() {
    if (stock.isOutOfStock) return Colors.red;
    if (stock.isLowStock) return Colors.orange;
    return Colors.green;
  }

  Border? _getBorderColor() {
    if (stock.isExpired) {
      return Border.all(color: Colors.red.withOpacity(0.3), width: 1);
    }
    if (stock.isExpiringSoon) {
      return Border.all(color: Colors.orange.withOpacity(0.3), width: 1);
    }
    return null;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showStockDetails(BuildContext context) {
    final isDark = context.read<ThemeProvider>().isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[800] : Colors.white,
        title: Text(
          stock.productName,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Category', stock.category, isDark),
              _buildDetailRow('Buying Price', '\${stock.buyingPrice.toStringAsFixed(2)}', isDark),
              _buildDetailRow('Selling Price', '\${stock.sellingPrice.toStringAsFixed(2)}', isDark),
              _buildDetailRow('Profit per Unit', '\${stock.profitPerUnit.toStringAsFixed(2)}', isDark),
              _buildDetailRow('Total Quantity', '${stock.quantity} ${stock.unit}', isDark),
              _buildDetailRow('Sold Quantity', '${stock.soldQuantity} ${stock.unit}', isDark),
              _buildDetailRow('Remaining', '${stock.remainingStock} ${stock.unit}', isDark),
              _buildDetailRow('Min Stock Level', '${stock.minStockLevel} ${stock.unit}', isDark),
              _buildDetailRow('Total Investment', '\${stock.totalInvestment.toStringAsFixed(2)}', isDark),
              _buildDetailRow('Total Profit', '\${stock.totalProfit.toStringAsFixed(2)}', isDark),
              _buildDetailRow('Date Added', _formatDate(stock.dateAdded), isDark),
              if (stock.expiryDate != null)
                _buildDetailRow('Expiry Date', _formatDate(stock.expiryDate!), isDark),
              if (stock.supplier != null && stock.supplier!.isNotEmpty)
                _buildDetailRow('Supplier', stock.supplier!, isDark),
              if (stock.description != null && stock.description!.isNotEmpty)
                _buildDetailRow('Description', stock.description!, isDark),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                color: isDark ? Colors.blue[300] : Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}