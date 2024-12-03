import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobilegestaoextintores/src/telas/Redefinir_Senha/Tela_Esqueceu_Senha.dart';
import 'dart:convert';
import 'package:mobilegestaoextintores/src/telas/TelaPrincipal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  _TelaLoginState createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  bool _obscureText = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _verificarUsuarioSalvo();
  }

  Future<void> _verificarUsuarioSalvo() async {
    final prefs = await SharedPreferences.getInstance();
    final logado = prefs.getBool('usuario_logado') ?? false;

    if (logado) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const TelaPrincipal(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Image.asset(
                        'assets/images/logo.jpeg',
                        height: imageHeight,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      flex: 2,
                      child: Image.asset(
                        'assets/images/Metro.jpeg',
                        height: imageHeight,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 380,
                child: const Divider(
                  thickness: 1,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 8,
                color: Colors.grey[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildEmailField(),
                      const SizedBox(height: 20),
                      _buildPasswordField(),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TelaEsqueceuSenha()),
                          );
                        },
                        child: const Text(
                          'Esqueceu a senha?',
                          style:
                              TextStyle(color: Colors.blueAccent, fontSize: 14),
                        ),
                      ),
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildLoginButton(context),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 100,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/pilar_metro_1.jpeg',
                width: MediaQuery.of(context).size.width * 0.1,
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              Transform.translate(
                offset: const Offset(-20, 0),
                child: Image.asset(
                  'assets/images/pilar_metro_2.jpeg',
                  width: MediaQuery.of(context).size.width * 0.1,
                  height: MediaQuery.of(context).size.height * 0.09,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _emailController,
        decoration: const InputDecoration(
          icon: Icon(Icons.email, color: Colors.blueAccent),
          border: InputBorder.none,
          hintText: 'Email',
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscureText,
        decoration: InputDecoration(
          icon: const Icon(Icons.lock, color: Colors.blueAccent),
          border: InputBorder.none,
          hintText: 'Senha',
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.blueAccent,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _login(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF004AAD),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text(
        'ENTRAR',
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> _login(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.2.0.32:3001/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      print('Resposta da API: ${response.body}');
      print('Código de status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('usuario_email', _emailController.text);
          prefs.setBool('usuario_logado', true);

          // Salva o nome do usuário
          prefs.setString('usuario_nome', data['nome']);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const TelaPrincipal(),
            ),
          );
        } else {
          print('Erro no servidor: ${data['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro no login: ${data['message']}')),
          );
        }
      } else {
        print('Erro de conexão: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro de conexão com o servidor')),
        );
      }
    } catch (e) {
      print('Erro ao tentar realizar login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro inesperado ao fazer login')),
      );
    }
  }

  // Future<void> _login(BuildContext context) async {
  //   final response = await http.post(
  //     Uri.parse('http://10.2.0.32:3001/login'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({
  //       'email': _emailController.text,
  //       'password': _passwordController.text,
  //     }),
  //   );

  //   print('Resposta da API: ${response.body}');
  //   print('Código de status: ${response.statusCode}');

  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);

  //     if (data['success'] == true) {
  //       final prefs = await SharedPreferences.getInstance();
  //       prefs.setString('usuario_email', _emailController.text);
  //       prefs.setBool('usuario_logado', true);

  //       // Salva o nome do usuário
  //       prefs.setString('usuario_nome', data['nome']);

  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => const TelaPrincipal(),
  //         ),
  //       );
  //     } else {
  //       print('Erro no servidor: ${data['message']}');
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Erro no login: ${data['message']}')),
  //       );
  //     }
  //   } else {
  //     print('Erro de conexão: ${response.statusCode}');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Erro de conexão com o servidor')),
  //     );
  //   }
  // }
}
