import 'package:flutter/material.dart';
import '/services/auth_services.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token; // Token recebido a partir do link de e-mail

  ResetPasswordScreen({required this.token});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  void _resetPassword() async {
    final newPassword = _passwordController.text.trim();

    // Verifica se a nova senha tem pelo menos 6 caracteres
    if (newPassword.length < 6) {
      setState(() {
        errorMessage = 'A senha deve ter pelo menos 6 caracteres.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Chama o serviço para redefinir a senha, passando o token e a nova senha
      await AuthService().resetPassword(widget.token, newPassword);

      // Exibe mensagem de sucesso e redireciona para a tela de login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Senha redefinida com sucesso!')),
      );

      Navigator.popUntil(context, ModalRoute.withName('/login'));
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao redefinir senha. Tente novamente.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Redefinir Senha')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Nova senha',
                errorText: errorMessage,
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _resetPassword,
                    child: Text('Redefinir Senha'),
                  ),
          ],
        ),
      ),
    );
  }
}
