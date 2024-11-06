import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // URL base do backend
  static const String _baseUrl = 'http://10.0.2.2:3000'; // '10.0.2.2' é o localhost para Android emulador

  // Função para registrar o usuário
  Future<void> resgistra(String email, String senha) async {
    final url = Uri.parse('$_baseUrl/cadastro');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': senha,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao registrar usuário: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro de comunicação: $e');
    }
  }

  // Função para verificar login e senha
  Future<bool> loginUser(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usernameOrEmail': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // Login bem-sucedido
        return true;
      } else {
        // Credenciais inválidas
        return false;
      }
    } catch (e) {
      throw Exception('Erro de comunicação: $e');
    }
  }
}
