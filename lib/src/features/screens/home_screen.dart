import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';
import '../widgets/low_stock_alert.dart';
import '../widgets/quick_actions.dart';
import '../widgets/recent_sales_list.dart';
import '../widgets/starts_card.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    int hour = DateTime.now().hour;

    if(hour<12){
      return 'Hello! Good Morning 🌄';
    } else if(hour<17){
      return 'Hello! Good Afternoon 🕑';
    } else{
      return 'Hello! Good Evening 🌆';
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(
              'Shop Manager',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

        ),

      body: Consumer<ShopProvider>(
        builder: (context, shopProvider, child) {
          return RefreshIndicator(
            onRefresh: () async {
              // Simulate refresh
              await Future.delayed(const Duration(seconds: 1));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height:20 ,),
                  // Stats Cards Row
                  Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: 'Today\'s Sales',
                          value: 'KSh ${shopProvider.todayRevenue.toStringAsFixed(0)}',
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