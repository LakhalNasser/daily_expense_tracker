import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'dart:io';

class ProductDetailsScreen extends StatelessWidget {
  final ProductModel product;
  const ProductDetailsScreen({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل المنتج')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: product.imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(product.imagePath!),
                            width: 180,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.image, size: 100, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Text('الاسم: ${product.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('المبلغ: ${product.amount} دج', style: const TextStyle(fontSize: 18, color: Colors.green)),
                const SizedBox(height: 12),
                Text('التصنيف: ${product.category}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 12),
                Text('التاريخ: ${product.date.year}-${product.date.month.toString().padLeft(2, '0')}-${product.date.day.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 16)),
                if (product.notes != null && product.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('ملاحظات: ${product.notes!}', style: const TextStyle(fontSize: 15, color: Colors.grey)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
