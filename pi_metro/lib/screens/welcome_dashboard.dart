import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeDashboard extends StatefulWidget {
  final String? nomeUsuario; // Parâmetro nomeado
  final String cargoUsuario;

  const WelcomeDashboard({
    Key? key,
    this.nomeUsuario,
    required this.cargoUsuario,
  }) : super(key: key);

  @override
  _WelcomeDashboardState createState() => _WelcomeDashboardState();
}

class _WelcomeDashboardState extends State<WelcomeDashboard> {
  late String nomeUsuario;

  @override
  void initState() {
    super.initState();
    _initializeNomeUsuario();
  }

  // Inicializa o nome do usuário, priorizando o argumento passado
  void _initializeNomeUsuario() async {
    if (widget.nomeUsuario != null && widget.nomeUsuario!.isNotEmpty) {
      setState(() {
        nomeUsuario = widget.nomeUsuario!;
      });
    } else {
      final prefs = await SharedPreferences.getInstance();
      final nome = prefs.getString('nomeUsuario') ?? 'Usuário';
      setState(() {
        nomeUsuario = nome;
      });
    }
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
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bem-vindo, $nomeUsuario',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  Text(
                    widget.cargoUsuario,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    color: Colors.white,
                    onPressed: () => _logout(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // Fundo da tela
          Positioned.fill(
            child: Image.asset(
              'lib/imgs/trilhos.png', // Substitua pelo caminho correto
              fit: BoxFit.cover,
            ),
          ),
          // Conteúdo principal
          Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Olá, $nomeUsuario!',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF001489),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Selecione a linha para continuar.',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
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
                    hint: Text(
                      'Escolha a linha desejada',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    dropdownColor: const Color(0xFF001489),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: '1',
                        child: Text('Linha 1 - Azul'),
                      ),
                      DropdownMenuItem(
                        value: '2',
                        child: Text('Linha 2 - Verde'),
                      ),
                      DropdownMenuItem(
                        value: '3',
                        child: Text('Linha 3 - Vermelha'),
                      ),
                      DropdownMenuItem(
                        value: '15',
                        child: Text('Linha 15 - Prata'),
                      ),
                    ],
                    onChanged: (value) {
                      // Lógica para tratar seleção
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Ação do botão
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF001489),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Confirmar',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Logo na parte inferior direita
          Positioned(
            bottom: 20,
            right: 20,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'lib/imgs/logo.png', // Substitua pelo caminho correto
                  width: 100,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
