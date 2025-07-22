import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupportChatPage extends StatefulWidget {
  const SupportChatPage({super.key});

  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage> {
  final TextEditingController _controller = TextEditingController();
  final supabase = Supabase.instance.client;
  late final String userId;
  bool sending = false;
  bool loading = true;
  List<Map<String, dynamic>> messages = [];
  late final Stream<List<Map<String, dynamic>>> chatStream;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final user = supabase.auth.currentUser;
    userId = user?.id ?? 'anonymous';
    await _fetchMessages();
    _subscribeToMessages();
  }

  Future<void> _fetchMessages() async {
    try {
      final res = await supabase
          .from('support_chat')
          .select()
          .order('created_at', ascending: true);
      if (mounted) {
        setState(() {
          messages = List<Map<String, dynamic>>.from(res);
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void _subscribeToMessages() {
    supabase
        .channel('public:support_chat')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'support_chat',
          callback: (payload) {
            final newMsg = payload.newRecord;
            if (newMsg.isNotEmpty && mounted) {
              setState(() {
                messages.add(newMsg);
              });
            }
          },
        )
        .subscribe();
  }

  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => sending = true);
    _controller.clear();
    try {
      await supabase.from('support_chat').insert({
        'user_id': userId,
        'from': 'user',
        'text': text,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('send_failed'.tr())));
      }
    } finally {
      if (mounted) {
        setState(() => sending = false);
      }
    }
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
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
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
                              color: isUser
                                  ? Colors.white
                                  : const Color(0xFF181111),
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
