
import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bem-vindo"),
      ),
      body: Center(
        child: Text(
          "Bem-vindo ao sistema!",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
