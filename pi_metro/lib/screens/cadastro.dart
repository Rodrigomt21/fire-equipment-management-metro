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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/imgs/telaCadastro.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTextField('Enter Email', emailController),
                _buildTextField('Password', passwordController, isPassword: true),
                _buildTextField('Confirm Password', confirmPasswordController, isPassword: true),
                if (errorMessage != null)
                  Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF001489),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Register',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: Colors.white,
                    ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 40),
      child: TextField(
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
      ),
    );
  }

  void _register() async {
    print('Tentando registrar o usuário...');  // Log inicial

    setState(() {
      errorMessage = null;
    });

    // Removendo espaços ao redor do email
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // Validação de email com logs adicionais
    print('Validando email: $email');
    bool isValid = EmailValidator.validate(email);
    print('Resultado da validação: $isValid');
    
    if (!isValid) {
      if (mounted) {
        setState(() {
          errorMessage = 'Por favor, insira um email válido.';
        });
      }
      print('Email inválido');
      return;
    }

    if (password != confirmPassword) {
      if (mounted) {
        setState(() {
          errorMessage = 'As senhas não coincidem!';
        });
      }
      print('Senhas não coincidem');
      return;
    }

    if (!_isPasswordValid(password)) {
      if (mounted) {
        setState(() {
          errorMessage = 'A senha deve conter ao menos 6 caracteres, uma letra maiúscula e um caractere especial.';
        });
      }
      print('Senha não atende aos requisitos');
      return;
    }

    try {
      await AuthService().registra(email, password);
      print('Registro realizado com sucesso');
      if (mounted) {
        Navigator.pushNamed(context, '/welcome');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cadastro realizado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Erro ao registrar usuário. Tente novamente.';
        });
      }
      print('Erro ao registrar usuário: $e');  // Log do erro em caso de falha
    }
  }

  bool _isPasswordValid(String password) {
    final regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[!@#\$&*~]).{6,}$');
    return regex.hasMatch(password);
  }
}
