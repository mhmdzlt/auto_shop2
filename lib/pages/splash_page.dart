import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../favorites_storage.dart';
import '../services/performance_service.dart';
import 'products_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // إعداد الرسوم المتحركة
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();

    // تحميل البيانات في الخلفية
    _initializeApp();
  }

  /// تهيئة التطبيق وتحميل البيانات الأساسية
  Future<void> _initializeApp() async {
    final startTime = DateTime.now();

    try {
      // استخدام خدمة الأداء للتهيئة المحسنة

      // تشغيل التهيئة والحد الأدنى من وقت العرض بالتوازي
      await Future.wait([
        Future.delayed(const Duration(seconds: 2)), // حد أدنى لعرض الشاشة
        PerformanceService.initializeApp(),
        _loadCriticalData(),
      ]);

      final initTime = DateTime.now().difference(startTime).inMilliseconds;
      debugPrint('🚀 Splash initialization completed in ${initTime}ms');

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const ProductsPage(),
            transitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0.0, 0.1),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOut,
                            ),
                          ),
                      child: child,
                    ),
                  );
                },
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error initializing app: $e');
      // في حالة الخطأ، انتقل للصفحة الرئيسية بعد ثانية واحدة
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ProductsPage()),
        );
      }
    }
  }

  /// تحميل البيانات الحرجة فقط
  Future<void> _loadCriticalData() async {
    await Future.wait([
      _loadCurrentUser(),
      _initializeFavorites(),
    ], eagerError: false);
  }

  /// تحميل بيانات المستخدم الحالي
  Future<void> _loadCurrentUser() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // تحديث آخر وقت دخول (غير متزامن)
        Supabase.instance.client
            .from('users')
            .update({'last_login': DateTime.now().toIso8601String()})
            .eq('id', user.id)
            .then((_) => debugPrint('✅ User last login updated'))
            .catchError((e) => debugPrint('❌ Error updating last login: $e'));
      }
    } catch (e) {
      debugPrint('❌ Error loading user: $e');
    }
  }

  /// تهيئة نظام المفضلات
  Future<void> _initializeFavorites() async {
    try {
      await FavoritesStorage.init();
      debugPrint('✅ Favorites initialized');
    } catch (e) {
      debugPrint('❌ Error initializing favorites: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // شعار التطبيق
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF93838),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFF93838,
                            ).withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.directions_car,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // اسم التطبيق
                    const Text(
                      'Auto Shop',
                      style: TextStyle(
                        color: Color(0xFF181111),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // وصف التطبيق
                    Text(
                      'Your trusted car parts store',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 50),

                    // مؤشر التحميل
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFFF93838),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
