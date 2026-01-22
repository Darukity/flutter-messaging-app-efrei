import 'package:flutter/material.dart';
import 'package:messaging_app_frontend/services/auth_storage.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  Future<void> checkAuth() async {
    final token = await AuthStorage.getToken();

    if (token != null && token.isNotEmpty) {
      // Déjà connecté → aller au chat
      Navigator.pushReplacementNamed(context, '/chat');
    } else {
      // Pas connecté → login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
