import 'package:flutter/material.dart';
class ChatProvider with ChangeNotifier {
  List messages = [];

  void addMessage(msg) {
    messages.add(msg);
    notifyListeners();
  }
}
