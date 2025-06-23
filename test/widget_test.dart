// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_mate/main.dart';
import 'package:shop_mate/src/features/screens/sales/provider/sales_provider.dart';
import 'package:shop_mate/src/features/screens/stock/provider/stock_provider.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    final salesProvider = SalesProvider();
    final stockProvider = StockProvider();
    await salesProvider.initializeDatabase();
    await stockProvider.initializeDatabase();

    await tester.pumpWidget(MyApp(salesProvider: salesProvider, stockProvider: stockProvider,));


    expect(find.text('ShopMate'), findsWidgets);

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
