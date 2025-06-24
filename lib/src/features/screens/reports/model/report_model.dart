// models/report_model.dart
class ReportSummary {
  final double totalSales;
  final double totalProfit;
  final int totalTransactions;
  final int totalItemsSold;
  final double salesTrend;
  final double profitTrend;

  ReportSummary({
    required this.totalSales,
    required this.totalProfit,
    required this.totalTransactions,
    required this.totalItemsSold,
    required this.salesTrend,
    required this.profitTrend,
  });

  factory ReportSummary.fromMap(Map<String, dynamic> map) {
    return ReportSummary(
      totalSales: (map['total_sales'] ?? 0.0).toDouble(),
      totalProfit: (map['total_profit'] ?? 0.0).toDouble(),
      totalTransactions: map['total_transactions'] ?? 0,
      totalItemsSold: map['total_items_sold'] ?? 0,
      salesTrend: (map['sales_trend'] ?? 0.0).toDouble(),
      profitTrend: (map['profit_trend'] ?? 0.0).toDouble(),
    );
  }
}

// models/transaction_model.dart
class TransactionModel {
  final int id;
  final double amount;
  final String date;
  final int itemCount;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.date,
    required this.itemCount,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      amount: (map['amount'] ?? 0.0).toDouble(),
      date: map['date'] ?? '',
      itemCount: map['item_count'] ?? 0,
    );
  }
}

// models/product_performance.dart
class ProductPerformance {
  final int id;
  final String name;
  final int unitsSold;
  final double revenue;
  final double profit;

  ProductPerformance({
    required this.id,
    required this.name,
    required this.unitsSold,
    required this.revenue,
    required this.profit,
  });

  factory ProductPerformance.fromMap(Map<String, dynamic> map) {
    return ProductPerformance(
      id: map['id'],
      name: map['name'] ?? '',
      unitsSold: map['units_sold'] ?? 0,
      revenue: (map['revenue'] ?? 0.0).toDouble(),
      profit: (map['profit'] ?? 0.0).toDouble(),
    );
  }
}

// models/chart_data.dart
class ChartData {
  final String label;
  final double value;

  ChartData({
    required this.label,
    required this.value,
  });

  factory ChartData.fromMap(Map<String, dynamic> map) {
    return ChartData(
      label: map['label'] ?? '',
      value: (map['value'] ?? 0.0).toDouble(),
    );
  }
}