import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = 'http://localhost:3000';

  Future<void> registra(String nomeCompleto, String email, String senha) async {
    final url = Uri.parse('$_baseUrl/cadastro');
    print('Enviando dados de registro para o backend...');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nomeCompleto': nomeCompleto,
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

  // Função para redefinir a senha
  Future<void> resetPassword(String token, String novaSenha) async {
    final url = Uri.parse('$_baseUrl/reset-password');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'novaSenha': novaSenha,
        }),
      );

      if (response.statusCode == 200) {
        print('Senha redefinida com sucesso');
      } else {
        print('Falha ao redefinir senha: ${response.body}');
        throw Exception('Falha ao redefinir senha: ${response.body}');
      }
    } catch (e) {
      print('Erro de comunicação: $e');
      throw Exception('Erro de comunicação: $e');
    }
  }

  // Função para solicitação de recuperação de senha
  Future<void> forgotPassword(String email) async {
    final url = Uri.parse('$_baseUrl/forgot-password');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        print('Email de recuperação enviado com sucesso');
      } else {
        print('Falha ao solicitar recuperação de senha: ${response.body}');
        throw Exception('Falha ao solicitar recuperação de senha: ${response.body}');
      }
    } catch (e) {
      print('Erro de comunicação: $e');
      throw Exception('Erro de comunicação: $e');
    }
  }
}
