import 'package:flutter/material.dart';
import '/services/auth_services.dart';

class ResetPasswordPage extends StatefulWidget {
  final String token;

  const ResetPasswordPage({required this.token, Key? key}) : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  String? errorMessage;

  void _resetPassword() async {
    final newPassword = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (newPassword != confirmPassword) {
      setState(() {
        errorMessage = 'As senhas não coincidem!';
      });
      return;
    }

    try {
      await AuthService().resetPassword(widget.token, newPassword);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha redefinida com sucesso!')),
      );
      Navigator.pushNamed(context, '/login');
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao redefinir senha. Tente novamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Redefinir Senha'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Nova Senha'),
              obscureText: true,
            ),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirmar Nova Senha'),
              obscureText: true,
            ),
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetPassword,
              child: const Text('Redefinir Senha'),
            ),
          ],
        ),
      ),
    );
  }
}
