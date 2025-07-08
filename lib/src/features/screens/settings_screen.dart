import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/shop_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../screens/sales/provider/sales_provider.dart';
import '../screens/stock/provider/stock_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Load settings when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SettingsSection(
                  title: 'Appearance',
                  children: [
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        IconData icon;
                        switch (themeProvider.themeMode) {
                          case ThemeMode.light:
                            icon = Icons.light_mode;
                            break;
                          case ThemeMode.dark:
                            icon = Icons.dark_mode;
                            break;
                          case ThemeMode.system:
                            icon = Icons.brightness_auto;
                            break;
                        }

                        return SettingsTile(
                          icon: icon,
                          title: 'Theme',
                          subtitle: themeProvider.themeModeLabel,
                          trailing: Switch(
                            value: themeProvider.isDarkMode,
                            onChanged: (value) {
                              themeProvider.toggleTheme();
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Shop Settings Section
                SettingsSection(
                  title: 'Shop Settings',
                  children: [
                    SettingsTile(
                      icon: Icons.store,
                      title: 'Shop Information',
                      subtitle: settingsProvider.shopName.isNotEmpty 
                          ? settingsProvider.shopName 
                          : 'Name, address, and contact details',
                      onTap: () => _showShopInfoDialog(context, settingsProvider),
                    ),
                    SettingsTile(
                      icon: Icons.attach_money,
                      title: 'Currency Format',
                      subtitle: settingsProvider.getCurrencyDisplayText(),
                      onTap: () => _showCurrencyDialog(context, settingsProvider),
                    ),
                    SettingsTile(
                      icon: Icons.warning,
                      title: 'Low Stock Alert',
                      subtitle: settingsProvider.getLowStockDisplayText(),
                      onTap: () => _showLowStockDialog(context, settingsProvider),
                    ),
                    SettingsTile(
                      icon: Icons.percent,
                      title: 'Tax Configuration',
                      subtitle: settingsProvider.getTaxDisplayText(),
                      onTap: () => _showTaxDialog(context, settingsProvider),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Data Management Section
                SettingsSection(
                  title: 'Data Management',
                  children: [
                    SettingsTile(
                      icon: Icons.backup,
                      title: 'Backup Data',
                      subtitle: 'Export your shop data',
                      onTap: () => _showBackupDialog(context),
                    ),
                    SettingsTile(
                      icon: Icons.delete_sweep,
                      title: 'Clear Old Sales',
                      subtitle: 'Remove sales older than 6 months',
                      onTap: () => _showClearSalesDialog(context),
                    ),
                    SettingsTile(
                      icon: Icons.refresh,
                      title: 'Reset App Data',
                      subtitle: 'Clear all data and start fresh',
                      onTap: () => _showResetDialog(context),
                      isDestructive: true,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Notifications Section
                SettingsSection(
                  title: 'Notifications',
                  children: [
                    SettingsTile(
                      icon: Icons.notifications,
                      title: 'Low Stock Alerts',
                      subtitle: 'Get notified when items are running low',
                      trailing: Switch(
                        value: settingsProvider.lowStockAlertsEnabled,
                        onChanged: (value) {
                          settingsProvider.toggleLowStockAlerts(value);
                        },
                      ),
                    ),
                    SettingsTile(
                      icon: Icons.schedule,
                      title: 'Daily Summary',
                      subtitle: 'End of day sales summary',
                      trailing: Switch(
                        value: settingsProvider.dailySummaryEnabled,
                        onChanged: (value) {
                          settingsProvider.toggleDailySummary(value);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // About Section
                SettingsSection(
                  title: 'About',
                  children: [
                    SettingsTile(
                      icon: Icons.info,
                      title: 'App Version',
                      subtitle: '1.0.0',
                      onTap: () => _showAboutDialog(context),
                    ),
                    SettingsTile(
                      icon: Icons.help,
                      title: 'Help & Support',
                      subtitle: 'Get help using the app',
                      onTap: () => _showHelpDialog(context),
                    ),
                    SettingsTile(
                      icon: Icons.contact_support,
                      title: 'Contact Developer',
                      subtitle: 'Report bugs or suggest features',
                      onTap: () => _showContactDialog(context),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showShopInfoDialog(BuildContext context, SettingsProvider settingsProvider) {
    final nameController = TextEditingController(text: settingsProvider.shopName);
    final addressController = TextEditingController(text: settingsProvider.shopAddress);
    final phoneController = TextEditingController(text: settingsProvider.shopPhone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Shop Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Shop Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await settingsProvider.updateShopInfo(
                name: nameController.text.trim(),
                address: addressController.text.trim(),
                phone: phoneController.text.trim(),
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Shop information updated!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, SettingsProvider settingsProvider) {
    String selectedCurrency = settingsProvider.currency;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Currency Format'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('KSh - Kenyan Shilling'),
                value: 'KSh',
                groupValue: selectedCurrency,
                onChanged: (value) {
                  setState(() {
                    selectedCurrency = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('USD - US Dollar'),
                value: 'USD',
                groupValue: selectedCurrency,
                onChanged: (value) {
                  setState(() {
                    selectedCurrency = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('EUR - Euro'),
                value: 'EUR',
                groupValue: selectedCurrency,
                onChanged: (value) {
                  setState(() {
                    selectedCurrency = value!;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await settingsProvider.updateCurrency(selectedCurrency);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Currency updated to $selectedCurrency!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLowStockDialog(BuildContext context, SettingsProvider settingsProvider) {
    final thresholdController = TextEditingController(
      text: settingsProvider.lowStockThreshold.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Low Stock Alert Threshold'),
        content: TextField(
          controller: thresholdController,
          decoration: const InputDecoration(
            labelText: 'Alert when stock is below',
            suffixText: 'items',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final threshold = int.tryParse(thresholdController.text);
              if (threshold != null && threshold > 0) {
                await settingsProvider.updateLowStockThreshold(threshold);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Low stock threshold updated to $threshold!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid number!')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showTaxDialog(BuildContext context, SettingsProvider settingsProvider) {
    final taxRateController = TextEditingController(
      text: settingsProvider.taxRate.toString(),
    );
    bool includeTaxInPrices = settingsProvider.includeTaxInPrices;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tax Configuration'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taxRateController,
                decoration: const InputDecoration(
                  labelText: 'Tax Rate',
                  suffixText: '%',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Include tax in product prices'),
                value: includeTaxInPrices,
                onChanged: (value) {
                  setState(() {
                    includeTaxInPrices = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final taxRate = double.tryParse(taxRateController.text);
                if (taxRate != null && taxRate >= 0) {
                  await settingsProvider.updateTaxRate(taxRate);
                  await settingsProvider.toggleIncludeTaxInPrices(includeTaxInPrices);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tax rate updated to ${taxRate.toStringAsFixed(1)}%!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid tax rate!')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Data'),
        content: const Text(
            'Export your shop data to a file that you can save or share.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Data backup feature coming soon!')),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showClearSalesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Old Sales'),
        content: const Text(
            'This will permanently delete sales records older than 6 months. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                // Get the sales provider and clear old sales
                final salesProvider = context.read<SalesProvider>();
                final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
                
                // Get old sales
                final oldSales = salesProvider.sales.where(
                  (sale) => sale.dateTime.isBefore(sixMonthsAgo)
                ).toList();
                
                // Delete old sales
                for (final sale in oldSales) {
                  await salesProvider.deleteSale(sale.id);
                }
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${oldSales.length} old sales cleared successfully!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error clearing old sales!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset App Data'),
        content: const Text(
            'This will permanently delete ALL your data including products, sales, and settings. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                // Reset shop provider data
                context.read<ShopProvider>().initializeSampleData();
                
                // Clear sales data
                final salesProvider = context.read<SalesProvider>();
                for (final sale in salesProvider.sales) {
                  await salesProvider.deleteSale(sale.id);
                }
                
                // Clear stock data
                final stockProvider = context.read<StockProvider>();
                await stockProvider.loadStocks();
                for (final stock in stockProvider.stocks) {
                  await stockProvider.deleteStock(stock.id!);
                }
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('App data has been reset!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error resetting app data!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Shop Manager',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.store, size: 64),
      children: [
        const Text(
            'A simple and powerful inventory management app for local shops.'),
        const SizedBox(height: 16),
        const Text('Built with Flutter and designed for ease of use.'),
      ],
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Getting Started:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Add products in the Stock tab'),
              Text('• Record sales in the Sell tab'),
              Text('• View reports in the Reports tab'),
              SizedBox(height: 16),
              Text('Features:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Track inventory and low stock'),
              Text('• Record daily sales'),
              Text('• Generate sales reports'),
              Text('• Backup and restore data'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Developer'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.email),
              title: Text('Email'),
              subtitle: Text('developer@shopmate.com'),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('WhatsApp'),
              subtitle: Text('+254 123 456 789'),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}