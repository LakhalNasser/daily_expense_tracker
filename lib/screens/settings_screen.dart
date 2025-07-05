import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final void Function(bool)? onThemeChanged;
  const SettingsScreen({Key? key, this.onThemeChanged}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  String currency = 'DZD';

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
    if (value != null) {
      setState(() {
        currency = value;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currency', value);
    }
  }

  void _clearData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد مسح البيانات'),
        content: const Text('هل أنت متأكد من رغبتك في مسح جميع البيانات؟ لا يمكن التراجع عن هذا الإجراء.'),
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
              onChanged: _changeCurrency,
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
