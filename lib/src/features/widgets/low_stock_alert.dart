import 'package:flutter/material.dart';
import '../models/product.dart';

class LowStockAlert extends StatelessWidget {
  final List<Product> products;

  const LowStockAlert({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.orange[700],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Low Stock Alert',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${products.length} item${products.length > 1 ? 's' : ''} running low:',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            ...products.take(3).map((product) => Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '• ${product.name} (${product.stock} left)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )),
            if (products.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '... and ${products.length - 3} more',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}