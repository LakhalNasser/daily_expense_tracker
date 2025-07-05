import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/product_model.dart';

Future<void> deleteProductWithImage({
  required BuildContext context,
  required int productIndex,
  required VoidCallback onSuccess,
}) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/products.json');
  if (await file.exists()) {
    final content = await file.readAsString();
    List<ProductModel> products = ProductModel.decodeList(content);
    if (productIndex < products.length) {
      final product = products[productIndex];
      if (product.imagePath != null) {
        final imgFile = File(product.imagePath!);
        if (await imgFile.exists()) {
          await imgFile.delete();
        }
      }
      products.removeAt(productIndex);
      await file.writeAsString(ProductModel.encodeList(products));
      onSuccess();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف المنتج بنجاح!')),
      );
    }
  }
}
