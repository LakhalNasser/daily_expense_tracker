import 'dart:convert';

class ProductModel {
  final String name;
  final num amount;
  final String category;
  final DateTime date;
  final String? notes;
  final String? imagePath;

  ProductModel({
    required this.name,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'amount': amount,
        'category': category,
        'date': date.toIso8601String(),
        'notes': notes,
        'imagePath': imagePath,
      };

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        name: json['name'],
        amount: json['amount'],
        category: json['category'],
        date: DateTime.parse(json['date']),
        notes: json['notes'],
        imagePath: json['imagePath'],
      );

  static String encodeList(List<ProductModel> products) =>
      jsonEncode(products.map((e) => e.toJson()).toList());

  static List<ProductModel> decodeList(String jsonStr) =>
      (jsonDecode(jsonStr) as List)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
}
