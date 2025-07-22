import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class BrandSectionsPage extends StatelessWidget {
  final int brandId;
  final String brandName;
  final String? brandLogo;

  const BrandSectionsPage({
    super.key,
    required this.brandId,
    required this.brandName,
    this.brandLogo,
  });

  @override
  Widget build(BuildContext context) {
    // أقسام مثال، ويمكنك لاحقًا جلبها من قاعدة البيانات حسب brandId
    final List<Map<String, dynamic>> sections = [
      {
        'id': 1,
        'name': 'body_section'.tr(),
        'image': 'https://cdn-icons-png.flaticon.com/512/181/181546.png',
      },
      {
        'id': 2,
        'name': 'engine_section'.tr(),
        'image': 'https://cdn-icons-png.flaticon.com/512/181/181554.png',
      },
      {
        'id': 3,
        'name': 'interior_section'.tr(),
        'image': 'https://cdn-icons-png.flaticon.com/512/181/181555.png',
      },
      {
        'id': 4,
        'name': 'wheels_section'.tr(),
        'image': 'https://cdn-icons-png.flaticon.com/512/181/181548.png',
      },
      // أضف أو عدل حسب الحاجة
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$brandName - ${'car_sections'.tr()}',
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: sections.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: .95,
          ),
          itemBuilder: (context, i) {
            final section = sections[i];
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/section_parts',
                  arguments: {
                    'sectionId': section['id'],
                    'sectionName': section['name'],
                    'sectionImage': section['image'],
                  },
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 10,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(section['image']),
                        radius: 36,
                        backgroundColor: const Color(0xFFF5F0F0),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        section['name'],
                        style: const TextStyle(
                          color: Color(0xFF181111),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavBar(current: 0),
    );
  }
}

// نفس ما استخدمناه في الصفحة الرئيسية:
class BottomNavBar extends StatelessWidget {
  final int current;
  const BottomNavBar({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: current,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
        }
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

// ويدجت اختيار اللغة
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

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
