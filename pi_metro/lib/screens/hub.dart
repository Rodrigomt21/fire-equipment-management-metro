import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Certifique-se de adicionar o pacote google_fonts ao pubspec.yaml

class HubPage extends StatelessWidget {
  const HubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagem de fundo ajustada automaticamente
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/imgs/fundoHub.png'), // Caminho da imagem de fundo
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Botão de Login com bordas arredondadas e cor sólida
          Positioned(
            left: 310,  // Ajuste fino da posição X
            top: 585,   // Ajuste fino da posição Y
            child: SizedBox(
              width: 300,  // Largura do botão de Login
              height: 50,  // Altura do botão de Login
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF001489), // Cor sólida #001489
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Bordas arredondadas
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                ),
                child: Text(
                  'Login',
                  style: GoogleFonts.poppins(
                    color: Colors.white, // Cor do texto em branco
                    fontSize: 18,        // Tamanho da fonte
                  ),
                ),
              ),
            ),
          ),

          // Botão de Cadastro com bordas arredondadas e cor sólida
          Positioned(
            left: 930,  // Ajuste fino da posição X
            top: 585,   // Ajuste fino da posição Y
            child: SizedBox(
              width: 300,  // Largura do botão de Cadastro
              height: 50,  // Altura do botão de Cadastro
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/cadastro');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF001489), // Cor sólida #001489
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Bordas arredondadas
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                ),
                child: Text(
                  'Cadastro',
                  style: GoogleFonts.poppins(
                    color: Colors.white, // Cor do texto em branco
                    fontSize: 18,        // Tamanho da fonte
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
