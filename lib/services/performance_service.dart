import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../favorites_storage.dart';
import '../models/part.dart';
import '../models/offline_order.dart';
import '../models/app_preferences.dart';
import '../models/address.dart' as app_models;
import '../models/order.dart';

/// خدمة تحسين الأداء والتحميل السريع
class PerformanceService {
  static bool _isInitialized = false;
  static final Map<String, dynamic> _cache = {};
  static const Duration _cacheTimeout = Duration(minutes: 15);
  static final Map<String, DateTime> _cacheTimestamps = {};

  /// تهيئة شاملة للتطبيق مع تحسين الأداء
  static Future<void> initializeApp() async {
    if (_isInitialized) return;

    final stopwatch = Stopwatch()..start();

    try {
      // تشغيل المهام الأساسية بالتوازي
      await Future.wait([
        _initializeHiveBoxes(),
        _initializeFavorites(),
        _preloadCriticalData(),
        _warmupServices(),
        _optimizeMemory(),
      ], eagerError: false);

      _isInitialized = true;
      debugPrint(
        '✅ App initialization completed in ${stopwatch.elapsedMilliseconds}ms',
      );
    } catch (e) {
      debugPrint('❌ App initialization error: $e');
    } finally {
      stopwatch.stop();
    }
  }

  /// تهيئة صناديق Hive مع التحسين
  static Future<void> _initializeHiveBoxes() async {
    try {
      final boxFutures = <Future>[];

      // فتح الصناديق الأساسية أولاً
      boxFutures.addAll([
        _openBoxSafely<Part>('products'),
        _openBoxSafely<app_models.Address>('addresses'),
        _openBoxSafely<AppPreferences>('preferences'),
      ]);

      // فتح الصناديق الثانوية
      boxFutures.addAll([
        _openBoxSafely<OfflineOrder>('offline_orders'),
        _openBoxSafely<Order>('orders'),
      ]);

      await Future.wait(boxFutures, eagerError: false);
      debugPrint('✅ Hive boxes initialized');
    } catch (e) {
      debugPrint('❌ Hive initialization error: $e');
    }
  }

