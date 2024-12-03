import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TelaReportarErro extends StatefulWidget {
  const TelaReportarErro({super.key});

  @override
  _TelaReportarErroState createState() => _TelaReportarErroState();
}

class _TelaReportarErroState extends State<TelaReportarErro> {
  final TextEditingController _controller = TextEditingController();
  String? _usuarioEmail;

  @override
  void initState() {
    super.initState();
    _carregarEmailUsuario();
  }

  Future<void> _carregarEmailUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _usuarioEmail = prefs.getString('usuario_email');
    });
  }

  void _enviarErro() async {
    final erro = _controller.text.trim();
    if (erro.isNotEmpty && _usuarioEmail != null) {
      final response = await http.post(
        Uri.parse('http://localhost:3000/reportar-erro'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'usuarioEmail': _usuarioEmail,
          'erroDescricao': erro,
        }),
      );

      if (response.statusCode == 200) {
        _mostrarDialogo('Sucesso', 'Erro reportado com sucesso!');
      } else {
        _mostrarDialogo('Erro', 'Falha ao reportar o erro: ${response.body}');
      }

      _controller.clear(); // Limpa o campo de texto após o envio
    } else {
      // Caso o campo esteja vazio, avisa o usuário
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, descreva o erro.')),
      );
    }
  }

  void _mostrarDialogo(String titulo, String mensagem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(mensagem),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportar Erro',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFFD9D9D9))),
        backgroundColor: const Color(0xFF011689),
        centerTitle: true,
        elevation: 4,
        iconTheme: const IconThemeData(
            color: Color(0xFFD9D9D9)), // Cor da seta (ícone de voltar)
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text(
                  'Caso tenha identificado algum erro, favor reportar abaixo',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Descreva o erro...',
                    border: InputBorder.none,
                  ),
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _enviarErro,
                child: const Text(
                  'Enviar Erro',
                  style: TextStyle(
                      color: Color(0xFFD9D9D9),
                      fontSize: 20),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF011689),
                  padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Opacity(
              opacity: 0.2,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.1,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Image.asset(
                    'lib/imgs/logo.jpeg',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}