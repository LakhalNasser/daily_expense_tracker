import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<ProductModel>> _productsFuture;
  String? _selectedFilterCategory;
  DateTime? _selectedFilterDate;

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
    return Scaffold(
      appBar: AppBar(title: const Text('قائمة المنتجات')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedFilterCategory,
                    items: [null, ..._categories].map((cat) => DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat ?? 'كل التصنيفات'),
                    )).toList(),
                    decoration: const InputDecoration(
                      labelText: 'التصنيف',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => setState(() => _selectedFilterCategory = val),
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
                if (_selectedFilterCategory != null || _selectedFilterDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() {
                      _selectedFilterCategory = null;
                      _selectedFilterDate = null;
                    }),
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
                  return const Center(child: Text('لا توجد منتجات بعد.'));
                }
                var products = snapshot.data!;
                if (_selectedFilterCategory != null) {
                  products = products.where((p) => p.category == _selectedFilterCategory).toList();
                }
                if (_selectedFilterDate != null) {
                  products = products.where((p) =>
                    p.date.year == _selectedFilterDate!.year &&
                    p.date.month == _selectedFilterDate!.month &&
                    p.date.day == _selectedFilterDate!.day
                  ).toList();
                }
                if (products.isEmpty) {
                  return const Center(child: Text('لا توجد نتائج للفلترة.'));
                }
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: product.imagePath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(product.imagePath!),
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.image, size: 40, color: Colors.grey),
                        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('المبلغ: ${product.amount} دج', style: const TextStyle(color: Colors.green)),
                            Text('التصنيف: ${product.category}'),
                            if (product.notes != null && product.notes!.isNotEmpty)
                              Text('ملاحظات: ${product.notes!}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            Text('التاريخ: ${product.date.year}-${product.date.month.toString().padLeft(2, '0')}-${product.date.day.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                // TODO: الانتقال إلى EditProductScreen مع index
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('تأكيد الحذف'),
                                    content: const Text('هل أنت متأكد من حذف هذا المنتج؟'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, false),
                                        child: const Text('إلغاء'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, true),
                                        child: const Text('حذف', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  // حذف المنتج من JSON وحذف الصورة إذا وجدت
                                  final dir = await getApplicationDocumentsDirectory();
                                  final file = File('${dir.path}/products.json');
                                  if (await file.exists()) {
                                    final content = await file.readAsString();
                                    List<ProductModel> products = ProductModel.decodeList(content);
                                    if (index < products.length) {
                                      final product = products[index];
                                      if (product.imagePath != null) {
                                        final imgFile = File(product.imagePath!);
                                        if (await imgFile.exists()) {
                                          await imgFile.delete();
                                        }
                                      }
                                      products.removeAt(index);
                                      await file.writeAsString(ProductModel.encodeList(products));
                                      setState(() {
                                        _productsFuture = _loadProducts();
                                      });
                                    }
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                        onTap: () {},
                      ),
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
