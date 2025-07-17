import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDashboardPage extends StatelessWidget {
  final bool isAdmin;
  const AdminDashboardPage({Key? key, required this.isAdmin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text('لوحة المشرف', style: GoogleFonts.cairo())),
        body: Center(
          child: Text('ليس لديك صلاحية الوصول', style: GoogleFonts.cairo()),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('لوحة المشرف', style: GoogleFonts.cairo())),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.inventory),
            title: Text('إدارة المنتجات', style: GoogleFonts.cairo()),
            onTap: () => Navigator.pushNamed(context, '/admin/products'),
          ),
          ListTile(
            leading: Icon(Icons.receipt_long),
            title: Text('إدارة الطلبات', style: GoogleFonts.cairo()),
            onTap: () => Navigator.pushNamed(context, '/admin/orders'),
          ),
          ListTile(
            leading: Icon(Icons.bar_chart),
            title: Text('الإحصائيات', style: GoogleFonts.cairo()),
            onTap: () => Navigator.pushNamed(context, '/admin/stats'),
          ),
        ],
      ),
    );
  }
}
