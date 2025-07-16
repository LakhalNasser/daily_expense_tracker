import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import 'dart:io';
import 'edit_product_screen.dart';
import '../services/delete_product_service.dart';
import '../providers/currency_provider.dart';
import '../l10n/app_localizations.dart';

class ProductDetailsScreen extends StatelessWidget {
  final ProductModel product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>().currency;
    final int? productIndex =
        ModalRoute.of(context)?.settings.arguments as int?;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).get('product_details')),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: AppLocalizations.of(context).get('edit'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProductScreen(
                    productIndex: productIndex ?? 0,
                  ),
                  settings: RouteSettings(arguments: productIndex),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: AppLocalizations.of(context).get('delete'),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title:
                      Text(AppLocalizations.of(context).get('confirm_delete')),
                  content:
                      Text(AppLocalizations.of(context).get('delete_message')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(AppLocalizations.of(context).get('cancel')),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(AppLocalizations.of(context).get('delete'),
                          style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true && productIndex != null) {
                if (!context.mounted) return;
                await deleteProductWithImage(
                  context: context,
                  productIndex: productIndex,
                  onSuccess: () {
                    Navigator.pop(context, true);
                  },
                );
              }
            },
          ),
        ],
      ),
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
                      ? GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => Dialog(
                                child: InteractiveViewer(
                                  panEnabled: true,
                                  minScale: 1,
                                  maxScale: 4,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(product.imagePath!),
                                      width: 350,
                                      height: 350,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(product.imagePath!),
                              width: 180,
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : const Icon(Icons.image, size: 100, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Text(
                    '${AppLocalizations.of(context).get('product_name')}: ${product.name}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(
                    '${AppLocalizations.of(context).get('amount')}: ${product.amount} $currency',
                    style: const TextStyle(fontSize: 18, color: Colors.green)),
                const SizedBox(height: 12),
                Text(
                    '${AppLocalizations.of(context).get('category')}: ${product.category}',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 12),
                Text(
                    '${AppLocalizations.of(context).get('date')}: ${product.date.year}-${product.date.month.toString().padLeft(2, '0')}-${product.date.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 16)),
                if (product.notes != null && product.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                      '${AppLocalizations.of(context).get('notes')}: ${product.notes!}',
                      style: const TextStyle(fontSize: 15, color: Colors.grey)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
