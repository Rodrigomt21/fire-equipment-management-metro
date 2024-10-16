import 'package:flutter/material.dart';
import 'screens/hub.dart'; 
import 'screens/login.dart'; 
import 'screens/cadastro.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestão de Equipamentos',
      theme: ThemeData(
        primaryColor: const Color(0xFF001489), // Azul Metrô
      ),
      initialRoute: '/', // Tela inicial será o Hub
      routes: {
        '/': (context) => const HubPage(), // Rota do Hub
        '/login': (context) => const LoginPage(), // Rota para Login
        '/cadastro': (context) => const CadastroPage(), // Rota para Cadastro
      },
    );
  }
}
