import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pi_metro/screens/Opcoes_Dashboard/Tela_Notificacao.dart';
import 'package:pi_metro/screens/Telas_Relatorios/relatorios_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String nomeUsuario = 'Carregando...';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nomeUsuario = prefs.getString('nomeUsuario') ?? 'Usuário';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget _buildLargerCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180, // Aumentado para mais destaque
        height: 150,
        decoration: BoxDecoration(
          color: const Color(0xFF001489),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF001489),
        title: Text(
          'Dashboard',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white), // Ícone branco
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Nome do usuário
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Text(
                'Olá, $nomeUsuario!',
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF001489),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Text(
                'O que você gostaria de fazer hoje?',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  color: Colors.grey[700],
                ),
              ),
            ),
            // Dashboard com 2 linhas de 3 cards centralizados
            Column(
              children: [
                // Primeira linha de cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLargerCard(
                      title: 'Alterar\nExtintores',
                      icon: Icons.edit,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NotificacoesPage(userId: '',)),
                        );
                      },
                    ),
                    const SizedBox(width: 30),
                    _buildLargerCard(
                      title: 'Consultar\nExtintores',
                      icon: Icons.search,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NotificacoesPage(userId: '',)),
                        );
                      },
                    ),
                    const SizedBox(width: 30),
                    _buildLargerCard(
                      title: 'Adicionar\nExtintores',
                      icon: Icons.add,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NotificacoesPage(userId: '',)),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Segunda linha de cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLargerCard(
                      title: 'Relatórios',
                      icon: Icons.bar_chart,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RelatoriosScreen()),
                        );
                      },
                    ),
                    const SizedBox(width: 30),
                    _buildLargerCard(
                      title: 'Notificações',
                      icon: Icons.notifications,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NotificacoesPage(userId: '',)),
                        );
                      },
                    ),
                    const SizedBox(width: 30),
                    _buildLargerCard(
                      title: 'Configurações',
                      icon: Icons.settings,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NotificacoesPage(userId: '',)),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
