import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:email_validator/email_validator.dart';
import '/services/auth_services.dart';

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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600;

          return Stack(
            children: [
              Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('lib/imgs/telaLogin.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                left: isSmallScreen ? screenWidth * 0.1 : 930,
                top: screenHeight * 0.3,
                child: SizedBox(
                  width: isSmallScreen ? screenWidth * 0.8 : 298,
                  child: Column(
                    children: [
                      _buildTextField('Email ou usuário', emailController),
                      const SizedBox(height: 20),
                      _buildTextField('Digite sua senha', passwordController, isPassword: true),
                      const SizedBox(height: 20),
                      if (errorMessage != null)
                        Text(
                          errorMessage!,
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF001489),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Login',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
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
      ),
    );
  }

  void _login() async {
    setState(() {
      errorMessage = null;
    });

    // Removendo espaços ao redor do email
    final email = emailController.text.trim();
    final password = passwordController.text;

    // Validação de email
    if (!EmailValidator.validate(email)) {
      if (mounted) {
        setState(() {
          errorMessage = 'Por favor, insira um email válido.';
        });
      }
      return;
    }

    try {
      bool success = await AuthService().loginUser(email, password);
      if (mounted) {
        if (success) {
          Navigator.pushNamed(context, '/welcome');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login realizado com sucesso!')),
          );
        } else {
          setState(() {
            errorMessage = 'Credenciais inválidas.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Erro de comunicação. Tente novamente.';
        });
      }
    }
  }
}
