import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pages/splash_page.dart';
import '../pages/login_page.dart';
import '../pages/home_page.dart';
import '../providers/preferences_provider.dart';

class AutoPartsApp extends ConsumerWidget {
  const AutoPartsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferencesProvider);

    return MaterialApp(
      title: 'Auto Parts',
      themeMode: preferences.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFF1978E5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1978E5),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.notoSansArabicTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF111418),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF111418),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF1978E5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1978E5),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.notoSansArabicTextTheme(
          ThemeData.dark().textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF1978E5),
          unselectedItemColor: Color(0xFF637488),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => LoginPage(
          onSuccess: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        '/home': (context) => const HomePage(),
        // أضف باقي الصفحات هنا بعد إنشائها
      },
    );
  }
}
