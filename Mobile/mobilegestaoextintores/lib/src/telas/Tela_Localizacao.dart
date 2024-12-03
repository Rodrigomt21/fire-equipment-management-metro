import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TelaConsultaLocalizacaoExtintor extends StatefulWidget {
  const TelaConsultaLocalizacaoExtintor({Key? key}) : super(key: key);

  @override
  _TelaConsultaLocalizacaoExtintorState createState() =>
      _TelaConsultaLocalizacaoExtintorState();
}

class _TelaConsultaLocalizacaoExtintorState
    extends State<TelaConsultaLocalizacaoExtintor> {
  final TextEditingController _patrimonioController = TextEditingController();
  String _patrimonio = "";
  bool _isLoading = false;
  Map<String, dynamic>? _localizacaoData;
  String _errorMessage = "";

  Future<void> _buscarLocalizacao() async {
    if (_patrimonio.isEmpty) {
      _showSnackBar("Por favor, insira o número do patrimônio.");
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    final url = Uri.parse(
        'http://localhost:3001/extintor/localizacao/$_patrimonio'); // Substitua localhost pelo IP da sua máquina

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _localizacaoData = data['localizacao'];
            _showSnackBar("Localização encontrada!", color: Colors.green);
          });
        } else {
          setState(() {
            _errorMessage = "Extintor não encontrado.";
            _showSnackBar(_errorMessage);
          });
        }
      } else {
        setState(() {
          _errorMessage = "Erro ao buscar localização.";
          _showSnackBar(_errorMessage);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Erro na conexão. Verifique sua internet.";
        _showSnackBar(_errorMessage);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      appBar: AppBar(
        title: const Text('Consulta de Localização do Extintor',
        style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFFD9D9D9))),
        backgroundColor: const Color(0xFF011689),
        centerTitle: true,
        elevation: 4,
        iconTheme: const IconThemeData(color: Color(0xFFD9D9D9)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputSection(),
              const SizedBox(height: 20),
              if (_errorMessage.isNotEmpty) _buildErrorMessage(),
              if (_localizacaoData != null) _buildLocalizacaoDetails(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _patrimonioController,
            decoration: InputDecoration(
              labelText: 'Número do Patrimônio',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: const Color(0xFFF7F9FC),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF011689)),
            ),
            onChanged: (value) {
              setState(() {
                _patrimonio = value;
              });
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _buscarLocalizacao,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF011689),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 3,
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Buscar Localização',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        _errorMessage,
        style: const TextStyle(color: Colors.red, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLocalizacaoDetails() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Localização do Extintor',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            Text('Linha: ${_localizacaoData!['Linha']}',
                style: const TextStyle(fontSize: 16)),
            Text('Estação: ${_localizacaoData!['Estacao']}',
                style: const TextStyle(fontSize: 16)),
            Text('Descrição Local: ${_localizacaoData!['Descricao_Local']}',
                style: const TextStyle(fontSize: 16)),
            Text('Observações: ${_localizacaoData!['Observacoes'] ?? 'N/A'}',
                style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
