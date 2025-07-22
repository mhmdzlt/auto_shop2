import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DevDashboardPage extends StatefulWidget {
  const DevDashboardPage({super.key});

  @override
  State<DevDashboardPage> createState() => _DevDashboardPageState();
}

class _DevDashboardPageState extends State<DevDashboardPage> {
  String? selectedCategory;

  final List<Map<String, dynamic>> orders = const [
    {
      'id': 30,
      'title': 'بناء التطبيق من الألف إلى الياء',
      'status': '✅',
      'category': 'أساسي',
    },
    {
      'id': 31,
      'title': 'تصميم الصفحة الرئيسية HomePage',
      'status': '✅',
      'category': 'واجهة',
    },
    {
      'id': 32,
      'title': 'صفحة التصنيفات والمنتجات والتفاصيل',
      'status': '✅',
      'category': 'واجهة',
    },
    {
      'id': 33,
      'title': 'صفحة البحث الذكي SearchPage',
      'status': '✅',
      'category': 'واجهة',
    },
    {
      'id': 34,
      'title': 'تنفيذ الطلب والدفع واختبار End-to-End',
      'status': '✅',
      'category': 'دفع',
    },
    {
      'id': 35,
      'title': 'لوحة المشرف لإدارة المنتجات والطلبات',
      'status': '✅',
      'category': 'إدارة',
    },
    {
      'id': 36,
      'title': 'نظام التقييمات والمراجعات',
      'status': '✅',
      'category': 'تفاعل',
    },
    {
      'id': 37,
      'title': 'تحسين الأداء عبر Caching و Lazy Loading',
      'status': '✅',
      'category': 'أداء',
    },
    {
      'id': 38,
      'title': 'شاشة Splash والشعار المتحرك',
      'status': '✅',
      'category': 'واجهة',
    },
    {
      'id': 39,
      'title': 'الاختبار النهائي قبل النشر',
      'status': '✅',
      'category': 'اختبار',
    },
    {
      'id': 40,
      'title': 'إصدار النسخة التجريبية ورفعها',
      'status': '✅',
      'category': 'نشر',
    },
    {
      'id': 41,
      'title': 'المنتجات المشابهة',
      'status': '✅',
      'category': 'ميزات',
    },
    {
      'id': 42,
      'title': 'وصل حديثًا ومنتجات موصى بها',
      'status': '✅',
      'category': 'ميزات',
    },
    {
      'id': 43,
      'title': 'صفحة الأسئلة الشائعة FAQ',
      'status': '✅',
      'category': 'دعم',
    },
    {
      'id': 44,
      'title': 'بوابة الدفع الإلكتروني',
      'status': '⏳',
      'category': 'دفع',
    },
    {
      'id': 45,
      'title': 'شاشة تاريخ العمليات المالية',
      'status': '✅',
      'category': 'دفع',
    },
    {
      'id': 46,
      'title': 'لوحة العروض الترويجية Flash Deals',
      'status': '✅',
      'category': 'ميزات',
    },
    {
      'id': 47,
      'title': 'قسم وصل حديثًا وموصى بها',
      'status': '✅',
      'category': 'ميزات',
    },
    {
      'id': 48,
      'title': 'تحسين تجربة السلة والملخص النهائي',
      'status': '✅',
      'category': 'واجهة',
    },
    {
      'id': 49,
      'title': 'تحسين واجهة المستخدم والـ UX النهائي',
      'status': '✅',
      'category': 'واجهة',
    },
    {
      'id': 50,
      'title': 'صفحة معلومات عن التطبيق',
      'status': '✅',
      'category': 'دعم',
    },
    {
      'id': 51,
      'title': 'ربط جميع الصفحات داخل التنقل',
      'status': '✅',
      'category': 'واجهة',
    },
    {
      'id': 52,
      'title': 'تصميم BottomNavigation برسوم متحركة',
      'status': '✅',
      'category': 'واجهة',
    },
    {
      'id': 53,
      'title': 'صفحة سياسة الخصوصية',
      'status': '✅',
      'category': 'قانوني',
    },
    {
      'id': 54,
      'title': 'إشعارات الدفع والمراجعة',
      'status': '✅',
      'category': 'تفاعل',
    },
    {
      'id': 55,
      'title': 'دعم اللغة الكردية الكامل',
      'status': '✅',
      'category': 'ترجمة',
    },
    {
      'id': 56,
      'title': 'الربط الفعلي بـ Stripe/FastPay',
      'status': '⏳',
      'category': 'دفع',
    },
    {
      'id': 57,
      'title': 'مركز الترويج والإعلانات',
      'status': '✅',
      'category': 'ميزات',
    },
    {
      'id': 58,
      'title': 'لوحة إدارة خارجية Web (اختياري)',
      'status': '⏳',
      'category': 'إدارة',
    },
    {
      'id': 59,
      'title': 'إصلاح HiveError وتسجيل TypeAdapters',
      'status': '✅',
      'category': 'إصلاح',
    },
    {
      'id': 60,
      'title': 'تجميع تسجيلات Hive في ملف مستقل',
      'status': '✅',
      'category': 'تنظيف',
    },
    {
      'id': 61,
      'title': 'تنظيف شامل للمشروع',
      'status': '✅',
      'category': 'تنظيف',
    },
    {
      'id': 62,
      'title': 'تحليل شامل للأخطاء والتحذيرات',
      'status': '✅',
      'category': 'جودة',
    },
    {
      'id': 63,
      'title': 'تشغيل GitHub Actions Workflow',
      'status': '✅',
      'category': 'أتمتة',
    },
    {
      'id': 64,
      'title': 'التحضير للنشر على Google Play',
      'status': '✅',
      'category': 'نشر',
    },
    {
      'id': 65,
      'title': 'إصلاح أخطاء register_page و checkout_page',
      'status': '✅',
      'category': 'إصلاح',
    },
    {
      'id': 66,
      'title': 'خطة تطوير بعد الإطلاق',
      'status': '✅',
      'category': 'تخطيط',
    },
    {
      'id': 67,
      'title': 'تفعيل الدفع الحقيقي',
      'status': '⏳',
      'category': 'دفع',
    },
    {
      'id': 68,
      'title': 'لوحة تحكم Web للمشرف',
      'status': '⏳',
      'category': 'إدارة',
    },
    {
      'id': 69,
      'title': 'نظام الفواتير PDF',
      'status': '⏳',
      'category': 'ميزات',
    },
    {
      'id': 70,
      'title': 'GitHub Actions للتحليل الشامل',
      'status': '✅',
      'category': 'أتمتة',
    },
    {
      'id': 71,
      'title': 'لوحة تحكم داخل التطبيق (Dashboard)',
      'status': '✅',
      'category': 'إدارة',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredOrders = selectedCategory == null
        ? orders
        : orders
              .where((order) => order['category'] == selectedCategory)
              .toList();

    final completedOrders = filteredOrders
        .where((order) => order['status'] == '✅')
        .length;
    final inProgressOrders = filteredOrders
        .where((order) => order['status'] == '⏳')
        .length;
    final totalOrders = filteredOrders.length;
    final completionPercentage = totalOrders > 0
        ? ((completedOrders / totalOrders) * 100).round()
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'لوحة تطوير التطبيق',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1978E5),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showProjectInfo(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // إحصائيات المشروع
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1978E5), Color(0xFF42A5F5)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'مشروع Auto Shop',
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      'المكتمل',
                      '$completedOrders',
                      '✅',
                      Colors.green,
                    ),
                    _buildStatCard(
                      'قيد التنفيذ',
                      '$inProgressOrders',
                      '⏳',
                      Colors.orange,
                    ),
                    _buildStatCard(
                      'الإجمالي',
                      '$totalOrders',
                      '📋',
                      Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'نسبة الإنجاز: $completionPercentage%',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: completionPercentage / 100,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        minHeight: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // فلتر الفئات
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryChip('الكل', null),
                _buildCategoryChip('أساسي', 'أساسي'),
                _buildCategoryChip('واجهة', 'واجهة'),
                _buildCategoryChip('دفع', 'دفع'),
                _buildCategoryChip('إدارة', 'إدارة'),
                _buildCategoryChip('ميزات', 'ميزات'),
                _buildCategoryChip('إصلاح', 'إصلاح'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // قائمة الأوامر
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                return _buildOrderCard(order);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String emoji, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? category) {
    final isSelected = selectedCategory == category;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
        selected: isSelected,
        selectedColor: const Color(0xFF1978E5),
        onSelected: (selected) {
          setState(() {
            selectedCategory = selected ? category : null;
          });
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    Color statusColor;
    IconData statusIcon;

    switch (order['status']) {
      case '✅':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case '⏳':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        break;
      case '❌':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              '#${order['id']}',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: statusColor,
                fontSize: 12,
              ),
            ),
          ),
        ),
        title: Text(
          order['title'],
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1978E5).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                order['category'],
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  color: const Color(0xFF1978E5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(statusIcon, color: statusColor, size: 24),
            const SizedBox(height: 4),
            Text(
              order['status'],
              style: TextStyle(fontSize: 16, color: statusColor),
            ),
          ],
        ),
        onTap: () => _showOrderDetails(order),
      ),
    );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تفاصيل الأمر #${order['id']}',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'العنوان:',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              Text(order['title'], style: GoogleFonts.cairo()),
              const SizedBox(height: 16),
              Text(
                'الفئة:',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1978E5).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order['category'],
                  style: GoogleFonts.cairo(
                    color: const Color(0xFF1978E5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'الحالة:',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Text(order['status'], style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    _getStatusText(order['status']),
                    style: GoogleFonts.cairo(
                      color: _getStatusColor(order['status']),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (order['status'] == '✅') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'تم إنجاز هذا الأمر بنجاح',
                          style: GoogleFonts.cairo(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (order['status'] == '⏳') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'هذا الأمر قيد التنفيذ حالياً',
                          style: GoogleFonts.cairo(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case '✅':
        return 'مكتمل';
      case '⏳':
        return 'قيد التنفيذ';
      case '❌':
        return 'غير مكتمل';
      default:
        return 'غير معروف';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '✅':
        return Colors.green;
      case '⏳':
        return Colors.orange;
      case '❌':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showProjectInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'معلومات المشروع',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎯 مشروع Auto Shop',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'تطبيق متجر قطع غيار السيارات مع نظام إدارة شامل',
              style: GoogleFonts.cairo(),
            ),
            const SizedBox(height: 16),
            Text(
              '📱 التقنيات المستخدمة:',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
            Text('• Flutter & Dart', style: GoogleFonts.cairo()),
            Text('• Supabase (Backend)', style: GoogleFonts.cairo()),
            Text('• Hive (Local Storage)', style: GoogleFonts.cairo()),
            Text('• Riverpod (State Management)', style: GoogleFonts.cairo()),
            Text('• Easy Localization', style: GoogleFonts.cairo()),
            const SizedBox(height: 16),
            Text(
              '🚀 الحالة: جاهز للإنتاج',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }
}
