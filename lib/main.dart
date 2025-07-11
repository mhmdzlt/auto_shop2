import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// استورد صفحاتك هنا
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/cart_page.dart';
import 'pages/order_history_page.dart';
import 'pages/chat_page.dart';
import 'pages/profile_page.dart';
import 'pages/products_page.dart';
import 'pages/splash_page.dart';
import 'pages/add_product_page.dart';
import 'pages/messages_page.dart';
import 'core/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // ✅ نحذف اللغة المحفوظة سابقًا (ku)
  await EasyLocalization.deleteSaveLocale();

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ], // ✅ فقط عربي وإنجليزي
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Parts Store',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        ...context.localizationDelegates,
      ],
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF93838),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'NotoSans',
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Color(0xFF181111)),
          titleTextStyle: TextStyle(
            color: Color(0xFF181111),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          centerTitle: true,
          elevation: 0,
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/cart': (context) => const CartPage(),
        '/orders': (context) => const OrderHistoryPage(),
        '/chat': (context) => ChatPage(userId: ''),
        '/profile': (context) => const ProfilePage(),
        '/products': (context) =>
            const SectionPartsPage(sectionId: 0, sectionName: 'All'),
        '/splash': (context) => const SplashPage(),
        '/add_product': (context) => const AddProductPage(),
        '/messages': (context) => const MessagesPage(),
      },
    );
  }
}
