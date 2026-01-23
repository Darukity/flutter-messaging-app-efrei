import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes.dart';
import 'providers/message_provider.dart';
import 'providers/chat_provider.dart';

/// 🚀 Point d'entrée de l'application
/// 
/// Cette fonction est appelée au démarrage de l'app.
/// C'est l'équivalent du main.ts dans Angular.
void main() {
  runApp(const MyApp());
}

/// 📱 Widget racine de l'application
/// 
/// Configure les Providers globaux et le MaterialApp (équivalent du Router Angular)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔄 MultiProvider : Rendre les Providers disponibles dans TOUTE l'app
    // 
    // 🆚 Comparaison Angular : C'est comme le providers: [] dans app.config.ts
    // Tous les composants/widgets de l'app peuvent accéder à ces Providers
    return MultiProvider(
      providers: [
        // 💬 MessageProvider : Gestion des messages d'une conversation
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        
        // 🔌 ChatProvider : Gestion de Socket.IO (Singleton)
        // Le Singleton garantit qu'il n'y a qu'une seule connexion Socket.IO
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        // Désactiver le bandeau "DEBUG" en haut à droite
        debugShowCheckedModeBanner: false,
        
        title: 'Messaging App',

        // 🏠 Page de démarrage (première page affichée)
        // '/' correspond au LoginPage (voir routes.dart)
        initialRoute: '/',

        // 🗺️ Routes centralisées (comme RouterModule.forRoot() en Angular)
        routes: AppRoutes.routes,
        
        // 🎯 Route dynamique pour passer des paramètres
        // (comme les paramètres de route Angular)
        onGenerateRoute: AppRoutes.onGenerateRoute,

        // 🎨 Thème global de l'application
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
        ),
      ),
    );
  }
}
