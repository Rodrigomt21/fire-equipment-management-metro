import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RelatoriosScreen extends StatelessWidget {
  const RelatoriosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF001489),
        title: Text(
          "Relatórios",
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Text(
          "Conteúdo da tela de Relatórios",
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
