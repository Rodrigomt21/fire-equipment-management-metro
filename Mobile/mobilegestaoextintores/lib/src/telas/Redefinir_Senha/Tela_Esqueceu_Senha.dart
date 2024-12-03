import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http; // Importar o pacote http
import 'dart:convert'; // Importar para usar jsonEncode

class TelaEsqueceuSenha extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<TelaEsqueceuSenha> {
  final TextEditingController _emailController = TextEditingController();
  String? errorMessage;
  bool isLoading = false;

  // Defina a URL base do seu backend
  final String _baseUrl =
      'http://localhost:3001'; // Altere para o endereço do seu servidor

  void _submitEmail() async {
    final email = _emailController.text.trim();

    if (!EmailValidator.validate(email)) {
      setState(() {
        errorMessage = 'Por favor, insira um e-mail válido.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Chama o serviço para enviar o e-mail de recuperação de senha
      await forgotPassword(email);

      // Exibe uma mensagem de sucesso sem sair da tela
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Email de recuperação enviado com sucesso. Verifique seu e-mail.')),
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao enviar o e-mail. Tente novamente.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Função para solicitação de recuperação de senha
  Future<void> forgotPassword(String email) async {
    final url = Uri.parse('$_baseUrl/forgot-password');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        print('Email de recuperação enviado com sucesso');
      } else {
        print('Falha ao solicitar recuperação de senha: ${response.body}');
        throw Exception(
            'Falha ao solicitar recuperação de senha: ${response.body}');
      }
    } catch (e) {
      print('Erro de comunicação: $e');
      throw Exception('Erro de comunicação: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Esqueceu a Senha')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Digite seu e-mail',
                errorText: errorMessage,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator() // Mostra um carregamento enquanto a solicitação é processada
                : ElevatedButton(
                    onPressed: _submitEmail,
                    child: Text('Enviar Link de Redefinição'),
                  ),
          ],
        ),
      ),
    );
  }
}
