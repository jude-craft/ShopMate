import 'package:flutter/material.dart';
import 'dart:convert';

class SettingsProvider with ChangeNotifier {
  // Shop Information
  String _shopName = 'My Shop';
  String _shopAddress = '';
  String _shopPhone = '';
  
  // Currency Settings
  String _currency = 'KSh';
  String _currencySymbol = 'KSh';
  
  // Low Stock Settings
  int _lowStockThreshold = 5;
  bool _lowStockAlertsEnabled = true;
  
  // Tax Settings
  double _taxRate = 16.0; // Default VAT rate
  bool _includeTaxInPrices = false;
  
  // Notification Settings
  bool _dailySummaryEnabled = false;
  
  // Getters
  String get shopName => _shopName;
  String get shopAddress => _shopAddress;
  String get shopPhone => _shopPhone;
  String get currency => _currency;
  String get currencySymbol => _currencySymbol;
  int get lowStockThreshold => _lowStockThreshold;
  bool get lowStockAlertsEnabled => _lowStockAlertsEnabled;
  double get taxRate => _taxRate;
  bool get includeTaxInPrices => _includeTaxInPrices;
  bool get dailySummaryEnabled => _dailySummaryEnabled;

  // Initialize settings (in-memory only)
  Future<void> loadSettings() async {
    // Settings are already initialized with default values
    notifyListeners();
  }

  // Save settings (in-memory only)
  Future<void> _saveSettings() async {
    // Just notify listeners since we're using in-memory storage
    notifyListeners();
  }

  // Shop Information Methods
  Future<void> updateShopInfo({
    required String name,
    required String address,
    required String phone,
  }) async {
    _shopName = name;
    _shopAddress = address;
    _shopPhone = phone;
    await _saveSettings();
  }

  // Currency Methods
  Future<void> updateCurrency(String currency) async {
    _currency = currency;
    _currencySymbol = _getCurrencySymbol(currency);
    await _saveSettings();
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'KSh':
        return 'KSh';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      default:
        return currency;
    }
  }

  // Low Stock Methods
  Future<void> updateLowStockThreshold(int threshold) async {
    _lowStockThreshold = threshold;
    await _saveSettings();
  }

  Future<void> toggleLowStockAlerts(bool enabled) async {
    _lowStockAlertsEnabled = enabled;
    await _saveSettings();
  }

  // Tax Methods
  Future<void> updateTaxRate(double rate) async {
    _taxRate = rate;
    await _saveSettings();
  }

  Future<void> toggleIncludeTaxInPrices(bool include) async {
    _includeTaxInPrices = include;
    await _saveSettings();
  }

  // Calculate tax amount
  double calculateTax(double amount) {
    return amount * (_taxRate / 100);
  }

  // Calculate total with tax
  double calculateTotalWithTax(double amount) {
    return amount + calculateTax(amount);
  }

  // Notification Methods
  Future<void> toggleDailySummary(bool enabled) async {
    _dailySummaryEnabled = enabled;
    await _saveSettings();
  }

  // Get currency display text
  String getCurrencyDisplayText() {
    switch (_currency) {
      case 'KSh':
        return 'KSh (Kenyan Shilling)';
      case 'USD':
        return 'USD (US Dollar)';
      case 'EUR':
        return 'EUR (Euro)';
      default:
        return _currency;
    }
  }

  // Get low stock display text
  String getLowStockDisplayText() {
    return 'Alert when stock is below $_lowStockThreshold items';
  }

  // Get tax display text
  String getTaxDisplayText() {
    return '$_taxRate% VAT';
  }
} 