import 'package:flutter/material.dart';
import 'package:mobilegestaoextintores/src/telas/Tela_RegistrarExtintorManual.dart';
import 'tela_configuracao.dart';

class TelaPrincipal extends StatelessWidget {
  final String nomeUsuario; 
  const TelaPrincipal({super.key, required this.nomeUsuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF004AAD),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/logo.jpeg',)
        ),
        title: const Text(
          'METRÔ DE SÃO PAULO',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                const Icon(Icons.account_circle, color: Colors.white),
                const SizedBox(width: 5),
                Text('Olá, $nomeUsuario', style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    spreadRadius: 3,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Gerenciamento de Extintores - Metrô de São Paulo',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004AAD),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Utilize o aplicativo para um controle eficiente dos extintores de incêndio:',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBulletPoint(
                          'Registrar novos extintores via QR code ou manualmente;'),
                      _buildBulletPoint(
                          'Controlar a entrada e saída dos extintores para manutenção;'),
                      _buildBulletPoint(
                          'Acompanhar a validade e localização dos equipamentos.'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Sua atenção e uso correto das ferramentas garantem a segurança de todos!',
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIconButton(
                  icon: Icons.fire_extinguisher,
                  label: 'Registrar',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TelaRegistrarExtintor()),
                    );
                  },
                ),
                _buildIconButton(
                  icon: Icons.build,
                  label: 'Manutenção',
                  onTap: () {
                    _navigateTo(context, 'Manutenção');
                  },
                ),
                _buildIconButton(
                  icon: Icons.map,
                  label: 'Localização',
                  onTap: () {
                    _navigateTo(context, 'Localização');
                  },
                ),
                _buildIconButton(
                  icon: Icons.search,
                  label: 'Consulta',
                  onTap: () {
                    _navigateTo(context, 'Consulta');
                  },
                ),
                _buildIconButton(
                  icon: Icons.settings,
                  label: 'Configurações',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TelaConfiguracao()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ',
            style: TextStyle(fontSize: 18, color: Color(0xFF004AAD))),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton(
      {required IconData icon,
      required String label,
      required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF004AAD),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 32, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, String pageName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navegando para $pageName')),
    );
  }
}
