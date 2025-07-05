import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class EditProductScreen extends StatefulWidget {
  final int productIndex;
  const EditProductScreen({Key? key, required this.productIndex}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  String? _selectedCategory;
  DateTime? _selectedDate;
  String? _imagePath;
  bool _loading = true;
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
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/products.json');
    if (await file.exists()) {
      final content = await file.readAsString();
      final products = ProductModel.decodeList(content);
      final product = products[widget.productIndex];
      _nameController = TextEditingController(text: product.name);
      _amountController = TextEditingController(text: product.amount.toString());
      _notesController = TextEditingController(text: product.notes ?? '');
      _selectedCategory = product.category;
      _selectedDate = product.date;
      _imagePath = product.imagePath;
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('تعديل منتج')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ...حقول التعديل (سيتم استكمالها في المهام القادمة)...
            Text('واجهة تعديل المنتج (تحت التطوير)')
          ],
        ),
      ),
    );
  }
}
