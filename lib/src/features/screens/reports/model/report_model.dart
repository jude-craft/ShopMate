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
}

class ChartData {
  final String label;
  final double value;

  ChartData({
    required this.label,
    required this.value,
  });
}

class TransactionModel {
  final String id;
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
      id: map['id']?.toString() ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: map['date']?.toString() ?? '',
      itemCount: (map['item_count'] as num?)?.toInt() ?? 1,
    );
  }
}

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
      id: (map['id'] as num?)?.toInt() ?? 0,
      name: map['name']?.toString() ?? '',
      unitsSold: (map['units_sold'] as num?)?.toInt() ?? 0,
      revenue: (map['revenue'] as num?)?.toDouble() ?? 0.0,
      profit: (map['profit'] as num?)?.toDouble() ?? 0.0,
    );
  }
}