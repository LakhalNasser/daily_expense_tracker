import 'package:flutter/material.dart';
import '../services/product_service.dart';
import 'add_product_screen.dart';
import 'product_list_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';
import '../l10n/app_localizations.dart';

/// MainScreen: واجهة التنقل الرئيسية بين الشاشات
class MainScreen extends StatefulWidget {
  final void Function(bool)? onThemeChanged;
  final Locale currentLocale;
  final void Function(Locale)? onLocaleChanged;
  const MainScreen(
      {super.key,
      this.onThemeChanged,
      this.onLocaleChanged,
      required this.currentLocale});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // متغيرات لكل شاشة (تُنشأ عند الطلب فقط)
  Widget? _productListScreen;
  Widget? _addProductScreen;
  Widget? _statisticsScreen;
  Widget? _settingsScreen;

  @override
  void initState() {
    super.initState();
    // تهيئة الخدمات عند بدء التطبيق
    _initServices();
    // TODO: يمكن لاحقًا ربطها بـ provider أو shared_preferences لاستعادة آخر صفحة
  }

  Future<void> _initServices() async {
    await ProductService().init();
    // يمكن إضافة تهيئة خدمات أخرى هنا
  }

  // دالة تُعيد الشاشة المطلوبة وتُنشئها عند أول طلب فقط
  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return _productListScreen ??= const ProductListScreen();
      case 1:
        return _addProductScreen ??= const AddProductScreen();
      case 2:
        return _statisticsScreen ??= const StatisticsScreen();
      case 3:
        return _settingsScreen ??= SettingsScreen(
          onThemeChanged: widget.onThemeChanged,
          onLocaleChanged: widget.onLocaleChanged,
          currentLocale: widget.currentLocale,
        );
      default:
        return Container();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_selectedIndex)),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: Container(
          key: ValueKey<int>(_selectedIndex),
          child: _getScreen(_selectedIndex),
        ),
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  Icons.list,
                  color: _selectedIndex == 0 ? Colors.deepPurple : Colors.grey,
                  key: ValueKey(_selectedIndex == 0),
                ),
              ),
              label: AppLocalizations.of(context).get('products'),
            ),
            BottomNavigationBarItem(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  Icons.add_box,
                  color: _selectedIndex == 1 ? Colors.deepPurple : Colors.grey,
                  key: ValueKey(_selectedIndex == 1),
                ),
              ),
              label: AppLocalizations.of(context).get('add'),
            ),
            BottomNavigationBarItem(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  Icons.pie_chart,
                  color: _selectedIndex == 2 ? Colors.deepPurple : Colors.grey,
                  key: ValueKey(_selectedIndex == 2),
                ),
              ),
              label: AppLocalizations.of(context).get('statistics'),
            ),
            BottomNavigationBarItem(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  Icons.settings,
                  color: _selectedIndex == 3 ? Colors.deepPurple : Colors.grey,
                  key: ValueKey(_selectedIndex == 3),
                ),
              ),
              label: AppLocalizations.of(context).get('settings'),
            ),
          ],
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(color: Colors.grey),
          showUnselectedLabels: true,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          elevation: 8,
          backgroundColor: Colors.white,
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => _onItemTapped(1),
              tooltip: 'إضافة منتج جديد',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  String _getTitle(int index) {
    final l10n = AppLocalizations.of(context);
    switch (index) {
      case 0:
        return l10n.get('product_list');
      case 1:
        return l10n.get('add_product');
      case 2:
        return l10n.get('statistics');
      case 3:
        return l10n.get('settings');
      default:
        return '';
    }
  }
}
