import 'package:flutter/material.dart';
import 'package:messaging_app_frontend/pages/chat/conversations_page.dart';
import 'package:messaging_app_frontend/pages/chat/users_page.dart';
import 'package:messaging_app_frontend/pages/chat/chat_detail_page.dart';
import 'package:messaging_app_frontend/pages/auth/splash_page.dart';

// pages
import 'pages/auth/login_page.dart';
import 'pages/auth/register_page.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const LoginPage(),
    '/login': (context) => const LoginPage(),
    '/register': (context) => const RegisterPage(),
    '/users': (context) => const UsersPage(),
    '/conversations': (context) => const ConversationsPage(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == '/chat-detail') {
      final user = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (context) => ChatDetailPage(otherUser: user),
      );
    }
    return null;
  }
}
