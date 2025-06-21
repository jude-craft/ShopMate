import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_mate/src/features/providers/theme_provider.dart';
import 'package:shop_mate/src/features/screens/sales/provider/sales_provider.dart';
import 'package:shop_mate/src/features/screens/welcome/welcome_screen.dart';
import 'package:shop_mate/src/features/theme/app_theme.dart';

import 'src/features/providers/shop_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final salesProvider = SalesProvider();
  await salesProvider.initializeDatabase();

  runApp(MyApp(salesProvider: salesProvider));
}

class MyApp extends StatelessWidget {
  final SalesProvider salesProvider;

  const MyApp({super.key, required this.salesProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider.value(value: salesProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'ShopMate ',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: WelcomeScreen(),
          );
        },
      ),
    );
  }
}