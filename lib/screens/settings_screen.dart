import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';

class SettingsScreen extends StatefulWidget {
  final void Function(bool)? onThemeChanged;
  const SettingsScreen({super.key, this.onThemeChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  String currency = 'DZD';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
      currency = prefs.getString('currency') ?? 'DZD';
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
        context.read<CurrencyProvider>().setCurrency(value);
      }
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('تم تغيير العملة إلى: ${_currencyLabel(value)}')),
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

  void _clearData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد مسح البيانات'),
        content: const Text(
            'هل أنت متأكد من رغبتك في مسح جميع البيانات؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('مسح'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      // TODO: Clear all app data (products, images, settings)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم مسح جميع البيانات بنجاح')),
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
