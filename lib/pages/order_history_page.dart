import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> orders = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() {
        loading = false;
        orders = [];
      });
      return;
    }
    setState(() => loading = true);
    final response = await supabase
        .from('orders')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
    setState(() {
      orders = List<Map<String, dynamic>>.from(response);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('سجل الطلبات')),
      body: orders.isEmpty
          ? const Center(child: Text('لا توجد طلبات'))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('طلب #${order['id']}'),
                    subtitle: Text('الحالة: ${order['status'] ?? '---'}'),
                    trailing: Text(order['created_at']?.toString().split('T').first ?? ''),
                  ),
                );
              },
            ),
    );
  }
}
