import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../services/invoice_service_new.dart';

class MyInvoicesPage extends StatefulWidget {
  const MyInvoicesPage({super.key});

  @override
  State<MyInvoicesPage> createState() => _MyInvoicesPageState();
}

class _MyInvoicesPageState extends State<MyInvoicesPage> {
  List<Map<String, dynamic>> orders = [];
  final supabase = Supabase.instance.client;
  bool loading = true;

  Future<void> fetchDeliveredOrders() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    final response = await supabase
        .from('orders')
        .select()
        .eq('user_id', user.id)
        .eq('status', 'delivered')
        .order('created_at', ascending: false);

    setState(() {
      orders = List<Map<String, dynamic>>.from(response);
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchDeliveredOrders();
  }

  Future<void> generateInvoice(Map<String, dynamic> order) async {
    // جلب بيانات المنتجات للفاتورة
    final items = order['items'] ?? [];
    final pdfData = await InvoiceService.generateInvoicePdf(
      orderId: order['id'].toString(),
      orderDetails: {
        'user_name': order['user_name'] ?? '',
        'date': order['created_at'],
        'items': items,
        'total': order['total'] ?? order['total_price'] ?? 0,
      },
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/invoice_${order['id']}.pdf');
    await file.writeAsBytes(pdfData);
    await OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📄 فواتيري")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? const Center(child: Text("لا توجد فواتير متاحة"))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  child: ListTile(
                    title: Text("طلب رقم: ${order['id'] ?? ''}"),
                    subtitle: Text(
                      "المجموع: \$${order['total'] ?? order['total_price'] ?? 0}",
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.picture_as_pdf),
                      onPressed: () => generateInvoice(order),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
