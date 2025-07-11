import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    // bool isLoggedIn = Supabase.instance.client.auth.currentUser != null;
    bool isLoggedIn = false; // للتجربة، غيّرها بحسب منطقك

    if (!mounted) return;
    // ignore: dead_code
    if (isLoggedIn) {
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // شعار التطبيق (يمكنك تغييره لصورة شعارك)
            CircleAvatar(
              radius: 54,
              backgroundColor: const Color(0xFFF93838),
              child: const Icon(
                Icons.car_repair,
                color: Colors.white,
                size: 54,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'app_name'.tr(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF181111),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            const CircularProgressIndicator(color: Color(0xFFF93838)),
          ],
        ),
      ),
    );
  }
}
