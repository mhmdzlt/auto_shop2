import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  List<dynamic> orders = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => loading = true);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      setState(() {
        orders = [];
        loading = false;
      });
      return;
    }
    final response = await Supabase.instance.client
        .from('orders')
        .select()
        .eq('user_id', userId)
        .not('payment_type', 'is', null)
        .order('created_at', ascending: false);
    setState(() {
      orders = response;
      loading = false;
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'paid':
        return Icons.check_circle;
      case 'pending':
        return Icons.hourglass_top;
      case 'failed':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تاريخ العمليات المالية'.tr())),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? Center(child: Text('لا توجد عمليات دفع مسجلة'.tr()))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (_, i) {
                final o = orders[i];
                return Card(
                  child: ListTile(
                    leading: Icon(
                      _statusIcon(o['payment_status']),
                      color: _statusColor(o['payment_status']),
                    ),
                    title: Text('${o['total_price']} ${'currency'.tr()}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('طريقة الدفع: ${o['payment_type'] ?? '-'}'),
                        Text('الحالة: ${o['payment_status'] ?? '-'}'),
                        Text(
                          'تاريخ الإنشاء: ${o['created_at']?.toString().substring(0, 16) ?? '-'}',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
