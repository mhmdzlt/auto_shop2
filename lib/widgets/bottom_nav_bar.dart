import 'package:flutter/material.dart';
import 'products_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';

class BottomNav extends StatefulWidget {
  final int index;
  const BottomNav({super.key, required this.index});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  @override
  void initState() {
    _selectedIndex = widget.index;
    super.initState();
  }

  void _onTap(int i) {
    if (i == _selectedIndex) return;
    Widget page;
    switch (i) {
      case 0:
        page = const ProductsPage();
        break;
      case 1:
        page = const CartPage();
        break;
      default:
        page = const ProfilePage();
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF1978E5),
      unselectedItemColor: const Color(0xFF637488),
      onTap: _onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          label: 'السلة',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'الحساب',
        ),
      ],
    );
  }
}
