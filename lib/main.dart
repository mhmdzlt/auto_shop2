import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart'; // 🐝 Hive للواجهة
import 'package:path_provider/path_provider.dart'; // 📁 لتحديد مسار التخزين
import 'models/part.dart';
import 'models/offline_order.dart'; // 📦 نموذج الطلبات المحلية
import 'models/app_preferences.dart'; // ⚙️ تفضيلات التطبيق
import 'models/address.dart'; // 📍 عناوين المستخدم
import 'models/order.dart'; // 📋 طلبات المستخدم
import 'storage/favorites_storage.dart';
import 'pages/splash_page.dart';
import 'services/notification_service.dart'; // 🔔 خدمة الإشعارات

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // 🔹 تهيئة الإشعارات المحلية
  await NotificationService.initialize();

  // 🔹 تهيئة Hive
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  // تسجيل Adapter وفُتح صندوق المنتجات
  Hive.registerAdapter(PartAdapter());
  Hive.registerAdapter(OfflineOrderAdapter());
  Hive.registerAdapter(AppPreferencesAdapter());
  Hive.registerAdapter(AddressAdapter());
  Hive.registerAdapter(OrderAdapter());
  Hive.registerAdapter(OrderItemAdapter());
  await Hive.openBox<Part>('products');
  await Hive.openBox<OfflineOrder>('offline_orders');
  await Hive.openBox<AppPreferences>('preferences');
  await Hive.openBox<Address>('addresses');
  await Hive.openBox<Order>('orders');
  // تهيئة FavoritesStorage (يفتح صندوق المفضلات)
  await FavoritesStorage.init();

  // 🔹 تهيئة Supabase
  await Supabase.initialize(
    url: 'https://nwakvjyqarqppqaexnks.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im53YWt2anlxYXJxcHBxYWV4bmtzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE0MTgxMTAsImV4cCI6MjA2Njk5NDExMH0.NDDG0p71kWrPIVci4KWmK10JOqFt5x7-IjmzJnfdVtc',
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en'), Locale('ku')],
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
      title: 'Auto Parts',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: GoogleFonts.notoSansArabic().fontFamily,
        textTheme: GoogleFonts.notoSansArabicTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const SplashPage(),
    );
  }
}
