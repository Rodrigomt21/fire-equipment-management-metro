import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificacoesPage extends StatelessWidget {
  final String userId;

  const NotificacoesPage({Key? key, required this.userId}) : super(key: key);

  Future<List<dynamic>> fetchNotificacoes() async {
    final response = await http.get(Uri.parse('http://localhost:3000/notificacoes?userId=$userId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao carregar notificações');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchNotificacoes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma notificação disponível.'));
          }

          final notificacoes = snapshot.data!;
          return ListView.builder(
            itemCount: notificacoes.length,
            itemBuilder: (context, index) {
              final notificacao = notificacoes[index];
              return ListTile(
                title: Text(notificacao['mensagem']),
                subtitle: Text(notificacao['data_criacao']),
                trailing: notificacao['status'] == 'não lida'
                    ? const Icon(Icons.circle, color: Colors.red, size: 12)
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
