import 'package:flutter/material.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('لوحة الإدارة')),
      body: Center(child: Text('واجهة إدارة الطلبات والمنتجات قيد التطوير...')),
    );
  }
}
