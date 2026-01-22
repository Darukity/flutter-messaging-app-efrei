import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  void login() async {
    final response = await http.post(
      Uri.parse('https://TON_BACKEND/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": emailCtrl.text,
        "password": passwordCtrl.text,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pushNamed(context, '/chat');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(controller: emailCtrl),
          TextField(controller: passwordCtrl),
          ElevatedButton(onPressed: login, child: Text("Login")),
        ],
      ),
    );
  }
}
