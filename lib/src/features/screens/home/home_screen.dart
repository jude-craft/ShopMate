import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/shop_provider.dart';
import '../../widgets/low_stock_alert.dart';
import '../../widgets/quick_actions.dart';
import '../../widgets/recent_sales_list.dart';
import '../../widgets/starts_card.dart';
import 'service/greeting_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildEnhancedGreeting(BuildContext context) {
    final greeting = GreetingService.getCoolGreeting();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(greeting.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  greeting.mainText,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            greeting.subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shop Manager',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<ShopProvider>(
        builder: (context, shopProvider, child) {
          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEnhancedGreeting(context),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: 'Today\'s Sales',
                          value:
                              'KSh ${shopProvider.todayRevenue.toStringAsFixed(0)}',
                          icon: Icons.attach_money,
                          color: Colors.green,
                          trend: '+12%',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatsCard(
                          title: 'Products',
                          value: '${shopProvider.totalProducts}',
                          icon: Icons.inventory_2,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Low Stock Alert
                  if (shopProvider.lowStockProducts.isNotEmpty)
                    LowStockAlert(products: shopProvider.lowStockProducts),

                  const SizedBox(height: 16),

                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: QuickActionCard(
                          title: 'New Sale',
                          icon: Icons.add_shopping_cart,
                          color: Colors.green,
                          onTap: () {
                            // Navigate to sell screen
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: QuickActionCard(
                          title: 'Add Product',
                          icon: Icons.add_box,
                          color: Colors.blue,
                          onTap: () {
                            // Navigate to add product
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recent Sales
                  Text(
                    'Recent Sales',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RecentSalesList(sales: shopProvider.todaySales),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
