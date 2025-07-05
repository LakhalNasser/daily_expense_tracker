import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/product_model.dart';

/// خدمة المنتجات (وهمية كبداية)
class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  List<ProductModel> _products = [];
  String? _jsonPath;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _jsonPath = '${dir.path}/products.json';
    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (_jsonPath == null) return;
    final file = File(_jsonPath!);
    if (await file.exists()) {
      final jsonStr = await file.readAsString();
      _products = ProductModel.decodeList(jsonStr);
    } else {
      _products = [];
    }
  }

  List<ProductModel> get products => List.unmodifiable(_products);

  Future<void> addProduct(ProductModel product) async {
    _products.add(product);
    await _saveProducts();
  }

  Future<void> updateProduct(int index, ProductModel product) async {
    _products[index] = product;
    await _saveProducts();
  }

  Future<void> deleteProduct(int index) async {
    _products.removeAt(index);
    await _saveProducts();
  }

  Future<void> _saveProducts() async {
    if (_jsonPath == null) return;
    final file = File(_jsonPath!);
    await file.writeAsString(ProductModel.encodeList(_products));
  }

  Future<void> clearAll() async {
    _products.clear();
    if (_jsonPath != null) {
      final file = File(_jsonPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}
