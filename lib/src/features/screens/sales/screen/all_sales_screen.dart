import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../providers/theme_provider.dart';
import '../models/sale_model.dart';
import '../provider/sales_provider.dart';

class AllSalesScreen extends StatefulWidget {
  @override
  _AllSalesScreenState createState() => _AllSalesScreenState();
}

class _AllSalesScreenState extends State<AllSalesScreen>
    with SingleTickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  late TabController _tabController;
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  List<Sale> _getSalesForDate(List<Sale> allSales, DateTime date) {
    return allSales.where((sale) =>
    sale.dateTime.day == date.day &&
        sale.dateTime.month == date.month &&
        sale.dateTime.year == date.year).toList();
  }

  List<Sale> _getSalesForMonth(List<Sale> allSales, DateTime date) {
    return allSales.where((sale) =>
    sale.dateTime.month == date.month &&
        sale.dateTime.year == date.year).toList();
  }

  double _getTotalForPeriod(List<Sale> sales) {
    return sales.fold(0.0, (sum, sale) => sum + sale.price);
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
        final isDark = themeProvider.isDarkMode;

        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF667EEA),
              onPrimary: Colors.white,
              surface: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              onSurface: isDark ? Colors.white : const Color(0xFF2D3748),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Widget _buildDateHeader(ThemeProvider themeProvider) {
    final isDark = themeProvider.isDarkMode;
    final isToday = DateUtils.isSameDay(selectedDate, DateTime.now());

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF667EEA),
            const Color(0xFF764BA2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isToday ? 'Today' : DateFormat('EEEE').format(selectedDate),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy').format(selectedDate),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    selectedDate = selectedDate.subtract(const Duration(days: 1));
                  });
                },
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = DateTime.now();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Go to Today',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: DateTime.now().isAfter(selectedDate)
                    ? () {
                  setState(() {
                    selectedDate = selectedDate.add(const Duration(days: 1));
                  });
                }
                    : null,
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(List<Sale> sales, ThemeProvider themeProvider) {
    final isDark = themeProvider.isDarkMode;
    final totalSales = _getTotalForPeriod(sales);
    final mpesaSales = sales
        .where((sale) => sale.paymentMethod == PaymentMethod.mpesa)
        .fold(0.0, (sum, sale) => sum + sale.price);
    final cashSales = sales
        .where((sale) => sale.paymentMethod == PaymentMethod.cash)
        .fold(0.0, (sum, sale) => sum + sale.price);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Sales',
              'Ksh ${totalSales.toStringAsFixed(0)}',
              Icons.trending_up,
              const Color(0xFF00C851),
              isDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'M-Pesa',
              'Ksh ${mpesaSales.toStringAsFixed(0)}',
              Icons.phone_android,
              const Color(0xFF00C851),
              isDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Cash',
              'Ksh ${cashSales.toStringAsFixed(0)}',
              Icons.money,
              const Color(0xFF667EEA),
              isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF2D3748),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesList(List<Sale> sales, ThemeProvider themeProvider) {
    final isDark = themeProvider.isDarkMode;

    if (sales.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No sales recorded',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sales will appear here once recorded',
              style: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Sort sales by date (newest first)
    final sortedSales = List<Sale>.from(sales)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: sales.length,
      itemBuilder: (context, index) {
        final sale = sortedSales[index];
        // Calculate the sale number (newest first gets highest number)
        final saleNumber = sales.length - index;

        return Dismissible(
          key: Key(sale.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outline, color: Colors.white, size: 24),
                SizedBox(height: 4),
                Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          onDismissed: (direction) async {
            final salesProvider = Provider.of<SalesProvider>(context, listen: false);
            await salesProvider.deleteSale(sale.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${sale.productName} deleted'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Added sale number circle
                Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA).withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF667EEA).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$saleNumber',
                      style: const TextStyle(
                        color: Color(0xFF667EEA),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: sale.paymentMethod == PaymentMethod.mpesa
                          ? [const Color(0xFF00C851), const Color(0xFF00C851).withOpacity(0.8)]
                          : [const Color(0xFF667EEA), const Color(0xFF764BA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    sale.paymentMethod == PaymentMethod.mpesa
                        ? Icons.phone_android
                        : Icons.payments_outlined,
                    color: Colors.white,
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
                          color: isDark ? Colors.white : const Color(0xFF2D3748),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (sale.paymentMethod == PaymentMethod.mpesa
                                  ? const Color(0xFF00C851)
                                  : const Color(0xFF667EEA)).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Qty: ${sale.quantity.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: sale.paymentMethod == PaymentMethod.mpesa
                                    ? const Color(0xFF00C851)
                                    : const Color(0xFF667EEA),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('HH:mm').format(sale.dateTime),
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
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
                      'Ksh ${sale.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFF00C851),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: (sale.paymentMethod == PaymentMethod.mpesa
                            ? const Color(0xFF00C851)
                            : const Color(0xFF667EEA)).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        sale.paymentMethod == PaymentMethod.mpesa ? 'M-Pesa' : 'Cash',
                        style: TextStyle(
                          color: sale.paymentMethod == PaymentMethod.mpesa
                              ? const Color(0xFF00C851)
                              : const Color(0xFF667EEA),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, SalesProvider>(
      builder: (context, themeProvider, salesProvider, child) {
        final isDark = themeProvider.isDarkMode;
        final dailySales = _getSalesForDate(salesProvider.sales, selectedDate);
        final monthlySales = _getSalesForMonth(salesProvider.sales, selectedDate);

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(
              'Sales History',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF2D3748),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: isDark ? Colors.white : const Color(0xFF2D3748),
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: 'Daily View'),
                    Tab(text: 'Monthly View'),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Daily View
              Column(
                children: [
                  _buildDateHeader(themeProvider),
                  _buildStatsCards(dailySales, themeProvider),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _buildSalesList(dailySales, themeProvider),
                  ),
                ],
              ),
              // Monthly View
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF667EEA).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Monthly Sales',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMMM yyyy').format(selectedDate),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: _selectDate,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.calendar_month,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatsCards(monthlySales, themeProvider),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _buildSalesList(monthlySales, themeProvider),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}