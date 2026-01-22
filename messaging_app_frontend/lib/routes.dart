import 'package:flutter/material.dart';
import 'package:messaging_app_frontend/chat_page.dart';
import 'package:messaging_app_frontend/pages/auth/splash_page.dart';

// pages
import 'pages/auth/login_page.dart';
import 'pages/auth/register_page.dart';
// plus tard : chat_page.dart, conversations_page.dart, etc.

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const SplashPage(),
    '/login': (context) => const LoginPage(),
    '/register': (context) => const RegisterPage(),
    '/chat': (context) =>  ChatPage()
  };
}
