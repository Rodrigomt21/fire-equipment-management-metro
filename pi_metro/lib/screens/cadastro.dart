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
                _buildTextField('Nome e Sobrenome', nomeCompletoController),
                _buildTextField('Email', emailController),
                _buildTextField('Senha', passwordController, isPassword: true),
                _buildTextField('Confirmar Senha', confirmPasswordController, isPassword: true),
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
                    'Registrar',
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

  // Função para transformar cada palavra do nome completo com a primeira letra maiúscula
  String capitalizeName(String name) {
    return name.split(' ').map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase()).join(' ');
  }

  void _register() async {
    print('Tentando registrar o usuário...');

    setState(() {
      errorMessage = null;
    });

    // Ajustar nome para que cada palavra comece com letra maiúscula
    final nomeCompleto = capitalizeName(nomeCompletoController.text.trim());
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (nomeCompleto.isEmpty) {
      if (mounted) {
        setState(() {
          errorMessage = 'Por favor, insira seu nome completo.';
        });
      }
      return;
    }

    if (!EmailValidator.validate(email)) {
      if (mounted) {
        setState(() {
          errorMessage = 'Por favor, insira um email válido.';
        });
      }
      return;
    }

    if (password != confirmPassword) {
      if (mounted) {
        setState(() {
          errorMessage = 'As senhas não coincidem!';
        });
      }
      return;
    }

    if (!_isPasswordValid(password)) {
      if (mounted) {
        setState(() {
          errorMessage = 'A senha deve conter ao menos 6 caracteres, uma letra maiúscula e um caractere especial.';
        });
      }
      return;
    }

    try {
      await AuthService().registra(nomeCompleto, email, password);
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
      print('Erro ao registrar usuário: $e');
    }
  }

  bool _isPasswordValid(String password) {
    final regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[!@#\$&*~]).{6,}$');
    return regex.hasMatch(password);
  }
}
