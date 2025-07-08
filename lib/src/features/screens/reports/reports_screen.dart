import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';
import 'provider/reports_provider.dart';
import '../sales/provider/sales_provider.dart';
import '../stock/provider/stock_provider.dart';
import 'widgets/report_card.dart';
import 'widgets/report_chart.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedPeriod = 'Today';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportProvider = context.read<ReportProvider>();
      final salesProvider = context.read<SalesProvider>();
      final stockProvider = context.read<StockProvider>();
      reportProvider.setProviders(sales: salesProvider, stock: stockProvider);
      reportProvider.loadReports();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Reports',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black54,
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.date_range,
              color: isDark ? Colors.white : Colors.black54,
            ),
            onSelected: (value) {
              setState(() {
                selectedPeriod = value;
              });
              final reportProvider = context.read<ReportProvider>();
              reportProvider.filterByPeriod(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Today', child: Text('Today')),
              const PopupMenuItem(value: 'Week', child: Text('This Week')),
              const PopupMenuItem(value: 'Month', child: Text('This Month')),
              const PopupMenuItem(value: 'Year', child: Text('This Year')),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  width: 0.5,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: isDark ? Colors.white : theme.primaryColor,
              unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Products'),
              ],
            ),
          ),
        ),
      ),
      body: Consumer<ReportProvider>(
        builder: (context, reportProvider, child) {
          if (reportProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.primaryColor,
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(context, reportProvider),
              _buildProductsTab(context, reportProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, ReportProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.loadReports(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodHeader(),
            const SizedBox(height: 16),
            _buildMetricsRow(provider),
            const SizedBox(height: 24),
            _buildSalesChart(provider),
            const SizedBox(height: 24),
            _buildQuickStats(provider),
            const SizedBox(height: 24),
            _buildExtraOverviewStats(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsTab(BuildContext context, ReportProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.loadReports(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTopProductsChart(provider),
            const SizedBox(height: 16),
            _buildProductPerformanceList(provider),
            const SizedBox(height: 16),
            _buildProductExtraStats(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodHeader() {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
            theme.primaryColor.withOpacity(0.2),
            theme.primaryColor.withOpacity(0.1),
          ]
              : [
            theme.primaryColor.withOpacity(0.1),
            theme.primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : theme.primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            color: isDark ? Colors.white : theme.primaryColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            selectedPeriod,
            style: TextStyle(
              color: isDark ? Colors.white : theme.primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow(ReportProvider provider) {
    return Row(
      children: [
        Expanded(
          child: ReportCard(
            title: 'Total Sales',
            value: '\Ksh ${provider.totalSales.toStringAsFixed(2)}',
            icon: Icons.money,
            color: Colors.green,
            trend: provider.salesTrend,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ReportCard(
            title: 'Profit',
            value: '\Ksh ${provider.totalProfit.toStringAsFixed(2)}',
            icon: Icons.trending_up,
            color: Colors.blue,
            trend: provider.profitTrend,
          ),
        ),
      ],
    );
  }

  Widget _buildSalesChart(ReportProvider provider, {bool showDetailed = false}) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Container(
      height: showDetailed ? 300 : 200,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.6)
                : Colors.black.withOpacity(0.12),
            blurRadius: isDark ? 20 : 15,
            offset: const Offset(0, 6),
            spreadRadius: isDark ? 3 : 1,
          ),
          if (isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
        ],
      ),
      child: ChartWidget(
        data: provider.salesChartData,
        title: 'Sales Trend',
        showDetailed: showDetailed,
      ),
    );
  }

  Widget _buildTopProductsChart(ReportProvider provider) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.6)
                : Colors.black.withOpacity(0.12),
            blurRadius: isDark ? 20 : 15,
            offset: const Offset(0, 6),
            spreadRadius: isDark ? 3 : 1,
          ),
          if (isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
        ],
      ),
      child: ChartWidget(
        data: provider.topProductsData,
        title: 'Top Products',
        chartType: ChartType.bar,
      ),
    );
  }

  Widget _buildQuickStats(ReportProvider provider) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Stats',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Items Sold',
                provider.totalItemsSold.toString(),
                Icons.shopping_cart,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Transactions',
                provider.totalTransactions.toString(),
                Icons.receipt,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.6)
                : Colors.black.withOpacity(0.12),
            blurRadius: isDark ? 20 : 15,
            offset: const Offset(0, 6),
            spreadRadius: isDark ? 3 : 1,
          ),
          if (isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductPerformanceList(ReportProvider provider) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.6)
                : Colors.black.withOpacity(0.12),
            blurRadius: isDark ? 20 : 15,
            offset: const Offset(0, 6),
            spreadRadius: isDark ? 3 : 1,
          ),
          if (isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.trending_up,
                    color: theme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Product Performance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.topProducts.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: 72,
              color: isDark ? Colors.grey[800] : Colors.grey[200],
            ),
            itemBuilder: (context, index) {
              final product = provider.topProducts[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.primaryColor,
                        theme.primaryColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  product.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  '${product.unitsSold} units sold',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.grey[800]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Ksh${product.revenue.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildExtraOverviewStats(ReportProvider provider) {
    final bestDay = provider.salesChartData.isNotEmpty
        ? provider.salesChartData.reduce((a, b) => a.value > b.value ? a : b)
        : null;
    final avgSale = provider.totalTransactions > 0
        ? (provider.totalSales / provider.totalTransactions)
        : 0.0;
    final mostProfitable = provider.topProducts.isNotEmpty
        ? provider.topProducts.reduce((a, b) => a.profit > b.profit ? a : b)
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (bestDay != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('Best ${selectedPeriod == 'Today' ? 'Hour' : selectedPeriod}: ${bestDay.label} (${bestDay.value.toStringAsFixed(2)})',
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        Text('Average Sale Value: ${avgSale.toStringAsFixed(2)}'),
        if (mostProfitable != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Most Profitable Product: ${mostProfitable.name} (${mostProfitable.profit.toStringAsFixed(2)})'),
          ),
      ],
    );
  }

  Widget _buildSalesExtraStats(ReportProvider provider) {
    final lowStockTopSellers = provider.topProducts
        .where((p) => p.unitsSold > 0 && p.unitsSold >= 5 && p.profit > 0 && p.revenue > 0)
        .take(3)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (lowStockTopSellers.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('Top Sellers (Check Stock!): ' +
                lowStockTopSellers.map((p) => p.name).join(', '),
                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
          ),
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Export feature coming soon!')),
            );
          },
          icon: const Icon(Icons.file_download),
          label: const Text('Export Report'),
        ),
      ],
    );
  }

  Widget _buildProductExtraStats(ReportProvider provider) {
    final mostSold = provider.topProducts.isNotEmpty
        ? provider.topProducts.first
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mostSold != null)
          Text('Most Sold Product: ${mostSold.name} (${mostSold.unitsSold} units)'),
      ],
    );
  }
}