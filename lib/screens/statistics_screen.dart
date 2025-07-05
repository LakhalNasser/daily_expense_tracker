import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/product_model.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Future<Map<String, num>> _categoryTotalsFuture;

  @override
  void initState() {
    super.initState();
    _categoryTotalsFuture = _loadCategoryTotals();
  }

  Future<Map<String, num>> _loadCategoryTotals() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/products.json');
    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        final products = ProductModel.decodeList(content);
        final Map<String, num> totals = {};
        for (var p in products) {
          totals[p.category] = (totals[p.category] ?? 0) + p.amount;
        }
        return totals;
      }
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إحصائيات المصاريف')),
      body: FutureBuilder<Map<String, num>>(
        future: _categoryTotalsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data ?? {};
          if (data.isEmpty) {
            return const Center(child: Text('لا توجد بيانات لعرض الإحصائيات.'));
          }
          final sections = data.entries.map((e) => PieChartSectionData(
            value: e.value.toDouble(),
            title: e.key,
            color: Colors.primaries[data.keys.toList().indexOf(e.key) % Colors.primaries.length],
            radius: 60,
            titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          )).toList();
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Text('توزيع المصاريف حسب التصنيف', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ...data.entries.map((e) => Row(
                  children: [
                    Container(
                      width: 16, height: 16,
                      color: Colors.primaries[data.keys.toList().indexOf(e.key) % Colors.primaries.length],
                    ),
                    const SizedBox(width: 8),
                    Text('${e.key}: ${e.value} دج'),
                  ],
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}
