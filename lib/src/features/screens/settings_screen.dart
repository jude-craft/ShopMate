import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/shop_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
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
                  subtitle: 'Name, address, and contact details',
                  onTap: () => _showShopInfoDialog(context),
                ),
                SettingsTile(
                  icon: Icons.attach_money,
                  title: 'Currency Format',
                  subtitle: 'KSh (Kenyan Shilling)',
                  onTap: () => _showCurrencyDialog(context),
                ),
                SettingsTile(
                  icon: Icons.warning,
                  title: 'Low Stock Alert',
                  subtitle: 'Alert when stock is below 5 items',
                  onTap: () => _showLowStockDialog(context),
                ),
                SettingsTile(
                  icon: Icons.percent,
                  title: 'Tax Configuration',
                  subtitle: 'Set up tax rates for products',
                  onTap: () => _showTaxDialog(context),
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
                    value: true, // You can add this to your provider
                    onChanged: (value) {
                      // Handle notification toggle
                    },
                  ),
                ),
                SettingsTile(
                  icon: Icons.schedule,
                  title: 'Daily Summary',
                  subtitle: 'End of day sales summary',
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {
                      // Handle daily summary toggle
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
      ),
    );
  }

  void _showShopInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Shop Information'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Shop Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
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
                onPressed: () => Navigator.pop(context),
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showCurrencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Currency Format'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text('KSh - Kenyan Shilling'),
                  value: 'KSh',
                  groupValue: 'KSh',
                  onChanged: (value) {},
                ),
                RadioListTile<String>(
                  title: const Text('USD - US Dollar'),
                  value: 'USD',
                  groupValue: 'KSh',
                  onChanged: (value) {},
                ),
                RadioListTile<String>(
                  title: const Text('EUR - Euro'),
                  value: 'EUR',
                  groupValue: 'KSh',
                  onChanged: (value) {},
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showLowStockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Low Stock Alert Threshold'),
            content: const TextField(
              decoration: InputDecoration(
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
                onPressed: () => Navigator.pop(context),
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showTaxDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Tax Configuration'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Tax Rate',
                    suffixText: '%',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                CheckboxListTile(
                  title: Text('Include tax in product prices'),
                  value: false,
                  onChanged: null,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
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
      builder: (context) =>
          AlertDialog(
            title: const Text('Clear Old Sales'),
            content: const Text(
                'This will permanently delete sales records older than 6 months. This action cannot be undone.'),
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
                        content: Text('Old sales cleared successfully!')),
                  );
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
      builder: (context) =>
          AlertDialog(
            title: const Text('Reset App Data'),
            content: const Text(
                'This will permanently delete ALL your data including products, sales, and settings. This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<ShopProvider>().initializeSampleData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('App data has been reset!')),
                  );
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
      builder: (context) =>
          AlertDialog(
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
      builder: (context) =>
          AlertDialog(
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