import 'package:flutter/material.dart';
import 'socket_service.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  
  final SocketService socketService = SocketService();

  @override
  void initState() {
    super.initState();
    socketService.initSocket();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: ListView(/* messages ici */)),
          TextField(/* envoyer un message */),
        ],
      ),
    );
  }
}
