import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:email_validator/email_validator.dart';
import '/services/auth_services.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final TextEditingController nomeCompletoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/imgs/telaCadastro.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: screenWidth < 600 ? screenWidth * 0.8 : 400,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cadastro',
                        style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Crie sua conta para começar a gerenciar e monitorar.',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildTextField('Nome Completo', nomeCompletoController),
                      const SizedBox(height: 15),
                      _buildTextField('Email', emailController),
                      const SizedBox(height: 15),
                      _buildTextField('Senha', passwordController, isPassword: true),
                      const SizedBox(height: 15),
                      _buildTextField('Confirmar Senha', confirmPasswordController, isPassword: true),
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            errorMessage!,
                            style: TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF001489),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: Center(
                          child: Text(
                            'Registrar',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  void _register() async {
    setState(() {
      errorMessage = null;
    });

    final nomeCompleto = nomeCompletoController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (nomeCompleto.isEmpty) {
      setState(() {
        errorMessage = 'Por favor, insira seu nome completo.';
      });
      return;
    }

    if (!EmailValidator.validate(email)) {
      setState(() {
        errorMessage = 'Por favor, insira um email válido.';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        errorMessage = 'As senhas não coincidem!';
      });
      return;
    }

    if (!_isPasswordValid(password)) {
      setState(() {
        errorMessage = 'A senha deve conter ao menos 6 caracteres, uma letra maiúscula e um caractere especial.';
      });
      return;
    }

    try {
      await AuthService().registra(nomeCompleto, email, password);
      Navigator.pushNamed(context, '/welcome');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado com sucesso!')),
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao registrar usuário. Tente novamente.';
      });
    }
  }

  bool _isPasswordValid(String password) {
    final regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[!@#\$&*~]).{6,}$');
    return regex.hasMatch(password);
  }
}
