import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class PartDetailsPage extends StatelessWidget {
  final int partId;
  final String partName;
  final String? partImage;
  final dynamic partPrice;
  final String? partCurrency;

  const PartDetailsPage({
    super.key,
    required this.partId,
    required this.partName,
    this.partImage,
    required this.partPrice,
    this.partCurrency,
  });

  @override
  Widget build(BuildContext context) {
    // (مثال) وصف افتراضي - يمكن جلبه من قاعدة البيانات
    String description = 'part_description_example'.tr(args: [partName]);
    String priceText = "$partPrice ${partCurrency ?? ""}";

    return Scaffold(
      appBar: AppBar(
        title: Text(partName, style: const TextStyle(color: Color(0xFF181111))),
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            if (partImage != null)
              Container(
                height: 180,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: const Color(0xFFF5F0F0),
                  image: DecorationImage(
                    image: NetworkImage(partImage!),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            Text(
              partName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF181111),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(fontSize: 16, color: Color(0xFF181111)),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Text(
                  'price'.tr(),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF181111),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  priceText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF93838),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
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
                  // TODO: أضف للسلة (حسب القاعدة لاحقًا)
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('added_to_cart'.tr())));
                },
                child: Text(
                  'add_to_cart'.tr(),
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
      bottomNavigationBar: BottomNavBar(current: 0),
    );
  }
}

// شريط التنقل ووايدجت اختيار اللغة كما في الصفحات السابقة
class BottomNavBar extends StatelessWidget {
  final int current;
  const BottomNavBar({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: current,
      onTap: (index) {
        if (index == 0)
          Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
        if (index == 1) Navigator.pushNamed(context, '/orders');
        if (index == 2) Navigator.pushNamed(context, '/profile');
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
            color: current == 0 ? Color(0xFFF93838) : Color(0xFF8c5f5f),
          ),
          label: 'home'.tr(),
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.list_alt,
            color: current == 1 ? Color(0xFFF93838) : Color(0xFF8c5f5f),
          ),
          label: 'orders'.tr(),
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.person,
            color: current == 2 ? Color(0xFFF93838) : Color(0xFF8c5f5f),
          ),
          label: 'account'.tr(),
        ),
      ],
      selectedItemColor: const Color(0xFFF93838),
      unselectedItemColor: const Color(0xFF8c5f5f),
      showUnselectedLabels: true,
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
