import 'package:mobilegestaoextintores/src/telas/Tela_Login.dart';
import 'package:flutter/material.dart';
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
                // Navegar para a tela de Conta
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
                    MaterialPageRoute(builder: (context) => TelaPrivacidade()));
              },
            ),
            _buildConfigOption(
              context,
              icon: Icons.phone_android,
              label: 'Tela',
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TelaConfigTela()));
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
                        builder: (context) => TelaReportarErro()));
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
            Image.network('https://i.imgur.com/IZ8lRQK.png', width: 80),
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
              onPressed: () {
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


class TelaPrivacidade extends StatelessWidget {
  const TelaPrivacidade({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacidade')),
      body: const Center(child: Text('Tela de Privacidade')),
    );
  }
}

class TelaConfigTela extends StatelessWidget {
  const TelaConfigTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tela')),
      body: const Center(child: Text('Tela de Configuração da Tela')),
    );
  }
}

class TelaReportarErro extends StatelessWidget {
  const TelaReportarErro({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportar Erro')),
      body: const Center(child: Text('Tela de Reportar Erro')),
    );
  }
}
