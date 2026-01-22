import 'package:flutter/material.dart';
import 'package:messaging_app_frontend/services/auth_storage.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    super.initState();
    protectPage();
  }

  Future<void> protectPage() async {
    final token = await AuthStorage.getToken();

    if (token == null) {
      // Pas de token → retour login
      Navigator.pushReplacementNamed(context, '/login');
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
        title: const Text("Chat"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),
      body: const Center(
        child: Text("Bienvenue dans le chat 🔥"),
      ),
    );
  }
}