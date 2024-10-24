import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
                image: AssetImage('lib/imgs/telaLogin.png'), // Caminho da imagem de fundo
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Botão de registro transparente e sem texto
          Positioned(
            left: 315,   // Ajuste fino da posição X
            top: 405,    // Ajuste fino da posição Y
            child: SizedBox(
              width: 100,  // Largura do botão
              height: 15,  // Altura do botão
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/cadastro'); // Redireciona para a aba de cadastro
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,  // Botão transparente
                  shadowColor: Colors.transparent,      // Sem sombra
                  padding: EdgeInsets.zero,             // Sem padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),  // Bordas arredondadas
                  ),
                ),
                child: const SizedBox.shrink(),  // Sem conteúdo visível
              ),
            ),
          ),

          // Campo de Login
          Positioned(
            left: 930,  // Ajuste fino da posição X para centralizar nos campos da imagem
            top: 232,   // Ajuste fino da posição Y para o campo de Login
            child: SizedBox(
              width: 298,  // Largura do campo de login ajustada
              height: 50,  // Altura do campo de login ajustada
              child: _buildTextField('Email ou usuário'),
            ),
          ),

          // Campo de Senha
          Positioned(
            left: 930,  // Ajuste fino da posição X para centralizar nos campos da imagem
            top: 312,   // Ajuste fino da posição Y para o campo de senha
            child: SizedBox(
              width: 298,  // Largura do campo de senha ajustada
              height: 50,  // Altura do campo de senha ajustada
              child: _buildTextField('Digite sua senha', isPassword: true),
            ),
          ),

          // Link "Esqueceu a senha?"
          Positioned(
            left: 1150,  // Ajuste da posição X para alinhar à direita do campo de senha
            top: 375,    // Ajuste da posição Y para logo abaixo do campo de senha
            child: const Text(
              'Esqueceu a senha?',
              style: TextStyle(color: Colors.black),
            ),
          ),

          // Botão de Login transparente com hover
          Positioned(
            left: 930,   // Ajuste fino da posição X para centralizar nos campos da imagem
            top: 425,    // Ajuste fino da posição Y para o botão de login
            child: MouseRegion(
              onEnter: (event) {}, // Detecta quando o mouse entra no botão
              onExit: (event) {},  // Detecta quando o mouse sai do botão
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  bool isHovering = false;
                  return MouseRegion(
                    onEnter: (_) => setState(() => isHovering = true),
                    onExit: (_) => setState(() => isHovering = false),
                    child: SizedBox(
                      width: 298,  // Largura do botão ajustada
                      height: 50,  // Altura do botão ajustada
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          backgroundColor: isHovering
                              ? Colors.blue.withOpacity(0.2)  // Efeito hover azul claro
                              : Colors.transparent,          // Transparente normalmente
                          side: const BorderSide(color: Colors.transparent), // Sem borda
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,  // Bordas quadradas
                          ),
                        ),
                        child: const SizedBox.shrink(),  // Sem texto
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

  // Função que cria os campos de texto
  Widget _buildTextField(String hint, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword ? true : false,  // Controla visibilidade da senha
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],  // Cor de fundo cinza claro
        hintText: hint,  // Placeholder atualizado e mais curto
        hintStyle: const TextStyle(
          color: Colors.black54, 
          fontSize: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),  // Bordas arredondadas modernas
          borderSide: BorderSide.none,  // Sem borda visível
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: const Icon(
                  Icons.visibility_off,
                  color: Colors.black54,
                ),
                onPressed: () {
                  // Alterna entre mostrar e esconder senha
                },
              )
            : null,  // O ícone de visibilidade aparece apenas no campo de senha
      ),
    );
  }
}
