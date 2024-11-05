import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
              // Imagem de fundo ajustada ao tamanho da tela
              Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('lib/imgs/telaLogin.png'),
                    fit: BoxFit.cover, // Garante que a imagem cubra toda a tela
                  ),
                ),
              ),

              // Botão de registro transparente e sem texto
              Positioned(
                left: isSmallScreen ? screenWidth * 0.7 : 315,
                top: screenHeight * 0.5,
                child: SizedBox(
                  width: 100,
                  height: 15,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/cadastro');
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

              // Campo de Login
              Positioned(
                left: isSmallScreen ? screenWidth * 0.1 : 930,
                top: screenHeight * 0.3,
                child: SizedBox(
                  width: isSmallScreen ? screenWidth * 0.8 : 298,
                  height: 50,
                  child: _buildTextField('Email ou usuário'),
                ),
              ),

              // Campo de Senha
              Positioned(
                left: isSmallScreen ? screenWidth * 0.1 : 930,
                top: screenHeight * 0.4,
                child: SizedBox(
                  width: isSmallScreen ? screenWidth * 0.8 : 298,
                  height: 50,
                  child: _buildTextField('Digite sua senha', isPassword: true),
                ),
              ),

              // Link "Esqueceu a senha?"
              Positioned(
                left: isSmallScreen ? screenWidth * 0.6 : 1150,
                top: screenHeight * 0.45,
                child: const Text(
                  'Esqueceu a senha?',
                  style: TextStyle(color: Colors.black),
                ),
              ),

              // Botão de Login estilizado
              Positioned(
                left: isSmallScreen ? screenWidth * 0.1 : 930,
                top: screenHeight * 0.5,
                child: SizedBox(
                  width: isSmallScreen ? screenWidth * 0.8 : 298,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField(String hint, {bool isPassword = false}) {
    return TextField(
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
