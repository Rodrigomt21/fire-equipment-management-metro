import 'package:mobilegestaoextintores/src/telas/Tela_Login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tela_conta.dart'; 

class TelaConfiguracao extends StatelessWidget {
  const TelaConfiguracao({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuração'),
        backgroundColor: const Color(0xFF004AAD),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildConfigOption(
              context,
              icon: Icons.account_circle,
              label: 'Conta',
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TelaConta()));
              },
            ),
            _buildConfigOption(
              context,
              icon: Icons.lock,
              label: 'Privacidade',
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TelaConta()));
              },
            ),
            _buildConfigOption(
              context,
              icon: Icons.phone_android,
              label: 'Tela',
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TelaConta()));
              },
            ),
            _buildConfigOption(
              context,
              icon: Icons.bug_report,
              label: 'Reportar Erro',
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TelaConta()));
              },
            ),
            const Divider(),
            _buildConfigOption(
              context,
              icon: Icons.exit_to_app,
              label: 'Sair da conta',
              onTap: () {
                _sairDaConta(context);
              },
              isLogout: true,
            ),
            const Spacer(),
            Opacity(
              opacity: 0.2, 
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5, 
                  height: MediaQuery.of(context).size.height * 0.1, 
                  child: Image.asset(
                    'assets/images/logo.jpeg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Function() onTap,
    bool isLogout = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isLogout ? Colors.red : const Color(0xFF004AAD),
                  size: 28,
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: isLogout ? Colors.red : Colors.black87,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isLogout ? Colors.red : Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  void _sairDaConta(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sair da Conta'),
          content: const Text('Você deseja realmente sair da conta?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                // Limpar informações da sessão usando shared_preferences
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear(); // Limpa todas as informações da sessão

                // Fecha o diálogo e navega para a tela de login
                Navigator.pop(context);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const TelaLogin()));
              },
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }
}
