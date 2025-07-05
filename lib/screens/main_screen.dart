import 'package:flutter/material.dart';
import '../services/product_service.dart';
import 'add_product_screen.dart';
import 'product_list_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

/// MainScreen: واجهة التنقل الرئيسية بين الشاشات
class MainScreen extends StatefulWidget {
  final void Function(bool)? onThemeChanged;
  const MainScreen({Key? key, this.onThemeChanged}) : super(key: key);

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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'المنتجات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'إضافة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'الإحصائيات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => _onItemTapped(1),
              child: const Icon(Icons.add),
              tooltip: 'إضافة منتج جديد',
            )
          : null,
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'قائمة المنتجات';
      case 1:
        return 'إضافة منتج';
      case 2:
        return 'الإحصائيات';
      case 3:
        return 'الإعدادات';
      default:
        return '';
    }
  }
}
