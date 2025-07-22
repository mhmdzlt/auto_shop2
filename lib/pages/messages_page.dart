import 'package:flutter/material.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: const Color(0xFF1a1a1a),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('User 1'),
            subtitle: Text('Hey! Is the part still available?'),
          ),
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('User 2'),
            subtitle: Text('I want to order some parts.'),
          ),
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('User 3'),
            subtitle: Text('Thanks for the fast reply!'),
          ),
        ],
      ),
    );
  }
}
