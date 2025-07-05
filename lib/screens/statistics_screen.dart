import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/product_model.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Future<Map<String, num>> _categoryTotalsFuture;
  late Future<Map<DateTime, num>> _dailyTotalsFuture;
  late Future<List<ProductModel>> _allProductsFuture;

  @override
  void initState() {
    super.initState();
    _categoryTotalsFuture = _loadCategoryTotals();
    _dailyTotalsFuture = _loadDailyTotals();
    _allProductsFuture = _loadAllProducts();
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

  Future<List<ProductModel>> _loadAllProducts() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/products.json');
    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        return ProductModel.decodeList(content);
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>().currency;
    return Scaffold(
      appBar: AppBar(title: const Text('إحصائيات المصاريف')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                minWidth: constraints.maxWidth,
              ),
              child: IntrinsicHeight(
                child: FutureBuilder<Map<String, num>>(
                  future: _categoryTotalsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final data = snapshot.data ?? {};
                    if (data.isEmpty) {
                      return const Center(
                          child: Text('لا توجد بيانات لعرض الإحصائيات.'));
                    }
                    final sections = data.entries
                        .map((e) => PieChartSectionData(
                              value: e.value.toDouble(),
                              title: e.key,
                              color: Colors.primaries[
                                  data.keys.toList().indexOf(e.key) %
                                      Colors.primaries.length],
                              radius: 60,
                              titleStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ))
                        .toList();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('توزيع المصاريف حسب التصنيف',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: constraints.maxWidth < 400 ? 180 : 250,
                          child: PieChart(
                            PieChartData(
                              sections: sections,
                              sectionsSpace: 2,
                              centerSpaceRadius:
                                  constraints.maxWidth < 400 ? 24 : 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ...data.entries.map((e) => Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: Colors.primaries[
                                      data.keys.toList().indexOf(e.key) %
                                          Colors.primaries.length],
                                ),
                                const SizedBox(width: 8),
                                Text('${e.key}: ${e.value} $currency'),
                              ],
                            )),
                        const SizedBox(height: 32),
                        const Text('تغير المصاريف زمنيًا',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        FutureBuilder<Map<DateTime, num>>(
                          future: _dailyTotalsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            final data = snapshot.data ?? {};
                            if (data.isEmpty) {
                              return const Text(
                                  'لا توجد بيانات كافية للرسم البياني الخطي.');
                            }
                            final sortedKeys = data.keys.toList()..sort();
                            final spots = <FlSpot>[];
                            for (int i = 0; i < sortedKeys.length; i++) {
                              spots.add(FlSpot(i.toDouble(),
                                  data[sortedKeys[i]]!.toDouble()));
                            }
                            return SizedBox(
                              height: constraints.maxWidth < 400 ? 120 : 200,
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
                                          if (idx < 0 ||
                                              idx >= sortedKeys.length)
                                            return const SizedBox();
                                          final d = sortedKeys[idx];
                                          return Text('${d.month}/${d.day}',
                                              style: const TextStyle(
                                                  fontSize: 10));
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
                        const SizedBox(height: 32),
                        const Text('الملخص',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        FutureBuilder<List<ProductModel>>(
                          future: _allProductsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            final products = snapshot.data ?? [];
                            if (products.isEmpty) {
                              return const Text('لا توجد بيانات كافية للملخص.');
                            }
                            // مجموع يومي
                            final today = DateTime.now();
                            final dailyTotal = products
                                .where((p) =>
                                    p.date.year == today.year &&
                                    p.date.month == today.month &&
                                    p.date.day == today.day)
                                .fold<num>(0, (sum, p) => sum + p.amount);
                            // مجموع شهري
                            final monthlyTotal = products
                                .where((p) =>
                                    p.date.year == today.year &&
                                    p.date.month == today.month)
                                .fold<num>(0, (sum, p) => sum + p.amount);
                            // أعلى تصنيف
                            final Map<String, num> categoryTotals = {};
                            for (var p in products) {
                              categoryTotals[p.category] =
                                  (categoryTotals[p.category] ?? 0) + p.amount;
                            }
                            String topCategory = '';
                            num topValue = 0;
                            categoryTotals.forEach((cat, val) {
                              if (val > topValue) {
                                topCategory = cat;
                                topValue = val;
                              }
                            });
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('مجموع اليوم: $dailyTotal $currency'),
                                Text('مجموع الشهر: $monthlyTotal $currency'),
                                Text(
                                    'أعلى تصنيف: $topCategory (${topValue.toStringAsFixed(2)} $currency)'),
                              ],
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
