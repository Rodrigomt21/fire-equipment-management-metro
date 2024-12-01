import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeDashboard extends StatefulWidget {
  final String nomeUsuario;
  final String cargoUsuario;

  const WelcomeDashboard({
    Key? key,
    required this.nomeUsuario,
    required this.cargoUsuario,
  }) : super(key: key);

  @override
  _WelcomeDashboardState createState() => _WelcomeDashboardState();
}

class _WelcomeDashboardState extends State<WelcomeDashboard> {
  late String nomeUsuario;
  String? linhaSelecionada;

  @override
  void initState() {
    super.initState();
    nomeUsuario = widget.nomeUsuario;
  }

  // Método para realizar o logout
  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('nomeUsuario');
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF001489),
        title: Text(
          'Bem-vindo, $nomeUsuario',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Selecione a linha para continuar.',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFEFEFEF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                hint: const Text('Escolha uma linha'),
                value: linhaSelecionada,
                dropdownColor: Colors.white,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xFF001489),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'Linha 1 - Azul',
                    child: Text(
                      'Linha 1 - Azul',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color(0xFF001489),
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Linha 2 - Verde',
                    child: Text(
                      'Linha 2 - Verde',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color(0xFF001489),
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Linha 3 - Vermelha',
                    child: Text(
                      'Linha 3 - Vermelha',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color(0xFF001489),
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Linha 15 - Prata',
                    child: Text(
                      'Linha 15 - Prata',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color(0xFF001489),
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    linhaSelecionada = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (linhaSelecionada != null) {
                    Navigator.pushNamed(
                      context,
                      '/linha-opcoes',
                      arguments: {'linha': linhaSelecionada!},
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor, selecione uma linha.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF001489),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Confirmar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
