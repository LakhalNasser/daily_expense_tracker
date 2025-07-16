import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/currency_provider.dart';
import 'screens/main_screen.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  Locale _currentLocale = const Locale('ar');

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _loadLocale();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  void _toggleTheme(bool value) async {
    setState(() {
      _isDarkMode = value;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLocale = Locale(prefs.getString('locale') ?? 'ar');
    });
  }

  void _changeLocale(Locale locale) async {
    setState(() {
      _currentLocale = locale;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _currentLocale.languageCode == 'ar'
          ? 'تتبع مصاريف المنتجات'
          : 'Product Expense Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Cairo', // خط حديث وجذاب
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
          headlineMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          bodyLarge: TextStyle(fontSize: 18),
          bodyMedium: TextStyle(fontSize: 16),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF512DA8),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        cardTheme: const CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color(0xFF512DA8),
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
          primary: Color(0xFF311B92),
          secondary: Color(0xFF9575CD),
          background: Color(0xFF22223B),
          surface: Color(0xFF2A2A40),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: Colors.white,
          onSurface: Colors.white,
          error: Colors.redAccent,
          onError: Colors.white,
        ),
        useMaterial3: true,
        fontFamily: 'Cairo',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 28, color: Colors.white),
          headlineMedium: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
          bodyLarge: TextStyle(fontSize: 18, color: Colors.white),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.white),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF311B92),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        cardTheme: const CardTheme(
          elevation: 4,
          color: Color(0xFF2A2A40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color(0xFF9575CD),
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizationsDelegate(),
      ],
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      locale: _currentLocale,
      home: MainScreen(
        onThemeChanged: _toggleTheme,
        onLocaleChanged: _changeLocale,
        currentLocale: _currentLocale,
      ),
    );
  }
}
