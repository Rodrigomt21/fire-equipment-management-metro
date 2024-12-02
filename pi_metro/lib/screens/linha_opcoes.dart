import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LinhaOpcoesScreen extends StatelessWidget {
  final String linhaSelecionada;

  const LinhaOpcoesScreen({Key? key, required this.linhaSelecionada}) : super(key: key);

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
              'lib/imgs/trilhos.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.40,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    linhaSelecionada,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF001489),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildOpcao(context, "Relatórios", '/relatorios'),
                      _buildOpcao(context, "Manutenção Preventiva", '/manutencao-preventiva'),
                      _buildOpcao(context, "Localização dos Extintores", '/localizacao-extintores'),
                      _buildOpcao(context, "Vencimento dos Extintores", '/vencimento-extintores'),
                      _buildOpcao(context, "Status", '/status'),
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

  Widget _buildOpcao(BuildContext context, String titulo, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 10),
        width: MediaQuery.of(context).size.width * 0.25,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF001489),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          titulo,
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: Colors.white,
            height: 1.2),
            textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
