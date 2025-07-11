import 'package:flutter/material.dart';
import '../pages/splash_page.dart';
import '../pages/login_page.dart';
import '../pages/home_page.dart';

class AutoPartsApp extends StatelessWidget {
  const AutoPartsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Parts',
      theme: ThemeData.dark(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        // أضف باقي الصفحات هنا بعد إنشائها
      },
    );
  }
}
