import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'models/part.dart';
import 'models/offline_order.dart';
import 'models/app_preferences.dart';
import 'models/address.dart' as app_models;
import 'models/order.dart';
import 'storage/favorites_storage.dart';
import 'pages/splash_page.dart';
import 'services/notification_service.dart';
import 'services/payment_service.dart';
import 'services/payment_invoice_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // قياس وقت بدء التشغيل
  final appStartTime = DateTime.now();

  try {
    // تهيئة الخدمات الأساسية بالتوازي
    await Future.wait([
      EasyLocalization.ensureInitialized(),
      _initializeCore(),
    ]);

    final initTime = DateTime.now().difference(appStartTime).inMilliseconds;
    debugPrint('🚀 App started in ${initTime}ms');

    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('ar'), Locale('en'), Locale('ku')],
        path: 'assets/translations',
        fallbackLocale: const Locale('ar'),
        child: const MyApp(),
      ),
    );
  } catch (e) {
    debugPrint('❌ App startup error: $e');
    // تشغيل التطبيق مع إعدادات افتراضية
    runApp(const MaterialApp(home: _ErrorScreen()));
  }
}

/// تهيئة الخدمات الأساسية
Future<void> _initializeCore() async {
  await Future.wait([
    _initializeHive(),
    _initializeSupabase(),
    _initializeServices(),
  ], eagerError: false);
}

/// تهيئة Hive مع التحسين
Future<void> _initializeHive() async {
  try {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);

    // تسجيل Adapters
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(PartAdapter());
    if (!Hive.isAdapterRegistered(1))
      Hive.registerAdapter(OfflineOrderAdapter());
    if (!Hive.isAdapterRegistered(2))
      Hive.registerAdapter(AppPreferencesAdapter());
    if (!Hive.isAdapterRegistered(3))
      Hive.registerAdapter(app_models.AddressAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(OrderAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(OrderItemAdapter());
  } catch (e) {
    debugPrint('❌ Hive initialization error: $e');
  }
}

/// تهيئة Supabase
Future<void> _initializeSupabase() async {
  try {
    await Supabase.initialize(
      url: 'https://nwakvjyqarqppqaexnks.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im53YWt2anlxYXJxcHBxYWV4bmtzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE0MTgxMTAsImV4cCI6MjA2Njk5NDExMH0.NDDG0p71kWrPIVci4KWmK10JOqFt5x7-IjmzJnfdVtc',
    );
  } catch (e) {
    debugPrint('❌ Supabase initialization error: $e');
  }
}

/// تهيئة الخدمات
Future<void> _initializeServices() async {
  try {
    await Future.wait([
      NotificationService.initialize(),
      PaymentService.init(),
      _initializePaymentInvoiceService(),
      _openHiveBoxes(),
    ], eagerError: false);
  } catch (e) {
    debugPrint('❌ Services initialization error: $e');
  }
}

/// فتح صناديق Hive المطلوبة
Future<void> _openHiveBoxes() async {
  try {
    await Future.wait([
      Hive.openBox<Part>('products'),
      Hive.openBox<OfflineOrder>('offline_orders'),
      Hive.openBox<AppPreferences>('preferences'),
      Hive.openBox<app_models.Address>('addresses'),
      Hive.openBox<Order>('orders'),
      FavoritesStorage.init(),
    ], eagerError: false);
    debugPrint('✅ Hive boxes opened successfully');
  } catch (e) {
    debugPrint('❌ Error opening Hive boxes: $e');
  }
}

/// تهيئة خدمة فواتير الدفع
Future<void> _initializePaymentInvoiceService() async {
  try {
    final paymentInvoiceService = PaymentInvoiceService();
    await paymentInvoiceService.setupPaymentListeners();
  } catch (e) {
    debugPrint('❌ Payment invoice service error: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // تحسين محرك الخطوط العربية
    GoogleFonts.config.allowRuntimeFetching = false;

    return MaterialApp(
      title: 'Auto Shop',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,

      // تحسين الأداء - تقليل rebuilds
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1.0), // منع تغيير حجم النص
          ),
          child: child!,
        );
      },

      theme: ThemeData(
        fontFamily: GoogleFonts.notoSansArabic().fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.light,
        ),
        useMaterial3: true,

        // تحسين أداء النصوص
        textTheme: GoogleFonts.notoSansArabicTextTheme(),

        // تحسين أداء AppBar
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          titleTextStyle: GoogleFonts.notoSansArabic(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        // تحسين أداء الأزرار
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1976D2),
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: Colors.black26,
            textStyle: GoogleFonts.notoSansArabic(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),

      home: const SplashPage(),
    );
  }
}

/// شاشة خطأ بسيطة عند فشل التهيئة
class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'حدث خطأ في تشغيل التطبيق',
                style: GoogleFonts.notoSansArabic(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'يرجى إعادة تشغيل التطبيق',
                style: GoogleFonts.notoSansArabic(fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // إعادة تشغيل التطبيق
                  main();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'إعادة المحاولة',
                  style: GoogleFonts.notoSansArabic(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
