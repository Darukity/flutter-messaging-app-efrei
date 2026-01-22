import 'package:flutter/material.dart';
import '../../services/conversation_service.dart';
import '../../services/auth_storage.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  List<Map<String, dynamic>> conversations = [];
  bool loading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    loadConversations();
  }

  Future<void> loadConversations() async {
    try {
      final data = await ConversationService.getConversations();
      setState(() {
        conversations = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Future<void> logout() async {
    await AuthStorage.clearToken();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(child: Text(error))
              : ListView.builder(
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conv = conversations[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(conv['name'] ?? 'Utilisateur'),
                      subtitle: Text(conv['lastMessage'] ?? ''),
                      onTap: () {
                        // TODO: ouvrir page chat individuelle
                      },
                    );
                  },
                ),
    );
  }
}
