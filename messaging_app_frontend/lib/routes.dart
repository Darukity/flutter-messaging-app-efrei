import 'package:flutter/material.dart';
import 'login_page.dart';
import 'chat_page.dart';

Map<String, WidgetBuilder> routes = {
  '/login': (context) => LoginPage(),
  '/chat': (context) => ChatPage(),
};
