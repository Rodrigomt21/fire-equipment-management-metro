import 'package:flutter/material.dart';
import 'package:mobilegestaoextintores/src/telas/Configuracao/Tela_Configuracao.dart';
import 'package:mobilegestaoextintores/src/telas/TelaScanQR.dart';
import 'package:mobilegestaoextintores/src/telas/Tela_Consulta.dart';
import 'package:mobilegestaoextintores/src/telas/Tela_Localizacao.dart';
import 'package:mobilegestaoextintores/src/telas/Tela_RegistrarExtintorManual.dart';
import 'package:mobilegestaoextintores/src/telas/Manutencao/Tela_Selecionar_Manutencao.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelaPrincipal extends StatelessWidget {
  const TelaPrincipal({super.key});

  Future<String?> _getNomeUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('usuario_nome');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getNomeUsuario(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text("Erro ao carregar o nome do usuário")),
          );
        }

        final nomeUsuario = snapshot.data!;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: const Color(0xFF011689),
            elevation: 0,
            title: Image.asset(
              'assets/images/logo_principal.jpeg',
              height: 40,
              fit: BoxFit.contain,
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                  mainAxisSize: MainAxisSize
                      .min, // Impede que ocupe mais espaço do que necessário
                  children: [
                    const Icon(Icons.account_circle,
                        color: Colors.white, size: 28),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Olá, $nomeUsuario',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow
                            .ellipsis, // Corta texto longo com "..."
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
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
                          color: Color(0xFF011689),
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
                              'Registrar novos extintores e gerar QR code;'),
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
                const SizedBox(height: 100),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  runSpacing: 20,
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
                      icon: Icons.qr_code_scanner,
                      label: 'Scanner QR',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => QRViewExample()),
                        );
                      },
                    ),
                    _buildIconButton(
                      icon: Icons.build,
                      label: 'Manutenção',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TelaSelecaoPage()),
                        );
                      },
                    ),
                    _buildIconButton(
                      icon: Icons.map,
                      label: 'Localização',
                       onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TelaConsultaLocalizacaoExtintor()),
                        );
                      },
                    ),
                    _buildIconButton(
                      icon: Icons.search,
                      label: 'Consulta',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TelaConsultaExtintor()),
                        );
                      },
                    ),
                    _buildIconButton(
                      icon: Icons.settings,
                      label: 'Configurações',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TelaConfiguracao()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ',
            style: TextStyle(fontSize: 18, color: Color(0xFF011689))),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF011689),
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
}
