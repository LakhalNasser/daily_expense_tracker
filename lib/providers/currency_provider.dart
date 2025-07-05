import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider extends ChangeNotifier {
  String _currency = 'DZD';
  String get currency => _currency;

  CurrencyProvider() {
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    _currency = prefs.getString('currency') ?? 'DZD';
    notifyListeners();
  }

  Future<void> setCurrency(String value) async {
    if (value != _currency) {
      _currency = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currency', value);
      notifyListeners();
    }
  }
}
