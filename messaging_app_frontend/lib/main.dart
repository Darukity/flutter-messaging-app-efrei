import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes.dart';
import 'providers/message_provider.dart';
import 'providers/chat_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Messaging App',

        // page de départ
        initialRoute: '/',

        // routes centralisées
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.onGenerateRoute,

        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
        ),
      ),
    );
  }
}
