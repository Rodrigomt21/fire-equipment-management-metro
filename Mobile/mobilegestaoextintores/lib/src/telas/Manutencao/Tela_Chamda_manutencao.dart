import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistrarProblemaExtintorPage extends StatefulWidget {
  @override
  _RegistrarProblemaExtintorPageState createState() =>
      _RegistrarProblemaExtintorPageState();
}

class _RegistrarProblemaExtintorPageState
    extends State<RegistrarProblemaExtintorPage> {
  final _patrimonioController = TextEditingController();
  String? _problemaSelecionado;
  final _localController = TextEditingController();
  final _observacoesController = TextEditingController();
  String? _statusSelecionado;

  List<String> problemaOptions = [
    'Vencido',
    'Quebrado',
    'Usado',
    'Violado',
    'Sem Pressão',
    'Corrosão',
    'Fugas',
    'Etiqueta Faltando',
    'Dano Estético',
    'Inadequado para Uso',
    'Descarte Necessário'
  ];

  List<dynamic> problemas = [];
  List<Map<String, dynamic>> statusOptions = [];

  @override
  void initState() {
    super.initState();
    _fetchProblemas();
    _fetchStatus();
  }

  Future<void> _fetchProblemas() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3001/problemas'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          problemas = data['problemas'] ?? [];
        });
      } else {
        _showErrorDialog('Erro ao buscar problemas: ${response.body}');
      }
    } catch (e) {
      _showErrorDialog('Erro de conexão: $e');
    }
  }

  Future<void> _fetchStatus() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3001/status'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          statusOptions = List<Map<String, dynamic>>.from(data['data']);
        });
      } else {
        _showErrorDialog('Erro ao buscar status: ${response.body}');
      }
    } catch (e) {
      _showErrorDialog('Erro de conexão: $e');
    }
  }

  Future<void> _registrarProblema() async {
    final patrimonio = _patrimonioController.text;
    final local = _localController.text;
    final observacoes = _observacoesController.text;

    if (patrimonio.isEmpty ||
        local.isEmpty ||
        _problemaSelecionado == null ||
        _statusSelecionado == null) {
      _showErrorDialog('Por favor, preencha todos os campos.');
      return;
    }

    final problemaData = {
      "patrimonio": patrimonio,
      "Problema": _problemaSelecionado,
      "local": local,
      "observacoes": observacoes,
      "status": _statusSelecionado // Adiciona o status selecionado
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3001/registrar_problema'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(problemaData),
      );

      if (response.statusCode == 200) {
        await _atualizarStatusExtintor(patrimonio, _statusSelecionado);

        _showSuccessDialog('Problema registrado com sucesso!');
        _clearFields();
        _fetchProblemas();
      } else {
        _showErrorDialog('Erro ao registrar o problema: ${response.body}');
      }
    } catch (e) {
      _showErrorDialog('Erro de conexão: $e');
    }
  }

  Future<void> _atualizarStatusExtintor(
      String patrimonio, String? statusSelecionado) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:3001/atualizar_status_extintor'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "patrimonio": patrimonio,
          "status": statusSelecionado,
        }),
      );

      if (response.statusCode != 200) {
        _showErrorDialog(
            'Erro ao atualizar status do extintor: ${response.body}');
      }
    } catch (e) {
      _showErrorDialog('Erro de conexão ao atualizar status: $e');
    }
  }

  void _clearFields() {
    _patrimonioController.clear();
    _localController.clear();
    _observacoesController.clear();
    setState(() {
      _problemaSelecionado = null;
      _statusSelecionado = null;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sucesso'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      appBar: AppBar(
        title: const Text("Registrar Problema no Extintor",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFFD9D9D9))),
        centerTitle: true,
        backgroundColor: const Color(0xFF011689),
        elevation: 4,
        iconTheme: const IconThemeData(color: Color(0xFFD9D9D9)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Registrar Problema no Extintor',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF011689),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Preencha os campos abaixo para registrar um problema no extintor.',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                      _patrimonioController, 'Número do Patrimônio'),
                  const SizedBox(height: 20),
                  _buildDropdown(),
                  const SizedBox(height: 20),
                  _buildStatusDropdown(),
                  const SizedBox(height: 20),
                  _buildTextField(_localController, 'Local do Extintor'),
                  const SizedBox(height: 20),
                  _buildTextField(
                    _observacoesController,
                    'Observações (opcional)',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _registrarProblema,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF011689),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text(
                      'Registrar Problema',
                      style: TextStyle(color: Color(0xFFD9D9D9)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Problemas Registrados',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            problemas.isEmpty
                ? const Text('Nenhum problema registrado.')
                : Column(
                    children: problemas
                        .map((problema) => _buildProblemCard(problema))
                        .toList(),
                  )
          ],
        ),
      ),
    );
  }

  Widget _buildProblemCard(Map<String, dynamic> problema) {
    return Card(
      elevation: 2,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patrimônio: ${problema['patrimonio']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Problema: ${problema['Problemas'] ?? 'Sem Problema'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Local: ${problema['Local'] ?? 'Sem Local'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Observações: ${problema['Observacoes'] ?? 'Sem Observações'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Status: ${problema['Status'] ?? 'Sem Status'}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      maxLines: maxLines,
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _problemaSelecionado,
      items: problemaOptions.map((problema) {
        return DropdownMenuItem<String>(
          value: problema,
          child: Text(
            problema,
            style: const TextStyle(color: Colors.black),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _problemaSelecionado = value;
        });
      },
      decoration: const InputDecoration(
        labelText: 'Selecione o Problema',
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _statusSelecionado,
      items: statusOptions.map((status) {
        return DropdownMenuItem<String>(
          value: status['nome'],
          child: Text(
            status['nome'],
            style: const TextStyle(color: Colors.black),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _statusSelecionado = value;
        });
      },
      decoration: const InputDecoration(
        labelText: 'Selecione o Status',
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
