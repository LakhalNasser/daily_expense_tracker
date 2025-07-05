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
      body: FutureBuilder<List<ProductModel>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد منتجات بعد.'));
          }
          final products = snapshot.data!;
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
                  onTap: () {},
                ),
              );
            },
          );
        },
      ),
    );
  }
}
