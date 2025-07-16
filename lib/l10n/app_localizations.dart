// lib/l10n/app_localizations.dart
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _localizedValues = <String, Map<String, String>>{
    'ar': {
      'products': 'المنتجات',
      'add': 'إضافة',
      'statistics': 'الإحصائيات',
      'settings': 'الإعدادات',
      'product_list': 'قائمة المنتجات',
      'add_product': 'إضافة منتج',
      'edit_product': 'تعديل منتج',
      'amount': 'المبلغ',
      'category': 'التصنيف',
      'notes': 'ملاحظات',
      'date': 'التاريخ',
      'search': 'بحث عن منتج بالاسم أو التصنيف',
      'no_products': 'لا توجد منتجات بعد.',
      'no_results': 'لا توجد نتائج للفلترة.',
      'delete': 'حذف',
      'cancel': 'إلغاء',
      'confirm_delete': 'تأكيد الحذف',
      'delete_message': 'هل أنت متأكد من حذف هذا المنتج؟',
      'edit': 'تعديل',
      'currency': 'العملة',
      'dark_mode': 'الوضع الليلي',
      'clear_data': 'مسح جميع البيانات',
      'language': 'اللغة',
      'arabic': 'العربية',
      'english': 'English',
      'snackbar_currency': 'تم تغيير العملة إلى',
      'snackbar_language_ar': 'تم تغيير اللغة إلى العربية',
      'snackbar_language_en': 'Language changed to English',
      'product_details': 'تفاصيل المنتج',
      'product_name': 'اسم المنتج',
      'select_date': 'اختر التاريخ',
    },
    'en': {
      'products': 'Products',
      'add': 'Add',
      'statistics': 'Statistics',
      'settings': 'Settings',
      'product_list': 'Product List',
      'add_product': 'Add Product',
      'edit_product': 'Edit Product',
      'amount': 'Amount',
      'category': 'Category',
      'notes': 'Notes',
      'date': 'Date',
      'search': 'Search by name or category',
      'no_products': 'No products yet.',
      'no_results': 'No results for filter.',
      'delete': 'Delete',
      'cancel': 'Cancel',
      'confirm_delete': 'Confirm Delete',
      'delete_message': 'Are you sure you want to delete this product?',
      'edit': 'Edit',
      'currency': 'Currency',
      'dark_mode': 'Dark Mode',
      'clear_data': 'Clear All Data',
      'language': 'Language',
      'arabic': 'Arabic',
      'english': 'English',
      'snackbar_currency': 'Currency changed to',
      'snackbar_language_ar': 'Language changed to Arabic',
      'snackbar_language_en': 'Language changed to English',
      'product_details': 'Product Details',
      'product_name': 'Product Name',
      'select_date': 'Select Date',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
