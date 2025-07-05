import 'package:flutter/material.dart';

/// MainScreen: واجهة التنقل الرئيسية بين الشاشات
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // قائمة الشاشات (يتم استبدال الحاويات بالشاشات الفعلية لاحقًا)
  final List<Widget> _screens = [
    Center(child: Text('قائمة المنتجات')), // ProductListScreen
    Center(child: Text('إضافة منتج')), // AddProductScreen
    Center(child: Text('الإحصائيات')), // StatisticsScreen
    Center(child: Text('الإعدادات')), // SettingsScreen
  ];

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
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
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
