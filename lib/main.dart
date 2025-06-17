import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_mate/src/features/navigation/main_navigation.dart';
import 'package:shop_mate/src/features/providers/theme_provider.dart';
import 'package:shop_mate/src/features/theme/app_theme.dart';

import 'src/features/providers/shop_provider.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'ShopMate ',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home:  MainNavigation(),
          );
        },
      ),
    );
  }
}