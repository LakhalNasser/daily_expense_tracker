import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

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
        child: Form(
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المنتج',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'المبلغ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                )).toList(),
                decoration: const InputDecoration(
                  labelText: 'التصنيف',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => setState(() => _selectedCategory = val),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? now,
                    firstDate: DateTime(now.year - 5),
                    lastDate: DateTime(now.year + 1),
                    locale: const Locale('ar'),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'التاريخ',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? 'اختر التاريخ'
                        : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              // حقل الصورة
              LayoutBuilder(
                builder: (context, constraints) {
                  final double size = constraints.maxWidth > 200 ? 120 : 80;
                  return Row(
                    children: [
                      _imagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(_imagePath!),
                                width: size,
                                height: size,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              width: size,
                              height: size,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.image, size: 40, color: Colors.grey),
                            ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                final picker = ImagePicker();
                                final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
                                if (image != null) {
                                  setState(() {
                                    _imagePath = image.path;
                                  });
                                }
                              },
                              icon: const Icon(Icons.photo),
                              label: const Text('من المعرض'),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final picker = ImagePicker();
                                final image = await picker.pickImage(source: ImageSource.camera, imageQuality: 75);
                                if (image != null) {
                                  setState(() {
                                    _imagePath = image.path;
                                  });
                                }
                              },
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('من الكاميرا'),
                            ),
                            if (_imagePath != null)
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _imagePath = null;
                                  });
                                },
                                icon: const Icon(Icons.delete, color: Colors.red),
                                label: const Text('حذف الصورة', style: TextStyle(color: Colors.red)),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final dir = await getApplicationDocumentsDirectory();
                  final file = File('${dir.path}/products.json');
                  if (await file.exists()) {
                    final content = await file.readAsString();
                    List<ProductModel> products = ProductModel.decodeList(content);
                    if (widget.productIndex < products.length) {
                      products[widget.productIndex] = ProductModel(
                        name: _nameController.text.trim(),
                        amount: num.tryParse(_amountController.text.trim()) ?? 0,
                        category: _selectedCategory ?? '',
                        date: _selectedDate ?? DateTime.now(),
                        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                        imagePath: _imagePath,
                      );
                      await file.writeAsString(ProductModel.encodeList(products));
                    }
                  }
                },
                child: const Text('حفظ التعديلات'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
