import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  // Função para registrar o usuário
  Future<void> registra(String nomeCompleto, String email, String senha) async {
    final url = Uri.parse('$_baseUrl/cadastro');

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
      } else if (response.statusCode == 400) {
        throw Exception('Dados inválidos: ${response.body}');
      } else {
        throw Exception('Falha ao registrar usuário: ${response.body}');
      }
    } catch (e) {
      print('Erro de comunicação: $e');
      throw Exception('Erro de comunicação: $e');
    }
  }

  // Função para login do usuário
  Future<Map<String, dynamic>> loginUser(String email, String senha) async {
    final url = Uri.parse('$_baseUrl/login');

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
        final data = jsonDecode(response.body);
        print('Login bem-sucedido: ${data['nomeCompleto']}');
        return {
          'status': true,
          'nomeCompleto': data['nomeCompleto'],
        };
      } else if (response.statusCode == 401) {
        return {'status': false, 'message': 'Credenciais inválidas'};
      } else {
        throw Exception('Falha no login: ${response.body}');
      }
    } catch (e) {
      print('Erro de comunicação: $e');
      throw Exception('Erro de comunicação: $e');
    }
  }

  Future<void> resetPassword(String token, String novaSenha) async {
  if (token.isEmpty || novaSenha.isEmpty || novaSenha.length < 6) {
    throw Exception('Token inválido ou senha muito curta.');
  }

  final url = Uri.parse('$_baseUrl/reset-password');

  print('Token enviado: $token');
  print('Nova senha enviada: $novaSenha');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
        'newPassword': novaSenha,
      }),
    );

    if (response.statusCode == 200) {
      print('Senha redefinida com sucesso');
    } else if (response.statusCode == 400) {
      throw Exception('Token inválido ou senha muito curta.');
    } else {
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
      } else if (response.statusCode == 404) {
        throw Exception('Email não encontrado');
      } else {
        throw Exception(
            'Falha ao solicitar recuperação de senha: ${response.body}');
      }
    } catch (e) {
      print('Erro de comunicação: $e');
      throw Exception('Erro de comunicação: $e');
    }
  }
}
