import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageOrdersPage extends StatefulWidget {
  const ManageOrdersPage({Key? key}) : super(key: key);
  @override
  State<ManageOrdersPage> createState() => _ManageOrdersPageState();
}

class _ManageOrdersPageState extends State<ManageOrdersPage> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    final response = await Supabase.instance.client.from('orders').select();
    setState(() {
      _orders = response;
      _isLoading = false;
    });
  }

  Future<void> _updateOrderStatus(int id, String status) async {
    await Supabase.instance.client
        .from('orders')
        .update({'status': status})
        .eq('id', id);
    _fetchOrders();
  }

  void _showOrderDetails(dynamic order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل الطلب', style: GoogleFonts.cairo()),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('رقم الطلب: ${order['id']}', style: GoogleFonts.cairo()),
              Text('المستخدم: ${order['user_id']}', style: GoogleFonts.cairo()),
              Text(
                'الإجمالي: ${order['total_price']} د.ع',
                style: GoogleFonts.cairo(),
              ),
              Text('الحالة: ${order['status']}', style: GoogleFonts.cairo()),
              Text(
                'العنوان: ${order['address_id']}',
                style: GoogleFonts.cairo(),
              ),
              Text(
                'المنتجات: ${order['order_items']}',
                style: GoogleFonts.cairo(),
              ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إدارة الطلبات', style: GoogleFonts.cairo())),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _orders.length,
              itemBuilder: (context, i) {
                final o = _orders[i];
                return ListTile(
                  title: Text('طلب #${o['id']}', style: GoogleFonts.cairo()),
                  subtitle: Text(
                    'الحالة: ${o['status']}',
                    style: GoogleFonts.cairo(),
                  ),
                  trailing: DropdownButton<String>(
                    value: o['status'],
                    items:
                        [
                              'pending',
                              'confirmed',
                              'inProgress',
                              'shipped',
                              'delivered',
                              'cancelled',
                            ]
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                    onChanged: (val) {
                      if (val != null) _updateOrderStatus(o['id'], val);
                    },
                  ),
                  onTap: () => _showOrderDetails(o),
                );
              },
            ),
    );
  }
}
