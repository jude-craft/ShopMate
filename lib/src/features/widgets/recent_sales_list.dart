import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop_mate/src/features/models/sales.dart';

import '../screens/sales/models/sale_model.dart';

class RecentSalesList extends StatelessWidget {
  final List<Sale> sales;

  const RecentSalesList({super.key, required this.sales});

  @override
  Widget build(BuildContext context) {
    if (sales.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                'No sales today yet',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sales will appear here once you start selling',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...sales
                .take(5)
                .map(
                  (sale) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.shopping_bag,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sale.productName,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Qty: ${sale.quantity.toStringAsFixed(0)}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    DateFormat('HH:mm').format(sale.dateTime),
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                      fontSize: 12,
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
                              'KSh ${sale.price.toStringAsFixed(0)}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                            ),
                            const SizedBox(height: 8,),
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
                ),
          ],
        ),
      ),
    );
  }
}
