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
  late Future<Map<DateTime, num>> _dailyTotalsFuture;

  @override
  void initState() {
    super.initState();
    _categoryTotalsFuture = _loadCategoryTotals();
    _dailyTotalsFuture = _loadDailyTotals();
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

  Future<Map<DateTime, num>> _loadDailyTotals() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/products.json');
    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        final products = ProductModel.decodeList(content);
        final Map<DateTime, num> totals = {};
        for (var p in products) {
          final day = DateTime(p.date.year, p.date.month, p.date.day);
          totals[day] = (totals[day] ?? 0) + p.amount;
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
                const SizedBox(height: 32),
                const Text('تغير المصاريف زمنيًا', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                FutureBuilder<Map<DateTime, num>>(
                  future: _dailyTotalsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final data = snapshot.data ?? {};
                    if (data.isEmpty) {
                      return const Text('لا توجد بيانات كافية للرسم البياني الخطي.');
                    }
                    final sortedKeys = data.keys.toList()..sort();
                    final spots = <FlSpot>[];
                    for (int i = 0; i < sortedKeys.length; i++) {
                      spots.add(FlSpot(i.toDouble(), data[sortedKeys[i]]!.toDouble()));
                    }
                    return SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: Colors.blue,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                            ),
                          ],
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  int idx = value.toInt();
                                  if (idx < 0 || idx >= sortedKeys.length) return const SizedBox();
                                  final d = sortedKeys[idx];
                                  return Text('${d.month}/${d.day}', style: const TextStyle(fontSize: 10));
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                          ),
                          gridData: FlGridData(show: true),
                          borderData: FlBorderData(show: true),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
