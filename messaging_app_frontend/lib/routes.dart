import 'package:flutter/material.dart';
import 'package:messaging_app_frontend/pages/chat/conversations_page.dart';
import 'package:messaging_app_frontend/pages/chat/users_page.dart';
import 'package:messaging_app_frontend/pages/chat/chat_detail_page.dart';
import 'package:messaging_app_frontend/pages/auth/splash_page.dart';
import 'package:messaging_app_frontend/pages/profile/profile_page.dart';
import 'package:messaging_app_frontend/pages/profile/profile_edit_page.dart';
import 'package:messaging_app_frontend/models/models.dart';

// Pages d'authentification
import 'pages/auth/login_page.dart';
import 'pages/auth/register_page.dart';

/// 🗺️ Configuration centralisée des routes
/// 
/// 🆚 Comparaison Angular : Équivalent de RouterModule avec les routes[]
/// 
/// Avantages :
/// - Navigation simplifiée : Navigator.pushNamed(context, '/users')
/// - Routes centralisées (plus facile à maintenir)
/// - Support des routes statiques ET dynamiques (avec paramètres)
class AppRoutes {
  /// 📋 Routes statiques (sans paramètres)
  /// 
  /// Map<String, WidgetBuilder> = Dictionnaire {nom_route: fonction_qui_crée_le_widget}
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const LoginPage(),           // 🏠 Page d'accueil
    '/login': (context) => const LoginPage(),      // 🔐 Connexion
    '/register': (context) => const RegisterPage(), // ✍️ Inscription
    '/users': (context) => const UsersPage(),      // 👥 Liste des utilisateurs
    '/conversations': (context) => const ConversationsPage(), // 💬 Conversations
    '/profile': (context) => const ProfilePage(),  // 👤 Profil utilisateur
  };

  /// 🎯 Routes dynamiques (avec paramètres)
  /// 
  /// Similaire à Angular : route: '/chat/:userId'
  /// Ici on récupère les paramètres via settings.arguments
  /// 
  /// Exemple d'utilisation :
  /// ```dart
  /// Navigator.pushNamed(
  ///   context,
  ///   '/chat-detail',
  ///   arguments: userObject, // Passer l'objet User
  /// );
  /// ```
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Route : /chat-detail (nécessite un User en argument)
    if (settings.name == '/chat-detail') {
      final user = settings.arguments as User;
      return MaterialPageRoute(
        builder: (context) => ChatDetailPage(otherUser: user),
      );
    }
    
    // Route : /profile-edit (nécessite un User en argument)
    if (settings.name == '/profile-edit') {
      final user = settings.arguments as User;
      return MaterialPageRoute(
        builder: (context) => ProfileEditPage(user: user),
      );
    }
    
    // Si aucune route ne correspond, retourner null (404)
    return null;
  }
}
