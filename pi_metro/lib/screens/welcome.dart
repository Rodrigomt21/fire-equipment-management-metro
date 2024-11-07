import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bem-vindo!'),
      ),
      body: Center(
        child: Text(
          'Cadastro realizado com sucesso!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
