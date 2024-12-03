import 'package:flutter/material.dart';
import 'package:mobilegestaoextintores/src/telas/Manutencao/Tela_Atualizar_Dados.dart';
import 'package:mobilegestaoextintores/src/telas/Manutencao/Tela_Chamda_manutencao.dart';
import 'package:mobilegestaoextintores/src/telas/Manutencao/Tela_Manutencao.dart';

class TelaSelecaoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Selecione uma Opção",
          style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFFD9D9D9))),
        centerTitle: true,
        backgroundColor: const Color(0xFF011689),
        elevation: 4,
        iconTheme: const IconThemeData(
            color: Color(0xFFD9D9D9)), // Cor da seta (ícone de voltar)
      ),
      body: SingleChildScrollView( // Adicione o SingleChildScrollView aqui
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20), // Espaço superior
            // Card para registrar extintor para manutenção
            _buildOptionCard(
              context,
              title: "Registrar Problema Do Extintor",
              description:
                  "Esta funcionalidade permite que os usuários gerenciem os extintores que apresentam problemas. "
                  "É possível detalhar as falhas identificadas e atualizar o status do extintor conforme necessário.",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RegistrarProblemaExtintorPage()),
                );
              },
            ),
            const SizedBox(height: 20),
            // Card para atualizar dados do extintor
            _buildOptionCard(
              context,
              title: "Atualizar Dados do Extintor",
              description:
                  "Esta opção é destinada aos profissionais responsáveis pela manutenção dos extintores. "
                  "Permite a atualização das informações referentes ao estado do extintor no dia da manutenção.",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ManutencaoExtintorPage()),
                );
              },
            ),
            const SizedBox(height: 20),
            // Card para acessar a tela de atualizar dados do extintor
            _buildOptionCard(
              context,
              title: "Atualizar Informações do Extintor",
              description:
                  "Nesta opção, você pode buscar um extintor pelo patrimônio e atualizar suas informações, "
                  "incluindo a geração de um novo QR Code.",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TelaAtualizarExtintor()), // Nova tela
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context,
      {required String title,
      required String description,
      required VoidCallback onPressed}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF011689),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF011689),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                "Selecionar",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}