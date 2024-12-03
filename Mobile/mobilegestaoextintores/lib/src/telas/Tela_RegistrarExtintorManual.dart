import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelaRegistrarExtintor extends StatefulWidget {
  const TelaRegistrarExtintor({super.key});

  @override
  _TelaRegistrarExtintorState createState() => _TelaRegistrarExtintorState();
}

class _TelaRegistrarExtintorState extends State<TelaRegistrarExtintor> {
  final _patrimonioController = TextEditingController();
  final _codigoFabricanteController = TextEditingController();
  final _dataFabricacaoController = TextEditingController();
  final _dataValidadeController = TextEditingController();
  final _ultimaRecargaController = TextEditingController();
  final _proximaInspecaoController = TextEditingController();
  final _observacoesController =
      TextEditingController(); // Observações do extintor
  final _descricaoLocalController = TextEditingController();
  final _observacaoLocalController =
      TextEditingController(); // Observação do local
  final _estacaoController =
      TextEditingController(); // Novo controlador para a estação

  String? _tipoSelecionado;
  String? _linhaSelecionada;
  String? _statusSelecionado;
  String? _qrCodeUrl;
  String? _capacidadeSelecionada;

  List<Map<String, dynamic>> tipos = [];
  List<Map<String, dynamic>> linhas = [];
  List<Map<String, dynamic>> localizacoesFiltradas = [];
  List<Map<String, dynamic>> status = [];
  List<Map<String, dynamic>> capacidades = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() {});
    await Future.wait(
        [fetchTipos(), fetchLinhas(), fetchStatus(), fetchCapacidades()]);
    setState(() {});
  }

  Future<void> fetchCapacidades() async {
    final response =
        await http.get(Uri.parse('http://localhost:3001/capacidades'));
    if (response.statusCode == 200) {
      try {
        var data = json.decode(response.body);
        if (data['data'] != null) {
          setState(() {
            capacidades = List<Map<String, dynamic>>.from(data['data'] ?? []);
          });
          print('Capacidades carregadas: $capacidades');
        } else {
          _showErrorDialog('Capacidades não encontradas.');
        }
      } catch (e) {
        _showErrorDialog('Erro ao decodificar a resposta: $e');
      }
    } else {
      _showErrorDialog('Erro ao carregar capacidades: ${response.statusCode}');
    }
  }

  Future<void> fetchTipos() async {
    final prefs = await SharedPreferences.getInstance();
    String? cachedTipos = prefs.getString('tipos');

    if (cachedTipos != null) {
      setState(() {
        tipos =
            List<Map<String, dynamic>>.from(json.decode(cachedTipos)['data']);
      });
      print('Tipos carregados do cache: $tipos');
    } else {
      final response =
          await http.get(Uri.parse('http://localhost:3001/tipos-extintores'));

      if (response.statusCode == 200) {
        print('Tipos retornados da API: ${response.body}');
        prefs.setString('tipos', response.body);
        setState(() {
          tipos = List<Map<String, dynamic>>.from(
              json.decode(response.body)['data']);
        });
      } else {
        print('Erro ao carregar tipos: ${response.statusCode}');
      }
    }
  }

  Future<void> fetchLinhas() async {
    final response = await http.get(Uri.parse('http://localhost:3001/linhas'));
    if (response.statusCode == 200) {
      setState(() {
        linhas =
            List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
      });
    }
  }

  Future<void> fetchLocalizacoes(String linhaId) async {
    final response = await http
        .get(Uri.parse('http://localhost:3001/localizacoes?linhaId=$linhaId'));
    if (response.statusCode == 200) {
      setState(() {
        localizacoesFiltradas =
            List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
      });
    }
  }

  Future<void> fetchStatus() async {
    final response = await http.get(Uri.parse('http://localhost:3001/status'));
    if (response.statusCode == 200) {
      setState(() {
        status =
            List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
      });
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  Future<void> _registrarExtintor() async {
    print("Patrimônio: ${_patrimonioController.text}");
    print("Tipo: $_tipoSelecionado");
    print("Capacidade: $_capacidadeSelecionada");
    print("Linha: $_linhaSelecionada");
    print(
        "Estação: ${_estacaoController.text}"); // Atualizado para mostrar o valor da estação
    print("Status: $_statusSelecionado");

    if (_patrimonioController.text.isEmpty ||
        _tipoSelecionado == null ||
        _capacidadeSelecionada == null ||
        _linhaSelecionada == null ||
        _estacaoController
            .text.isEmpty || // Verifique se a estação está preenchida
        _statusSelecionado == null) {
      _showErrorDialog('Por favor, preencha todos os campos obrigatórios.');
      return;
    }

    final extintorData = {
      "patrimonio": _patrimonioController.text,
      "tipo_id": _tipoSelecionado,
      "capacidade_id": _capacidadeSelecionada,
      "codigo_fabricante": _codigoFabricanteController.text,
      "data_fabricacao": _dataFabricacaoController.text,
      "data_validade": _dataValidadeController.text,
      "ultima_recarga": _ultimaRecargaController.text,
      "proxima_inspecao": _proximaInspecaoController.text,
      "linha_id": _linhaSelecionada,
      "estacao": _estacaoController.text, // Usando o novo campo de texto
      "descricao_local": _descricaoLocalController.text,
      "observacoes_local": _observacaoLocalController.text,
      "observacoes": _observacoesController.text,
      "status": _statusSelecionado,
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3001/registrar_extintor'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(extintorData),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        print("Resposta do servidor: $responseData");
        setState(() {
          _qrCodeUrl = responseData['qrCodeUrl'] ?? '';
        });

        _showSuccessDialog('Extintor registrado com sucesso!');
      } else {
        print("Erro no registro: ${response.body}");
        _showErrorDialog('Erro ao registrar extintor: ${response.body}');
      }
    } catch (e) {
      print("Erro ao conectar: $e");
      _showErrorDialog('Erro de conexão: $e');
    }
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

  Widget _buildDropdown({
    required String label,
    required List<Map<String, dynamic>> items,
    String? value,
    required Function(String?) onChanged,
    required String Function(Map<String, dynamic>) displayItem,
  }) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: value,
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item['id'].toString(),
              child: Text(displayItem(item)),
            ),
          )
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: const Color(0xFFF4F4F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isDate = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: isDate,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: const Color(0xFFF4F4F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      onTap: isDate ? () => _selectDate(controller) : null,
    );
  }

  Future<void> _printQRCode() async {
    if (_qrCodeUrl == null) return;

    try {
      final response = await http.get(Uri.parse(_qrCodeUrl!));
      if (response.statusCode == 200) {
        final imageBytes = response.bodyBytes;
        final pdf = pw.Document();

        pdf.addPage(pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(pw.MemoryImage(imageBytes)),
            );
          },
        ));

        await Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
          return pdf.save();
        });
      } else {
        _showErrorDialog('Falha ao carregar o QR Code.');
      }
    } catch (e) {
      _showErrorDialog('Erro ao tentar baixar a imagem: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      appBar: AppBar(
        title: const Text('Registrar Extintor',
          style: TextStyle(
            fontWeight: FontWeight.bold, color: Color(0xFFD9D9D9))),
        backgroundColor: const Color(0xFF011689),
        centerTitle: true,
        elevation: 4,
        foregroundColor: const Color(0xFFD9D9D9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Color(0xFFD9D9D9),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Card(
              elevation: 5,
              color: Color.fromARGB(255, 255, 255, 255),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    _buildTextField(
                      controller: _patrimonioController,
                      label: 'Patrimônio',
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      label: 'Tipo',
                      items: tipos,
                      value: _tipoSelecionado,
                      onChanged: (value) {
                        setState(() {
                          _tipoSelecionado = value;
                        });
                      },
                      displayItem: (item) =>
                          item['nome'] ?? 'Nome não disponível',
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      label: 'Capacidade',
                      items: capacidades,
                      value: _capacidadeSelecionada,
                      onChanged: (value) {
                        setState(() {
                          _capacidadeSelecionada = value;
                        });
                      },
                      displayItem: (item) =>
                          item['descricao'] ?? 'Descrição não disponível',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _codigoFabricanteController,
                      label: 'Código do Fabricante',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _dataFabricacaoController,
                      label: 'Data de Fabricação',
                      isDate: true,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _dataValidadeController,
                      label: 'Data de Validade',
                      isDate: true,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                        controller: _ultimaRecargaController,
                        label: 'Última Recarga',
                        isDate: true),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _proximaInspecaoController,
                      label: 'Próxima Inspeção',
                      isDate: true,
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      label: 'Linha',
                      items: linhas,
                      value: _linhaSelecionada,
                      onChanged: (value) {
                        setState(() {
                          _linhaSelecionada = value;
// Reseta a localização ao mudar a linha
                          if (value != null) {
                            fetchLocalizacoes(value);
                          }
                        });
                      },
                      displayItem: (item) => item['nome'],
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _estacaoController,
                      label: 'Estação', // Novo campo para a estação
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      label: 'Status',
                      items: status,
                      value: _statusSelecionado,
                      onChanged: (value) {
                        setState(() {
                          _statusSelecionado = value;
                        });
                      },
                      displayItem: (item) => item['nome'],
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _descricaoLocalController,
                      label: 'Descrição do Local',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _observacaoLocalController,
                      label: 'Observação sobre o local',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _observacoesController,
                      label: 'Observações do Extintor',
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _registrarExtintor,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF011689),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Registrar',
                        style: TextStyle(color: Color(0xFFD9D9D9)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_qrCodeUrl != null)
                      Column(
                        children: [
                          Image.network(
                            _qrCodeUrl!,
                            errorBuilder: (context, error, stackTrace) {
                              print("Erro ao carregar imagem: $error");
                              return const Text("Erro ao carregar QR Code.");
                            },
                          ),
                          ElevatedButton(
                            onPressed: _printQRCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF011689),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Imprimir QR Code'),
                          ),
                        ],
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
