import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/services/auth_services.dart';

class CadastroPage extends StatelessWidget {
  const CadastroPage({super.key});

  // Função para registrar o usuário, enviando os dados ao backend
  Future<void> registerUser(String email, String senha, BuildContext context) async {
    final response = await http.post(
      Uri.parse('http://localhost:5000/cadastro'), // URL ajustada para o caminho correto
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'senha': senha}),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário registrado com sucesso!')),
      );
      Navigator.pushNamed(context, '/login'); // Redireciona para a tela de login após o registro
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao registrar usuário')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    return Scaffold(
      body: Stack(
        children: [
          // Imagem de fundo ajustada ao tamanho da tela
          Container(
            width: screenWidth,
            height: screenHeight,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/imgs/telaCadastro.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Campo de Email
          Positioned(
            left: 973,
            top: screenHeight * 0.3,
            child: SizedBox(
              width: 298,
              height: 50,
              child: _buildTextField(
                'Enter Email',
                controller: emailController,
              ),
            ),
          ),

          // Campo de Senha
          Positioned(
            left: 973,
            top: screenHeight * 0.4,
            child: SizedBox(
              width: 298,
              height: 50,
              child: _buildTextField(
                'Password',
                controller: passwordController,
                isPassword: true,
              ),
            ),
          ),

          // Campo de Confirmação de Senha
          Positioned(
            left: 973,
            top: screenHeight * 0.5,
            child: SizedBox(
              width: 298,
              height: 50,
              child: _buildTextField(
                'Confirm Password',
                controller: confirmPasswordController,
                isPassword: true,
              ),
            ),
          ),

          // Botão de Registrar estilizado
          Positioned(
            left: 973,
            top: screenHeight * 0.6,
            child: SizedBox(
              width: 298,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (passwordController.text == confirmPasswordController.text) {
                    
    AuthService().resgistra(emailController.text, passwordController.text).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuário registrado com sucesso!'))
        );
        Navigator.pushNamed(context, '/login'); // Redirect to login on successful registration
    }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao registrar usuário'))
        );
    });
    
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('As senhas não coincidem!')),
                    );
                  }
                },
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
            ),
          ),

          // Botão de login transparente e sem texto
          Positioned(
            left: 305,
            top: 405,
            child: SizedBox(
              width: 90,
              height: 15,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint,
      {required TextEditingController controller, bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        hintText: hint,
        hintStyle: const TextStyle(
          color: Colors.black54,
          fontSize: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: const Icon(
                  Icons.visibility_off,
                  color: Colors.black54,
                ),
                onPressed: () {},
              )
            : null,
      ),
    );
  }
}
