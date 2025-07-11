import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SupportChatPage extends StatefulWidget {
  const SupportChatPage({super.key});

  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage> {
  final List<Map<String, String>> messages = [
    {'from': 'support', 'text': 'welcome_support'.tr()},
  ];
  final TextEditingController _controller = TextEditingController();
  bool sending = false;

  void sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      messages.add({'from': 'user', 'text': text});
      sending = true;
    });
    _controller.clear();

    // هنا يمكن ربط Supabase أو أي خدمة chat فعلية
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        messages.add({'from': 'support', 'text': 'reply_soon'.tr()});
        sending = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('support_chat'.tr()),
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF181111)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: LanguageSelector(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: messages.length,
              itemBuilder: (context, i) {
                final msg = messages[i];
                final isUser = msg['from'] == 'user';
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFFF93838)
                          : const Color(0xFFF5F0F0),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      msg['text'] ?? '',
                      style: TextStyle(
                        color: isUser ? Colors.white : const Color(0xFF181111),
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 2, thickness: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !sending,
                    decoration: InputDecoration(
                      hintText: 'type_message'.tr(),
                      filled: true,
                      fillColor: const Color(0xFFF5F0F0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(11),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 7,
                        horizontal: 14,
                      ),
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                const SizedBox(width: 7),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFF93838)),
                  onPressed: sending ? null : sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ويدجت اختيار اللغة
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
