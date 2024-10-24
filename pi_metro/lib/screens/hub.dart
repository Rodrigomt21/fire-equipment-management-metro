import 'package:flutter/material.dart';

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

          // Botão de Login transparente e sem texto, com hover
          Positioned(
            left: 310,  // Ajuste fino da posição X
            top: 585,   // Ajuste fino da posição Y
            child: MouseRegion(
              onEnter: (event) => {}, // Detecta quando o mouse entra no botão
              onExit: (event) => {},  // Detecta quando o mouse sai do botão
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  bool isHoveringLogin = false;
                  return MouseRegion(
                    onEnter: (_) => setState(() => isHoveringLogin = true),
                    onExit: (_) => setState(() => isHoveringLogin = false),
                    child: SizedBox(
                      width: 300,  // Largura do botão de Login
                      height: 50,  // Altura do botão de Login
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: isHoveringLogin
                              ? Colors.blue.withOpacity(0.2) // Efeito hover
                              : Colors.transparent, // Botão transparente normalmente
                          side: const BorderSide(color: Colors.transparent), // Sem borda
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero, // Bordas quadradas
                          ),
                        ),
                        child: const SizedBox.shrink(), // Sem texto
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Botão de Cadastro transparente e com hover
          Positioned(
            left: 930,  // Ajuste fino da posição X
            top: 585,   // Ajuste fino da posição Y
            child: MouseRegion(
              onEnter: (event) => {}, // Detecta quando o mouse entra no botão
              onExit: (event) => {},  // Detecta quando o mouse sai do botão
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  bool isHoveringCadastro = false;
                  return MouseRegion(
                    onEnter: (_) => setState(() => isHoveringCadastro = true),
                    onExit: (_) => setState(() => isHoveringCadastro = false),
                    child: SizedBox(
                      width: 300,  // Largura do botão de Cadastro
                      height: 50,  // Altura do botão de Cadastro
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/cadastro');
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: isHoveringCadastro
                              ? Colors.green.withOpacity(0.2) // Efeito hover
                              : Colors.transparent, // Botão transparente normalmente
                          side: const BorderSide(color: Colors.transparent), // Sem borda
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero, // Bordas quadradas
                          ),
                        ),
                        child: const SizedBox.shrink(), // Sem texto
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
