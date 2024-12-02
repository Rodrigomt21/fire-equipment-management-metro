import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  String? errorMessage;

  // Método para criar campos de texto com estilo
  Widget _buildTextField(String hint, TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? !_isPasswordVisible : false,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Coluna do lado esquerdo
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'lib/imgs/logo.png', // Substitua pelo caminho da sua logo
                      height: 50,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Bem-vindo de volta!',
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Acesse sua conta para continuar\ncom o gerenciamento dos equipamentos.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Column(
                      children: [
                        Text(
                          'Ainda não tem uma conta?',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/cadastro');
                          },
                          child: Text(
                            'Cadastre-se aqui!',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: const Color(0xFF001489),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Coluna do lado direito com o card de login
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: screenWidth * 0.4,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      image: DecorationImage(
                        image: AssetImage('lib/imgs/trilhos.png'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.white.withOpacity(0.6),
                          BlendMode.lighten,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Login',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildTextField('Digite seu e-mail', emailController),
                        const SizedBox(height: 15),
                        _buildTextField(
                          'Senha',
                          passwordController,
                          isPassword: true,
                        ),
                        const SizedBox(height: 30),
                        if (errorMessage != null)
                          Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ElevatedButton(
                          onPressed: _login,
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
                              'Entrar',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/forgot-password');
                          },
                          child: Text(
                            'Esqueceu sua senha?',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: const Color(0xFF001489),
                              fontWeight: FontWeight.bold,
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
      ),
    );
  }

  void _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (!EmailValidator.validate(email)) {
      setState(() {
        errorMessage = 'Por favor, insira um e-mail válido.';
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        errorMessage = 'Por favor, insira sua senha.';
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'senha': password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final nomeUsuario = responseData['nomeCompleto'];

        // Salvar estado de login e nome do usuário
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('nomeUsuario', nomeUsuario);

        // Redirecionar para o dashboard
        Navigator.pushReplacementNamed(context, '/welcome-dashboard');
      } else {
        setState(() {
          errorMessage = 'Email ou senha incorretos. Tente novamente.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erro de conexão com o servidor.';
      });
      debugPrint(e.toString());
    }
  }
}
