import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});
  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  int totalOrders = 0;
  int totalProducts = 0;
  double totalSales = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => loading = true);
    final orders = await Supabase.instance.client.from('orders').select();
    final products = await Supabase.instance.client.from('products').select();
    totalOrders = orders.length;
    totalProducts = products.length;
    totalSales = orders.fold(0, (sum, o) => sum + (o['total_price'] ?? 0));
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('الإحصائيات', style: GoogleFonts.cairo())),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إجمالي الطلبات: $totalOrders',
                    style: GoogleFonts.cairo(fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'إجمالي المنتجات: $totalProducts',
                    style: GoogleFonts.cairo(fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'إجمالي المبيعات: $totalSales د.ع',
                    style: GoogleFonts.cairo(fontSize: 18, color: Colors.green),
                  ),
                ],
              ),
            ),
    );
  }
}
