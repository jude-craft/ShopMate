import 'package:flutter/material.dart';
import '../../../backend/sales/sales_db.dart';
import '../models/sale_model.dart';

class SalesProvider extends ChangeNotifier {
  List<Sale> _sales = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Sale> get sales => _sales;

  // Initialize and load sales from database
  Future<void> initializeDatabase() async {
    await loadSalesFromDatabase();
  }

  // Load all sales from database
  Future<void> loadSalesFromDatabase() async {
    try {
      final salesData = await _dbHelper.getAllSales();
      _sales = salesData.map((map) => Sale.fromMap(map)).toList();
      // Sort sales by date (newest first)
      _sales.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      notifyListeners();
    } catch (e) {
      print('Error loading sales: $e');
    }
  }

  // Add sale to both local list and database
  Future<void> addSale(Sale sale) async {
    try {
      await _dbHelper.insertSale(sale.toMap());
      _sales.insert(0, sale);
      notifyListeners();
    } catch (e) {
      print('Error adding sale: $e');
      throw e;
    }
  }

  // Delete sale from both local list and database
  Future<void> deleteSale(String saleId) async {
    try {
      await _dbHelper.deleteSale(saleId);
      _sales.removeWhere((sale) => sale.id == saleId);
      notifyListeners();
    } catch (e) {
      print('Error deleting sale: $e');
      throw e;
    }
  }

  // Get sales for a specific date
  List<Sale> getSalesForDate(DateTime date) {
    return _sales.where((sale) =>
    sale.dateTime.day == date.day &&
        sale.dateTime.month == date.month &&
        sale.dateTime.year == date.year).toList();
  }

  // Get sales for a specific month
  List<Sale> getSalesForMonth(DateTime date) {
    return _sales.where((sale) =>
    sale.dateTime.month == date.month &&
        sale.dateTime.year == date.year).toList();
  }

  // Get sales for a specific year
  List<Sale> getSalesForYear(DateTime date) {
    return _sales.where((sale) =>
    sale.dateTime.year == date.year).toList();
  }

  // Get sales between two dates
  List<Sale> getSalesBetweenDates(DateTime startDate, DateTime endDate) {
    return _sales.where((sale) =>
    sale.dateTime.isAfter(startDate.subtract(const Duration(days: 1))) &&
        sale.dateTime.isBefore(endDate.add(const Duration(days: 1)))).toList();
  }

  // Get total sales for a specific date
  double getTotalSalesForDate(DateTime date) {
    return getSalesForDate(date)
        .fold(0.0, (sum, sale) => sum + sale.price);
  }

  // Get total sales for a specific month
  double getTotalSalesForMonth(DateTime date) {
    return getSalesForMonth(date)
        .fold(0.0, (sum, sale) => sum + sale.price);
  }

  // Get total sales for a specific year
  double getTotalSalesForYear(DateTime date) {
    return getSalesForYear(date)
        .fold(0.0, (sum, sale) => sum + sale.price);
  }

  // Get M-Pesa sales for a specific date
  double getMpesaSalesForDate(DateTime date) {
    return getSalesForDate(date)
        .where((sale) => sale.paymentMethod == PaymentMethod.mpesa)
        .fold(0.0, (sum, sale) => sum + sale.price);
  }

  // Get Cash sales for a specific date
  double getCashSalesForDate(DateTime date) {
    return getSalesForDate(date)
        .where((sale) => sale.paymentMethod == PaymentMethod.cash)
        .fold(0.0, (sum, sale) => sum + sale.price);
  }

  // Get M-Pesa sales for a specific month
  double getMpesaSalesForMonth(DateTime date) {
    return getSalesForMonth(date)
        .where((sale) => sale.paymentMethod == PaymentMethod.mpesa)
        .fold(0.0, (sum, sale) => sum + sale.price);
  }

  // Get Cash sales for a specific month
  double getCashSalesForMonth(DateTime date) {
    return getSalesForMonth(date)
        .where((sale) => sale.paymentMethod == PaymentMethod.cash)
        .fold(0.0, (sum, sale) => sum + sale.price);
  }

  // Get daily sales breakdown for a month
  Map<int, double> getDailySalesBreakdown(DateTime month) {
    Map<int, double> dailySales = {};
    final monthSales = getSalesForMonth(month);

    for (var sale in monthSales) {
      final day = sale.dateTime.day;
      dailySales[day] = (dailySales[day] ?? 0) + sale.price;
    }

    return dailySales;
  }

