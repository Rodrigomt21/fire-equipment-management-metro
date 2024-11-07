import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = 'http://localhost:3000';

  Future<void> registra(String email, String senha) async {
    final url = Uri.parse('$_baseUrl/cadastro');
    print('Enviando dados de registro para o backend...');  // Log para verificar a chamada

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'senha': senha,
        }),
      );

      if (response.statusCode == 200) {
        print('Registro concluído com sucesso no backend');
      } else {
        print('Falha ao registrar usuário: ${response.body}');
        throw Exception('Falha ao registrar usuário: ${response.body}');
      }
    } catch (e) {
      print('Erro de comunicação: $e');
      throw Exception('Erro de comunicação: $e');
    }
  }

  Future<bool> loginUser(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'senha': password,
        }),
      );

      print('Resposta do servidor no login: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Erro de comunicação: $e');
      throw Exception('Erro de comunicação: $e');
    }
  }
}
