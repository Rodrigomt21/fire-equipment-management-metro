import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CadastroPage extends StatelessWidget {
  const CadastroPage({super.key});

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
                image: AssetImage('lib/imgs/telaCadastro.png'), // Caminho da imagem de fundo
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Campo de Email
          Positioned(
            left: 973,  // Ajuste fino da posição X
            top: 198,   // Ajuste fino da posição Y
            child: SizedBox(
              width: 298,  // Largura do campo de email ajustada
              height: 50,  // Altura do campo de email ajustada
              child: _buildTextField('Enter Email'),
            ),
          ),

          // Campo de Senha
          Positioned(
            left: 973,  // Ajuste fino da posição X
            top: 270,   // Ajuste fino da posição Y
            child: SizedBox(
              width: 298,  // Largura do campo de senha ajustada
              height: 50,  // Altura do campo de senha ajustada
              child: _buildTextField('Password', isPassword: true),
            ),
          ),

          // Campo de Confirmação de Senha
          Positioned(
            left: 973,  // Ajuste fino da posição X
            top: 335,   // Ajuste fino da posição Y
            child: SizedBox(
              width: 298,  // Largura do campo de confirmação de senha ajustada
              height: 50,  // Altura do campo de confirmação de senha ajustada
              child: _buildTextField('Confirm Password', isPassword: true),
            ),
          ),

          // Botão de Registrar estilizado
          Positioned(
            left: 973,   // Ajuste fino da posição X
            top: 405,    // Ajuste fino da posição Y
            child: SizedBox(
              width: 298,  // Largura do botão ajustada
              height: 50,  // Altura do botão ajustada
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF001489), // Azul Metrô
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),  // Bordas arredondadas
                  ),
                ),
                child: Text(
                  'Register',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: Colors.white,  // Texto branco
                  ),
                ),
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
      obscureText: isPassword,  // Controla visibilidade da senha
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],  // Cor de fundo cinza claro
        hintText: hint,  // Placeholder atualizado
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
