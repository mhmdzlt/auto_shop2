import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    setState(() => loading = true);
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      if (response.user != null) {
        Navigator.pushReplacementNamed(context, '/login');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('register_success'.tr())));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('register_failed'.tr())));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is AuthException ? e.message : 'register_failed'.tr(),
          ),
        ),
      );
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
        children: [
          const SizedBox(height: 40),
          Center(
            child: Text(
              'register_title'.tr(),
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF181111),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'email'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: const Color(0xFFF5F0F0),
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'password'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: const Color(0xFFF5F0F0),
            ),
          ),
          const SizedBox(height: 28),
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
              onPressed: loading ? null : register,
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'register'.tr(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, '/login'),
              child: Text(
                'have_account'.tr(),
                style: const TextStyle(
                  color: Color(0xFF8c5f5f),
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          Align(alignment: Alignment.centerRight, child: LanguageSelector()),
        ],
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
