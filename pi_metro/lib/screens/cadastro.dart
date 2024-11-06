import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CadastroPage extends StatelessWidget {
  const CadastroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
                fit: BoxFit.cover, // Garante que a imagem cubra toda a tela
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
              child: _buildTextField('Enter Email'),
            ),
          ),

          // Campo de Senha
          Positioned(
            left: 973,
            top: screenHeight * 0.4,
            child: SizedBox(
              width: 298,
              height: 50,
              child: _buildTextField('Password', isPassword: true),
            ),
          ),

          // Campo de Confirmação de Senha
          Positioned(
            left: 973,
            top: screenHeight * 0.5,
            child: SizedBox(
              width: 298,
              height: 50,
              child: _buildTextField('Confirm Password', isPassword: true),
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
                onPressed: () {},
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
