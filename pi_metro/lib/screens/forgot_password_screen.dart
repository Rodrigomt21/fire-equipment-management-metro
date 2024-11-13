import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import '/services/auth_services.dart'; // Importe o serviço de autenticação que lida com as requisições de API

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  String? errorMessage;
  bool isLoading = false;

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
    await AuthService().forgotPassword(email);
    
    // Exibe uma mensagem de sucesso sem sair da tela
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Email de recuperação enviado com sucesso. Verifique seu e-mail.')),
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
