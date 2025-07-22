import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminStatsPage extends StatefulWidget {
  const AdminStatsPage({super.key});

  @override
  State<AdminStatsPage> createState() => _AdminStatsPageState();
}

class _AdminStatsPageState extends State<AdminStatsPage> {
  int userCount = 0;
  int orderCount = 0;
  int promoUsedCount = 0;
  List<Map<String, dynamic>> topRatedProducts = [];
  List<Map<String, dynamic>> topSellingProducts = [];
  bool loading = true;

  Future<void> fetchStats() async {
    setState(() => loading = true);
    final users = await Supabase.instance.client.from('users').select();
    final orders = await Supabase.instance.client.from('orders').select();
    final promos = await Supabase.instance.client.from('promo_codes').select();

    // أكثر المنتجات تقييماً
    final topRated = await Supabase.instance.client
        .rpc('top_rated_products') // استخدم دالة مخصصة أو استعلام group by
        .select();
    // أكثر المنتجات مبيعاً
    final topSelling = await Supabase.instance.client
        .rpc('top_selling_products') // استخدم دالة مخصصة أو استعلام group by
        .select();

    setState(() {
      userCount = users.length;
      orderCount = orders.length;
      promoUsedCount = promos.length; // عدّل إذا كان هناك جدول usage
      topRatedProducts = List<Map<String, dynamic>>.from(topRated ?? []);
      topSellingProducts = List<Map<String, dynamic>>.from(topSelling ?? []);
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📊 إحصائيات التطبيق")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatCard(
                    title: "عدد المستخدمين",
                    value: userCount.toString(),
                  ),
                  StatCard(
                    title: "إجمالي الطلبات",
                    value: orderCount.toString(),
                  ),
                  StatCard(
                    title: "أكواد الخصم المستخدمة",
                    value: promoUsedCount.toString(),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "أكثر المنتجات تقييماً:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...topRatedProducts.map(
                    (p) => ListTile(
                      title: Text(p['name'] ?? ''),
                      subtitle: Text(
                        "تقييم: ${p['avg_rating'] ?? '-'} (${p['reviews_count'] ?? 0} تقييم)",
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "الأكثر مبيعاً:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...topSellingProducts.map(
                    (p) => ListTile(
                      title: Text(p['name'] ?? ''),
                      subtitle: Text("مبيعات: ${p['sales_count'] ?? 0}"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  const StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}
