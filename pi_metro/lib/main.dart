import 'package:flutter/material.dart';
import 'screens/hub.dart';
import 'screens/login.dart'; // Certifique-se de que este caminho está correto
import 'screens/cadastro.dart';
import 'screens/ResetPasswordPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestão de Equipamentos',
      theme: ThemeData(
        primaryColor: const Color(0xFF001489),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HubPage(),
        '/login': (context) => const LoginPage(), // Referência correta para LoginPage
        '/cadastro': (context) => const CadastroPage(),
        '/reset-password': (context) => ResetPasswordPage(token: ''),
      },
    );
  }
}