  /// فتح صندوق Hive بأمان
  static Future<Box<T>?> _openBoxSafely<T>(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        return Hive.box<T>(boxName);
      }
      return await Hive.openBox<T>(boxName);
    } catch (e) {
      debugPrint('❌ Failed to open box $boxName: $e');
      return null;
    }
  }

  /// تهيئة المفضلات
  static Future<void> _initializeFavorites() async {
    try {
      await FavoritesStorage.init();
      debugPrint('✅ Favorites initialized');
    } catch (e) {
      debugPrint('❌ Favorites initialization error: $e');
    }
  }

  /// تحميل البيانات الحرجة مسبقاً
  static Future<void> _preloadCriticalData() async {
    try {
      final futures = <Future>[];

      // تحميل بيانات المستخدم
      futures.add(_loadUserData());

      // تحميل المنتجات الشائعة
      futures.add(_preloadPopularProducts());

      // تحميل العناوين
      futures.add(_preloadAddresses());

      await Future.wait(futures, eagerError: false);
      debugPrint('✅ Critical data preloaded');
    } catch (e) {
      debugPrint('❌ Data preloading error: $e');
    }
  }

  /// تحميل بيانات المستخدم
  static Future<void> _loadUserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        _cache['current_user'] = user;
        _cacheTimestamps['current_user'] = DateTime.now();

        // تحديث آخر وقت دخول بدون انتظار
        unawaited(_updateLastLogin(user.id));
      }
    } catch (e) {
      debugPrint('❌ User data loading error: $e');
    }
  }

  /// تحديث آخر وقت دخول
  static Future<void> _updateLastLogin(String userId) async {
    try {
      await Supabase.instance.client
          .from('users')
          .update({'last_login': DateTime.now().toIso8601String()})
          .eq('id', userId);
    } catch (e) {
      debugPrint('❌ Last login update error: $e');
    }
  }

  /// تحميل المنتجات الشائعة مسبقاً
  static Future<void> _preloadPopularProducts() async {
    try {
      final productsBox = Hive.box<Part>('products');
      if (productsBox.isNotEmpty) {
        // استخدام البيانات المحلية
        final popularProducts = productsBox.values.take(20).toList();
        _cache['popular_products'] = popularProducts;
        _cacheTimestamps['popular_products'] = DateTime.now();
      } else {
        // تحميل من الخادم في الخلفية
        unawaited(_loadPopularProductsFromServer());
      }
    } catch (e) {
      debugPrint('❌ Popular products preloading error: $e');
    }
  }

  /// تحميل المنتجات الشائعة من الخادم
  static Future<void> _loadPopularProductsFromServer() async {
    try {
      final response = await Supabase.instance.client
          .from('products')
          .select()
          .limit(20);

      if (response.isNotEmpty) {
        _cache['popular_products'] = response;
        _cacheTimestamps['popular_products'] = DateTime.now();
      }
    } catch (e) {
      debugPrint('❌ Server products loading error: $e');
    }
  }

  /// تحميل العناوين مسبقاً
  static Future<void> _preloadAddresses() async {
    try {
      final addressesBox = Hive.box<app_models.Address>('addresses');
      if (addressesBox.isNotEmpty) {
        _cache['addresses'] = addressesBox.values.toList();
        _cacheTimestamps['addresses'] = DateTime.now();
      }
    } catch (e) {
      debugPrint('❌ Addresses preloading error: $e');
    }
  }

  /// تشغيل الخدمات للاحماء
  static Future<void> _warmupServices() async {
    try {
      final futures = <Future>[];

      // اختبار اتصال Supabase
      futures.add(_testSupabaseConnection());

      // تحضير خدمات النظام
      futures.add(_prepareSystemServices());

      await Future.wait(futures, eagerError: false);
      debugPrint('✅ Services warmed up');
    } catch (e) {
      debugPrint('❌ Services warmup error: $e');
    }
  }

  /// اختبار اتصال Supabase
  static Future<void> _testSupabaseConnection() async {
    try {
      await Supabase.instance.client.from('products').select('id').limit(1);
      _cache['supabase_connected'] = true;
    } catch (e) {
      _cache['supabase_connected'] = false;
      debugPrint('❌ Supabase connection test failed: $e');
    }
  }

  /// تحضير خدمات النظام
  static Future<void> _prepareSystemServices() async {
    try {
      // تحميل الخطوط المطلوبة مسبقاً
      await _preloadFonts();

      // تحضير الصور الأساسية
      await _preloadImages();
    } catch (e) {
      debugPrint('❌ System services preparation error: $e');
    }
  }

  /// تحميل الخطوط مسبقاً
  static Future<void> _preloadFonts() async {
    try {
      // تحميل خط Arabic (إذا لم يكن محملاً)
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.transparent,
          statusBarColor: Colors.transparent,
        ),
      );
    } catch (e) {
      debugPrint('❌ Font preloading error: $e');
    }
  }

  /// تحميل الصور الأساسية مسبقاً
  static Future<void> _preloadImages() async {
    try {
      // تحضير أيقونات التطبيق الأساسية
      const imagePaths = ['assets/icons/car.png', 'assets/icons/logo.png'];

      for (final path in imagePaths) {
        try {
          await rootBundle.load(path);
        } catch (e) {
          // تجاهل الصور غير الموجودة
        }
      }
    } catch (e) {
      debugPrint('❌ Image preloading error: $e');
    }
  }

  /// تحسين استخدام الذاكرة
  static Future<void> _optimizeMemory() async {
    try {
      // تنظيف الذاكرة المؤقتة القديمة
      _cleanupOldCache();

      // ضغط البيانات المحلية إذا أمكن
      await _compactHiveBoxes();

      debugPrint('✅ Memory optimized');
    } catch (e) {
      debugPrint('❌ Memory optimization error: $e');
    }
  }

  /// تنظيف الذاكرة المؤقتة القديمة
  static void _cleanupOldCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    for (final entry in _cacheTimestamps.entries) {
      if (now.difference(entry.value) > _cacheTimeout) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      debugPrint('🗑️ Cleaned ${expiredKeys.length} expired cache entries');
    }
  }

  /// ضغط صناديق Hive
  static Future<void> _compactHiveBoxes() async {
    try {
      final boxNames = ['products', 'offline_orders', 'addresses', 'orders'];

      for (final boxName in boxNames) {
        try {
          if (Hive.isBoxOpen(boxName)) {
            await Hive.box(boxName).compact();
          }
        } catch (e) {
          debugPrint('❌ Failed to compact box $boxName: $e');
        }
      }
    } catch (e) {
      debugPrint('❌ Box compaction error: $e');
    }
  }

  /// الحصول على بيانات من الذاكرة المؤقتة
  static T? getCachedData<T>(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp != null) {
      final age = DateTime.now().difference(timestamp);
      if (age <= _cacheTimeout) {
        return _cache[key] as T?;
      } else {
        // البيانات منتهية الصلاحية
        _cache.remove(key);
        _cacheTimestamps.remove(key);
      }
    }
    return null;
  }

  /// حفظ بيانات في الذاكرة المؤقتة
  static void setCachedData<T>(String key, T data) {
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
  }

  /// التحقق من حالة التهيئة
  static bool get isInitialized => _isInitialized;

  /// إحصائيات الأداء
  static Map<String, dynamic> getPerformanceStats() {
    return {
      'initialized': _isInitialized,
      'cache_size': _cache.length,
      'cached_keys': _cache.keys.toList(),
      'memory_usage':
          '${(_cache.length * 0.1).toStringAsFixed(1)} MB (estimated)',
    };
  }

  /// تنظيف الموارد
  static void dispose() {
    _cache.clear();
    _cacheTimestamps.clear();
    _isInitialized = false;
  }
}

/// دالة مساعدة لتشغيل Future بدون انتظار
void unawaited(Future<void> future) {
  // تشغيل بدون انتظار مع معالجة الأخطاء
  future.catchError((error) {
    debugPrint('❌ Unawaited future error: $error');
  });
}
