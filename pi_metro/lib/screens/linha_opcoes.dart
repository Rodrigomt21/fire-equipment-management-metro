import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LinhaOpcoesScreen extends StatelessWidget {
  final String linhaSelecionada; // Nome da linha selecionada

  const LinhaOpcoesScreen({Key? key, required this.linhaSelecionada})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF001489),
        title: Text(
          "Opções da $linhaSelecionada",
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/imgs/trilhos.png', // Substitua pelo caminho correto do mapa
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    linhaSelecionada,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF001489),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOpcao(context, "Relatórios"),
                      _buildOpcao(context, "Manutenção Preventiva"),
                      _buildOpcao(context, "Localização dos Extintores"),
                      _buildOpcao(context, "Vencimento dos Extintores"),
                      _buildOpcao(context, "Status"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpcao(BuildContext context, String titulo) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/graficos',
          arguments: {'titulo': titulo, 'linha': linhaSelecionada},
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF001489),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          titulo,
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
