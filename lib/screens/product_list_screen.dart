import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/currency_provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'edit_product_screen.dart';
import 'product_details_screen.dart';
import '../l10n/app_localizations.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<ProductModel>> _productsFuture;
  String? _selectedFilterCategory;
  DateTime? _selectedFilterDate;
  String _searchQuery = '';

  final List<String> _categories = [
    'طعام',
    'ملابس',
    'إلكترونيات',
    'ترفيه',
    'أخرى',
  ];

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProducts();
  }

  Future<List<ProductModel>> _loadProducts() async {
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
      appBar: AppBar(title: const Text('قائمة المنتجات')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).get('search'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedFilterCategory,
                        items: [null, ..._categories]
                            .map((cat) => DropdownMenuItem<String>(
                                  value: cat,
                                  child: Text(cat ??
                                      AppLocalizations.of(context)
                                          .get('category')),
                                ))
                            .toList(),
                        decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context).get('category'),
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (val) =>
                            setState(() => _selectedFilterCategory = val),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedFilterDate ?? now,
                            firstDate: DateTime(now.year - 5),
                            lastDate: DateTime(now.year + 1),
                            locale: const Locale('ar'),
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedFilterDate = picked;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'التاريخ',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            _selectedFilterDate == null
                                ? 'كل التواريخ'
                                : '${_selectedFilterDate!.year}-${_selectedFilterDate!.month.toString().padLeft(2, '0')}-${_selectedFilterDate!.day.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ),
                    ),
                    if (_selectedFilterCategory != null ||
                        _selectedFilterDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() {
                          _selectedFilterCategory = null;
                          _selectedFilterDate = null;
                        }),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ProductModel>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text(
                          AppLocalizations.of(context).get('no_products')));
                }
                var products = snapshot.data!;
                if (_selectedFilterCategory != null) {
                  products = products
                      .where((p) => p.category == _selectedFilterCategory)
                      .toList();
                }
                if (_selectedFilterDate != null) {
                  products = products
                      .where((p) =>
                          p.date.year == _selectedFilterDate!.year &&
                          p.date.month == _selectedFilterDate!.month &&
                          p.date.day == _selectedFilterDate!.day)
                      .toList();
                }
                if (_searchQuery.isNotEmpty) {
                  products = products
                      .where((p) =>
                          p.name.contains(_searchQuery) ||
                          p.category.contains(_searchQuery))
                      .toList();
                }
                if (products.isEmpty) {
                  return Center(
                      child:
                          Text(AppLocalizations.of(context).get('no_results')));
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 500;
                    final imageSize = isWide ? 72.0 : 56.0;
                    final cardPadding = isWide ? 24.0 : 12.0;
                    final fontSize = isWide ? 18.0 : 15.0;
                    return ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailsScreen(
                                    product: product),
                                settings: RouteSettings(arguments: index),
                              ),
                            );
                          },
                          child: Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: cardPadding,
                                vertical: cardPadding / 2),
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(
                                  isWide ? 20 : 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FutureBuilder<bool>(
                                    future: product.imagePath != null
                                        ? File(product.imagePath!).exists()
                                        : Future.value(false),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                              ConnectionState.done &&
                                          snapshot.data == true) {
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              16),
                                          child: Image.file(
                                            File(product.imagePath!),
                                            width: imageSize + 24,
                                            height: imageSize + 24,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      } else {
                                        return Icon(Icons.image,
                                            size: imageSize + 24,
                                            color: Colors.grey);
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(product.name,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: fontSize +
                                                    2)),
                                        const SizedBox(height: 6),
                                        Text(
                                            '${AppLocalizations.of(context).get('amount')}: ${product.amount} $currency',
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontSize: fontSize)),
                                        Text(
                                            '${AppLocalizations.of(context).get('category')}: ${product.category}',
                                            style: TextStyle(fontSize: fontSize)),
                                        if (product.notes != null &&
                                            product.notes!.isNotEmpty)
                                          Text(
                                              '${AppLocalizations.of(context).get('notes')}: ${product.notes!}',
                                              style: TextStyle(
                                                  fontSize: fontSize - 2,
                                                  color: Colors.grey)),
                                        Text(
                                            '${AppLocalizations.of(context).get('date')}: ${product.date.year}-${product.date.month.toString().padLeft(2, '0')}-${product.date.day.toString().padLeft(2, '0')}',
                                            style: TextStyle(
                                                fontSize: fontSize - 2)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        color: Colors.orange,
                                        tooltip: AppLocalizations.of(context)
                                            .get('edit'),
                                        onPressed: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditProductScreen(
                                                      productIndex: index),
                                            ),
                                          );
                                          setState(() {
                                            _productsFuture = _loadProducts();
                                          });
                                        },
                                        splashColor: Colors.orangeAccent,
                                        highlightColor: Colors.orange.shade100,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        color: Colors.red,
                                        tooltip: AppLocalizations.of(context)
                                            .get('delete'),
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: Text(
                                                  AppLocalizations.of(context)
                                                      .get('confirm_delete')),
                                              content: Text(
                                                  AppLocalizations.of(context)
                                                      .get('delete_message')),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx, false),
                                                  child: Text(
                                                      AppLocalizations.of(context)
                                                          .get('cancel')),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx, true),
                                                  child: Text(
                                                      AppLocalizations.of(context)
                                                          .get('delete'),
                                                      style: const TextStyle(
                                                          color: Colors.red)),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            // حذف المنتج من JSON وحذف الصورة إذا وجدت
                                            final dir =
                                                await getApplicationDocumentsDirectory();
                                            final file =
                                                File('${dir.path}/products.json');
                                            if (await file.exists()) {
                                              final content =
                                                  await file.readAsString();
                                              List<ProductModel> products =
                                                  ProductModel.decodeList(
                                                      content);
                                              if (index < products.length) {
                                                final product = products[index];
                                                if (product.imagePath != null) {
                                                  final imgFile =
                                                      File(product.imagePath!);
                                                  if (await imgFile.exists()) {
                                                    await imgFile.delete();
                                                  }
                                                }
                                                products.removeAt(index);
                                                await file.writeAsString(
                                                    ProductModel.encodeList(
                                                        products));
                                                setState(() {
                                                  _productsFuture =
                                                      _loadProducts();
                                                });
                                              }
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
