import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  bool _isConfirmPasswordVisible = false;
  String? errorMessage;

  // Método para validar a senha
  bool _isPasswordValid(String password) {
    final regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[!@#\$&*~]).{6,}$');
    return regex.hasMatch(password);
  }

  // Método para criar os campos de texto
  Widget _buildTextField(String hint, TextEditingController controller,
      {bool isPassword = false, bool isConfirmPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword
          ? !_isPasswordVisible
          : isConfirmPassword
              ? !_isConfirmPasswordVisible
              : false,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: isPassword || isConfirmPassword
            ? IconButton(
                icon: Icon(
                  (isPassword && _isPasswordVisible) ||
                          (isConfirmPassword && _isConfirmPasswordVisible)
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    if (isPassword) {
                      _isPasswordVisible = !_isPasswordVisible;
                    } else if (isConfirmPassword) {
                      _isConfirmPasswordVisible =
                          !_isConfirmPasswordVisible;
                    }
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
            // Coluna do lado esquerdo aprimorada
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'lib/imgs/logo.png',
                      height: 50,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Cadastro',
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Crie sua conta e faça parte do time!\nComece a gerenciar seus equipamentos\ncom eficiência e facilidade.',
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
                          'Já tem uma conta?',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: Text(
                            'Faça login aqui!',
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
            // Coluna do lado direito com o card do formulário
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
                          'Cadastro',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildTextField('Digite seu e-mail', emailController),
                        const SizedBox(height: 15),
                        _buildTextField(
                            'Digite seu nome completo', nomeCompletoController),
                        const SizedBox(height: 15),
                        _buildTextField(
                          'Senha',
                          passwordController,
                          isPassword: true,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          'Confirme sua senha',
                          confirmPasswordController,
                          isConfirmPassword: true,
                        ),
                        const SizedBox(height: 30),
                        if (errorMessage != null)
                          Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
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
                              'Cadastrar',
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
        errorMessage = 'Por favor, insira um e-mail válido.';
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
        errorMessage = 'A senha deve conter pelo menos 6 caracteres, uma letra maiúscula e um caractere especial.';
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/cadastro'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nomeCompleto': nomeCompleto,
          'email': email,
          'senha': password,
        }),
      );

      if (response.statusCode == 200) {
        final userResponse = await http.get(
          Uri.parse('http://localhost:3000/usuario?email=$email'),
        );

        if (userResponse.statusCode == 200) {
          final userData = jsonDecode(userResponse.body);
          final nomeUsuario = userData['nomeCompleto'];

          Navigator.pushReplacementNamed(
            context,
            '/welcome-dashboard',
            arguments: {'nomeUsuario': nomeUsuario},
          );
        } else {
          setState(() {
            errorMessage = 'Erro ao buscar informações do usuário.';
          });
        }
      } else {
        setState(() {
          errorMessage = 'Erro ao registrar usuário.';
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