  // Get top selling products for a specific period
  Map<String, double> getTopProductsForPeriod(List<Sale> sales) {
    Map<String, double> productTotals = {};

    for (var sale in sales) {
      productTotals[sale.productName] =
          (productTotals[sale.productName] ?? 0) + sale.price;
    }

    // Sort by total sales descending
    var sortedEntries = productTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries);
  }

  // Get sales count for a specific date
  int getSalesCountForDate(DateTime date) {
    return getSalesForDate(date).length;
  }

  // Get sales count for a specific month
  int getSalesCountForMonth(DateTime date) {
    return getSalesForMonth(date).length;
  }

  // Get average sale amount for a specific period
  double getAverageSaleAmount(List<Sale> sales) {
    if (sales.isEmpty) return 0.0;
    final total = sales.fold(0.0, (sum, sale) => sum + sale.price);
    return total / sales.length;
  }

  // Get payment method breakdown for a specific period
  Map<PaymentMethod, double> getPaymentMethodBreakdown(List<Sale> sales) {
    Map<PaymentMethod, double> breakdown = {
      PaymentMethod.mpesa: 0.0,
      PaymentMethod.cash: 0.0,
    };

    for (var sale in sales) {
      breakdown[sale.paymentMethod] =
          (breakdown[sale.paymentMethod] ?? 0) + sale.price;
    }

    return breakdown;
  }

  // Get weekly sales data (last 7 days from given date)
  List<Map<String, dynamic>> getWeeklySalesData(DateTime endDate) {
    List<Map<String, dynamic>> weeklyData = [];

    for (int i = 6; i >= 0; i--) {
      final date = endDate.subtract(Duration(days: i));
      final dailySales = getSalesForDate(date);
      final total = dailySales.fold(0.0, (sum, sale) => sum + sale.price);

      weeklyData.add({
        'date': date,
        'total': total,
        'count': dailySales.length,
        'day': _getDayName(date.weekday),
      });
    }

    return weeklyData;
  }

  // Get monthly sales data (last 12 months from given date)
  List<Map<String, dynamic>> getYearlySalesData(DateTime endDate) {
    List<Map<String, dynamic>> yearlyData = [];

    for (int i = 11; i >= 0; i--) {
      final month = DateTime(endDate.year, endDate.month - i, 1);
      final monthlySales = getSalesForMonth(month);
      final total = monthlySales.fold(0.0, (sum, sale) => sum + sale.price);

      yearlyData.add({
        'month': month,
        'total': total,
        'count': monthlySales.length,
        'monthName': _getMonthName(month.month),
      });
    }

    return yearlyData;
  }

  // Helper method to get day name
  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  // Helper method to get month name
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  // Get sales growth percentage between two periods
  double getSalesGrowthPercentage(List<Sale> currentPeriod, List<Sale> previousPeriod) {
    final currentTotal = currentPeriod.fold(0.0, (sum, sale) => sum + sale.price);
    final previousTotal = previousPeriod.fold(0.0, (sum, sale) => sum + sale.price);

    if (previousTotal == 0) return currentTotal > 0 ? 100.0 : 0.0;

    return ((currentTotal - previousTotal) / previousTotal) * 100;
  }

  // Get busiest hour of the day for a specific date
  Map<String, dynamic> getBusiestHour(DateTime date) {
    final dailySales = getSalesForDate(date);
    Map<int, double> hourlyTotals = {};

    for (var sale in dailySales) {
      final hour = sale.dateTime.hour;
      hourlyTotals[hour] = (hourlyTotals[hour] ?? 0) + sale.price;
    }

    if (hourlyTotals.isEmpty) {
      return {'hour': 0, 'total': 0.0, 'count': 0};
    }

    final busiestHour = hourlyTotals.entries
        .reduce((a, b) => a.value > b.value ? a : b);

    final count = dailySales
        .where((sale) => sale.dateTime.hour == busiestHour.key)
        .length;

    return {
      'hour': busiestHour.key,
      'total': busiestHour.value,
      'count': count,
    };
  }

  double get totalSalesToday {
    final today = DateTime.now();
    return getTotalSalesForDate(today);
  }

  double get mpesaSalesToday {
    final today = DateTime.now();
    return getMpesaSalesForDate(today);
  }

  double get cashSalesToday {
    final today = DateTime.now();
    return getCashSalesForDate(today);
  }

  List<Sale> get todaySales {
    final today = DateTime.now();
    return getSalesForDate(today);
  }

  Map<String, double> get productTotals {
    return getTopProductsForPeriod(_sales);
  }
}