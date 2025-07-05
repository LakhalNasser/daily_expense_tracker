import 'package:flutter/material.dart';

/// MainScreen: واجهة التنقل الرئيسية بين الشاشات
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // قائمة الشاشات (تُبنى بشكل كسول)
  final List<Widget?> _screens = List.filled(4, null);

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const Center(child: Text('قائمة المنتجات'));
      case 1:
        return const Center(child: Text('إضافة منتج'));
      case 2:
        return const Center(child: Text('الإحصائيات'));
      case 3:
        return const Center(child: Text('الإعدادات'));
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  void initState() {
    super.initState();
    // يمكن لاحقًا ربطها بـ provider أو shared_preferences لاستعادة آخر صفحة
    // تحميل الشاشة الأولى فقط عند البداية
    _screens[0] = _buildScreen(0);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // تحميل الشاشة عند الطلب فقط
      if (_screens[index] == null) {
        _screens[index] = _buildScreen(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_selectedIndex)),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: List.generate(_screens.length, (i) => _screens[i] ?? const SizedBox.shrink()),
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
