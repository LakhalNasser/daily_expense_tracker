import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/currency_provider.dart';

class SettingsScreen extends StatefulWidget {
  final void Function(bool)? onThemeChanged;
  final Locale currentLocale;
  final void Function(Locale)? onLocaleChanged;
  const SettingsScreen(
      {super.key,
      this.onThemeChanged,
      this.onLocaleChanged,
      required this.currentLocale});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  String currency = 'DZD';
  bool _isLoading = true;
  Locale _currentLocale = const Locale('ar');

  @override
  void initState() {
    super.initState();
    _currentLocale = widget.currentLocale;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
      currency = prefs.getString('currency') ?? 'DZD';
      _currentLocale = Locale(prefs.getString('locale') ?? 'ar');
      _isLoading = false;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    setState(() {
      isDarkMode = value;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    if (widget.onThemeChanged != null) {
      widget.onThemeChanged!(value);
    }
  }

  Future<void> _changeCurrency(String? value) async {
    if (value != null && value != currency) {
      setState(() {
        currency = value;
        _isLoading = true;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currency', value);
      // تحديث العملة في provider
      if (mounted) {
        Provider.of<CurrencyProvider>(context, listen: false)
            .setCurrency(value);
      }
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                  child: Text('تم تغيير العملة إلى: ${_currencyLabel(value)}')),
            ],
          ),
          backgroundColor: Colors.green.shade50,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'إغلاق',
            textColor: Colors.green,
            onPressed: () {},
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  String _currencyLabel(String value) {
    switch (value) {
      case 'DZD':
        return 'دينار جزائري';
      case 'USD':
        return 'دولار أمريكي';
      case 'EUR':
        return 'يورو';
      default:
        return value;
    }
  }

  Future<void> _changeLanguage(Locale? locale) async {
    if (locale != null && locale != _currentLocale) {
      setState(() {
        _currentLocale = locale;
        _isLoading = true;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('locale', locale.languageCode);
      if (widget.onLocaleChanged != null) {
        widget.onLocaleChanged!(locale);
      }
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.language, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(locale.languageCode == 'ar'
                      ? 'تم تغيير اللغة إلى العربية'
                      : 'Language changed to English')),
            ],
          ),
          backgroundColor: Colors.blue.shade50,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'إغلاق',
            textColor: Colors.blue,
            onPressed: () {},
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _clearData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 8),
            const Text('تأكيد مسح البيانات'),
          ],
        ),
        content: const Text(
            'هل أنت متأكد من رغبتك في مسح جميع البيانات؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('مسح', style: TextStyle(color: Colors.red)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
    if (confirm == true) {
      // TODO: Clear all app data (products, images, settings)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.delete_forever, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(child: Text('تم مسح جميع البيانات بنجاح')),
            ],
          ),
          backgroundColor: Colors.red.shade50,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'إغلاق',
            textColor: Colors.red,
            onPressed: () {},
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('العملة'),
            trailing: DropdownButton<String>(
              value: currency,
              items: const [
                DropdownMenuItem(value: 'DZD', child: Text('دينار جزائري')),
                DropdownMenuItem(value: 'USD', child: Text('دولار أمريكي')),
                DropdownMenuItem(value: 'EUR', child: Text('يورو')),
              ],
              onChanged: _isLoading ? null : _changeCurrency,
            ),
          ),
          SwitchListTile(
            title: const Text('الوضع الليلي'),
            value: isDarkMode,
            onChanged: _toggleDarkMode,
          ),
          ListTile(
            title: Text('اللغة'),
            trailing: DropdownButton<Locale>(
              value: _currentLocale,
              items: const [
                DropdownMenuItem(child: Text('العربية'), value: Locale('ar')),
                DropdownMenuItem(child: Text('English'), value: Locale('en')),
              ],
              onChanged: _isLoading ? null : _changeLanguage,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_forever),
            label: const Text('مسح جميع البيانات'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: _clearData,
          ),
        ],
      ),
    );
  }
}
