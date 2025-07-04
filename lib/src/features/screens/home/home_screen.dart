import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_mate/src/features/screens/sales/provider/sales_provider.dart';
import 'package:shop_mate/src/features/screens/sales/screen/all_sales_screen.dart';
import 'package:shop_mate/src/features/screens/stock/provider/stock_provider.dart';

import '../../navigation/main_navigation.dart';
import '../../widgets/quick_actions.dart';
import '../../widgets/low_stock_alert.dart';
import '../../widgets/recent_sales_list.dart';
import '../../widgets/starts_card.dart';
import 'service/greeting_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockProvider>().loadStocks();
    });
  }

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

  void _navigateToSales(BuildContext context) {
    final mainNavState = context.findAncestorStateOfType<MainNavigationState>();
    mainNavState?.navigateToTab(1);
  }
  void _navigateToStocks(BuildContext context) {
    final mainNavState = context.findAncestorStateOfType<MainNavigationState>();
    mainNavState?.navigateToTab(2);
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
      body: Consumer2<SalesProvider, StockProvider>(
        builder: (context, salesProvider, stockProvider, child) {
          return RefreshIndicator(
            onRefresh: () async {
              await stockProvider.loadStocks();
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
                          value: 'KSh ${salesProvider.totalSalesToday.toStringAsFixed(0)}',
                          icon: Icons.attach_money,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatsCard(
                          title: 'Products',
                          value: '${stockProvider.stocks.length}',
                          icon: Icons.inventory_2,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: 'Low Stock',
                          value: '${stockProvider.lowStockCount}',
                          icon: Icons.warning,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatsCard(
                          title: 'Out of Stock',
                          value: '${stockProvider.outOfStockCount}',
                          icon: Icons.error,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Low Stock Alert
                  LowStockAlert(
                    stocks: stockProvider.lowStockItems,
                  ),

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
                            _navigateToSales(context);
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
                            _navigateToStocks(context);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Sales',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AllSalesScreen(),
                                ),
                              );
                            },
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      RecentSalesList(sales: salesProvider.todaySales.take(3).toList()),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}