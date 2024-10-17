import 'package:flutter/material.dart';

class HubPage extends StatelessWidget {
  const HubPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Pegando o tamanho da tela com MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Imagem de fundo ajustada automaticamente
          Container(
            width: double.infinity,  // Ocupa toda a largura da tela
            height: double.infinity, // Ocupa toda a altura da tela
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/imgs/fundoHub.png'), // Caminho da imagem de fundo
                fit: BoxFit.cover,  // Ajusta a imagem automaticamente para cobrir a tela
              ),
            ),
          ),

          // Botão de Login transparente sobre a imagem de fundo
          Positioned(
            top: 590, // Ajuste a posição vertical do botão de Login
            left: (screenWidth / 2) - 100, // Ajusta horizontalmente o botão de login (assumindo largura de 200px)
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                backgroundColor: Colors.transparent, // Botão transparente
                side: const BorderSide(color: Colors.black, width: 2), // Borda preta
              ),
              child: const Text(
                'Login',
                style: TextStyle(
                  color: Colors.white, // Cor do texto
                  fontSize: 20, // Tamanho do texto
                ),
              ),
            ),
          ),

          // Botão de Cadastro transparente sobre a imagem de fundo
          Positioned(
            top: 650, // Ajuste a posição vertical do botão de Cadastro
            left: (screenWidth / 2) - 100, // Ajusta horizontalmente o botão de cadastro (assumindo largura de 200px)
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/cadastro');
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                backgroundColor: Colors.transparent, // Botão transparente
                side: const BorderSide(color: Colors.black, width: 2), // Borda preta
              ),
              child: const Text(
                'Cadastro',
                style: TextStyle(
                  color: Colors.white, // Cor do texto
                  fontSize: 20, // Tamanho do texto
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
