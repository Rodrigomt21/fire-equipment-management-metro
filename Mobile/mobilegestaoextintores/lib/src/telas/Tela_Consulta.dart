import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class TelaConsultaExtintor extends StatefulWidget {
  const TelaConsultaExtintor({Key? key}) : super(key: key);

  @override
  _TelaConsultaExtintorState createState() => _TelaConsultaExtintorState();
}

class _TelaConsultaExtintorState extends State<TelaConsultaExtintor> {
  final TextEditingController _patrimonioController = TextEditingController();
  String _patrimonio = "";
  bool _isLoading = false;
  Map<String, dynamic>? _extintorData;
  String _errorMessage = "";
  List<String> _patrimoniosDisponiveis = [];

  String formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy HH:mm:ss').format(parsedDate);
    } catch (e) {
      return 'Data inválida';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchPatrimoniosDisponiveis();
  }

  Future<void> _fetchPatrimoniosDisponiveis() async {
    setState(() {
      _errorMessage = '';
    });

    try {
      final url = Uri.parse(
          'http://localhost:3001/patrimonio'); // Substitua localhost pelo IP da sua máquina
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _patrimoniosDisponiveis = (data['patrimônios'] as List)
                .map((item) => item.toString())
                .toList();
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? "Falha ao carregar patrimônios.";
          });
        }
      } else {
        setState(() {
          _errorMessage =
              "Erro ao carregar patrimônios. Tente novamente mais tarde.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Erro na conexão. Verifique sua internet.";
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

  Future<void> _buscarExtintor() async {
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
        'http://localhost:3001/extintor/$_patrimonio'); // Substitua localhost pelo IP da sua máquina

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _extintorData = data['extintor'];
            _showSnackBar("Extintor encontrado!", color: Colors.green);
          });
        } else {
          setState(() {
            _errorMessage = "Extintor não encontrado.";
            _showSnackBar(_errorMessage);
          });
        }
      } else {
        setState(() {
          _errorMessage = "Erro ao buscar extintor.";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Consulta',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFD9D9D9),
          ),
        ),
        backgroundColor: const Color(0xFF011689),
        centerTitle: true,
        elevation: 4,
        iconTheme: const IconThemeData(
          color: Color(0xFFD9D9D9),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputSection(),
              if (_errorMessage.isNotEmpty) _buildErrorMessage(),
              if (_extintorData != null) _buildExtintorDetails(),
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
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Selecione o Patrimônio',
              labelStyle: const TextStyle(color: Color(0xFF011689)),
              filled: true,
              fillColor: const Color(0xFFF7F9FC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            items: _patrimoniosDisponiveis.map((String patrimonio) {
              return DropdownMenuItem<String>(
                value: patrimonio,
                child: Text(patrimonio),
              );
            }).toList(),
            onChanged: (String? value) {
              if (value != null) {
                setState(() {
                  _patrimonio = value;
                  _patrimonioController.text = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _patrimonioController,
            decoration: InputDecoration(
              labelText: 'Ou digite o número do Patrimônio',
              labelStyle: const TextStyle(color: Color(0xFF011689)),
              filled: true,
              fillColor: const Color(0xFFF7F9FC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              hintText: 'Digite ou selecione acima',
              prefixIcon: const Icon(Icons.edit, color: Color(0xFF011689)),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _patrimonio = value;
              });
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _buscarExtintor,
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
                    'Buscar Extintor',
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

  Widget _buildExtintorDetails() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildDetailCard('Informações do Extintor', [
          'Patrimônio: ${_extintorData!['Patrimonio']}',
          'Capacidade: ${_extintorData!['Capacidade']}',
          'Tipo: ${_extintorData!['Tipo']}',
          'Código do Fabricante: ${_extintorData!['Codigo_Fabricante']}',
          'Data de Fabricação: ${formatDate(_extintorData!['Data_Fabricacao'])}',
          'Data de Validade: ${formatDate(_extintorData!['Data_Validade'])}',
          'Última Recarga: ${formatDate(_extintorData!['Ultima_Recarga'])}',
          'Próxima Inspeção : ${formatDate(_extintorData!['Proxima_Inspecao'])}',
          'Status: ${_extintorData!['Status']}',
          'Observações: ${_extintorData!['Observacoes_Extintor']}',
        ]),
        const SizedBox(height: 20),
        _buildQrCode(_extintorData!['QR_Code']),
        const SizedBox(height: 20),
        _buildDetailCard('Localização do Extintor', [
          'Estação: ${_extintorData!['Estacao']}',
          'Descrição: ${_extintorData!['Descricao_Local']}',
          'Observações: ${_extintorData!['Observacoes_Local']}',
        ]),
        const SizedBox(height: 20),
        _buildDetailCard('Linha Associada', [
          'Nome: ${_extintorData!['Linha_Nome']}',
          'Código: ${_extintorData!['Linha_Codigo']}',
          'Descrição: ${_extintorData!['Linha_Descricao']}',
        ]),
        const SizedBox(height: 20),
        _buildDetailCard('Histórico de Manutenção', [
          'Data da Manutenção: ${formatDate(_extintorData!['Data_Manutencao'] ?? "Não disponível")}',
          'Responsável: ${_extintorData!['Responsavel_Manutencao'] ?? "Não disponível"}',
          'Descrição: ${_extintorData!['Manutencao_Descricao'] ?? "Não disponível"}',
          'Observações: ${_extintorData!['Manutencao_Observacoes'] ?? "Não disponível"}',
        ]),
      ],
    );
  }

  Widget _buildQrCode(String? qrCodeUrl) {
    if (qrCodeUrl == null || qrCodeUrl.isEmpty) {
      return const Center(
        child: Text(
          "QR Code não disponível",
          style: TextStyle(fontSize: 16, color: Colors.red),
        ),
      );
    }

    final qrCodeImageUrl = qrCodeUrl.startsWith('http')
        ? qrCodeUrl
        : 'http://localhost:3001/$qrCodeUrl';

    return Image.network(
      qrCodeImageUrl,
      height: 200.0,
      width: 200.0,
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Text(
            "Erro ao carregar o QR Code",
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _buildDetailCard(String title, List<String> items) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(item, style: const TextStyle(fontSize: 16)),
                )),
          ],
        ),
      ),
    );
  }
}
