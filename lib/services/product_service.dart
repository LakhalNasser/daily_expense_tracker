/// خدمة المنتجات (وهمية كبداية)
class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  Future<void> init() async {
    // هنا يمكن تهيئة قواعد البيانات أو تحميل بيانات أولية
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
