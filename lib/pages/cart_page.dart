import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // مثال: بيانات سلة مؤقتة (لاحقاً تربط مع مزود بيانات حقيقي)
  List<Map<String, dynamic>> cartItems = [
    {
      'id': 101,
      'name': 'Front Bumper',
      'image': 'https://cdn-icons-png.flaticon.com/512/149/149995.png',
      'price': 90,
      'currency': '\$',
      'qty': 1,
    },
    {
      'id': 102,
      'name': 'Engine Oil Filter',
      'image': 'https://cdn-icons-png.flaticon.com/512/3043/3043317.png',
      'price': 12,
      'currency': '\$',
      'qty': 2,
    },
  ];

  void incrementQty(int index) {
    setState(() {
      cartItems[index]['qty'] += 1;
    });
  }

  void decrementQty(int index) {
    setState(() {
      if (cartItems[index]['qty'] > 1) {
        cartItems[index]['qty'] -= 1;
      } else {
        cartItems.removeAt(index);
      }
    });
  }

  void removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  double getTotal() {
    double sum = 0;
    for (final item in cartItems) {
      sum += item['price'] * item['qty'];
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'cart'.tr(),
          style: const TextStyle(color: Color(0xFF181111)),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF181111)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: LanguageSelector(),
          ),
        ],
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Text(
                'cart_empty'.tr(),
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              itemCount: cartItems.length,
              separatorBuilder: (context, i) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final item = cartItems[i];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(item['image']),
                      radius: 28,
                      backgroundColor: const Color(0xFFF5F0F0),
                    ),
                    title: Text(
                      item['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${item['price']} ${item['currency']}',
                      style: const TextStyle(
                        color: Color(0xFFF93838),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => decrementQty(i),
                          icon: const Icon(
                            Icons.remove_circle,
                            color: Color(0xFF8c5f5f),
                          ),
                        ),
                        Text(
                          '${item['qty']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => incrementQty(i),
                          icon: const Icon(
                            Icons.add_circle,
                            color: Color(0xFFF93838),
                          ),
                        ),
                        IconButton(
                          onPressed: () => removeItem(i),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'total'.tr(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "${getTotal().toStringAsFixed(2)} \$", // العملة مثال
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Color(0xFFF93838),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF93838),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/checkout');
                      },
                      child: Text(
                        'checkout'.tr(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class LanguageSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final locales = [
      {'locale': const Locale('ar'), 'name': 'العربية'},
      {'locale': const Locale('en'), 'name': 'English'},
      {'locale': const Locale('ku'), 'name': 'کوردی'},
    ];
    return DropdownButton<Locale>(
      value: context.locale,
      underline: const SizedBox(),
      icon: const Icon(Icons.language, color: Color(0xFF8c5f5f)),
      onChanged: (locale) {
        context.setLocale(locale!);
      },
      items: locales
          .map(
            (e) => DropdownMenuItem(
              value: e['locale'] as Locale,
              child: Text(e['name'] as String),
            ),
          )
          .toList(),
    );
  }
}
