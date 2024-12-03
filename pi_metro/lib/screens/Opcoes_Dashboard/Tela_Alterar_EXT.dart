import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class TelaEditarExtintor extends StatefulWidget {
  final String patrimonio;

  const TelaEditarExtintor({super.key, required this.patrimonio});

  @override
  _TelaEditarExtintorState createState() => _TelaEditarExtintorState();
}

class _TelaEditarExtintorState extends State<TelaEditarExtintor> {
  final _codigoFabricanteController = TextEditingController();
  final _dataFabricacaoController = TextEditingController();
  final _dataValidadeController = TextEditingController();
  final _ultimaRecargaController = TextEditingController();
  final _proximaInspecaoController = TextEditingController();
  final _observacoesController = TextEditingController();
  final _descricaoLocalController = TextEditingController();
  final _observacaoLocalController = TextEditingController();
  final _estacaoController = TextEditingController();

  String? _tipoSelecionado;
  String? _linhaSelecionada;
  String? _statusSelecionado;
  String? _capacidadeSelecionada;

  List<Map<String, dynamic>> tipos = [];
  List<Map<String, dynamic>> linhas = [];
  List<Map<String, dynamic>> status = [];
  List<Map<String, dynamic>> capacidades = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _fetchExtintorData(); // Busca os dados do extintor para edição
  }

  Future<void> _fetchInitialData() async {
    await Future.wait([
      fetchTipos(),
      fetchLinhas(),
      fetchStatus(),
      fetchCapacidades(),
    ]);
  }

  Future<void> _fetchExtintorData() async {
    final response = await http.get(Uri.parse('http://localhost:3000/extintor/${widget.patrimonio}'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['success']) {
        // Preencha os campos com os dados do extintor
        var extintor = data['extintor'];
        _codigoFabricanteController.text = extintor['Codigo_Fabricante'];
        _dataFabricacaoController.text = extintor['Data_Fabricacao'];
        _dataValidadeController.text = extintor['Data_Validade'];
        _ultimaRecargaController.text = extintor['Ultima_Recarga'];
        _proximaInspecaoController.text = extintor['Proxima_Inspecao'];
        _observacoesController.text = extintor['Observacoes'];
        _descricaoLocalController.text = extintor['Descricao_Local'];
        _observacaoLocalController.text = extintor['Observacoes_Local'];
        _estacaoController.text = extintor['Estacao'];

        setState(() {
          _tipoSelecionado = extintor['Tipo_ID'].toString();
          _linhaSelecionada = extintor['Linha_ID'].toString();
          _statusSelecionado = extintor['Status_ID'].toString();
          _capacidadeSelecionada = extintor['Capacidade_ID'].toString();
        });
      } else {
        _showErrorDialog('Extintor não encontrado.');
      }
    } else {
      _showErrorDialog('Erro ao carregar dados do extintor: ${response.statusCode}');
    }
  }

  Future<void> fetchCapacidades() async {
    final response = await http.get(Uri.parse('http://localhost:3000/capacidades'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        capacidades = List<Map<String, dynamic>>.from(data['data'] ?? []);
      });
    }
  }

  Future<void> fetchTipos() async {
    final response = await http.get(Uri.parse('http://localhost:3000/tipos-extintores'));
    if (response.statusCode == 200) {
      setState(() {
        tipos = List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
      });
    }
  }

  Future<void> fetchLinhas() async {
    final response = await http.get(Uri.parse('http://localhost: 3000/linhas'));
    if (response.statusCode == 200) {
      setState(() {
        linhas = List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
      });
    }
  }

  Future<void> fetchStatus() async {
    final response = await http.get(Uri.parse('http://localhost:3000/status'));
    if (response.statusCode == 200) {
      setState(() {
        status = List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
      });
    }
  }

  Future<void> _updateExtintor() async {
    final extintorData = {
      "codigo_fabricante": _codigoFabricanteController.text,
      "data_fabricacao": _dataFabricacaoController.text,
      "data_validade": _dataValidadeController.text,
      "ultima_recarga": _ultimaRecargaController.text,
      "proxima_inspecao": _proximaInspecaoController.text,
      "tipo_id": _tipoSelecionado,
      "linha_id": _linhaSelecionada,
      "status_id": _statusSelecionado,
      "observacoes": _observacoesController.text,
      "descricao_local": _descricaoLocalController.text,
      "observacoes_local": _observacaoLocalController.text,
      "estacao": _estacaoController.text,
    };

    try {
      final response = await http.put(
        Uri.parse('http://localhost:3000/extintor/${widget.patrimonio}'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(extintorData),
      );

      if (response.statusCode == 200) {
        _showSuccessDialog('Extintor atualizado com sucesso!');
      } else {
        _showErrorDialog('Erro ao atualizar extintor: ${response.body}');
      }
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Extintor',
          style: TextStyle(
            fontWeight: FontWeight.bold, color: Color(0xFFD9D9D9))),
        backgroundColor: const Color(0xFF011689),
        centerTitle: true,
        elevation: 4,
        foregroundColor: const Color(0xFFD9D9D9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Card(
              elevation: 5,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
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
                      isDate: true,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _proximaInspecaoController,
                      label: 'Próxima Inspeção',
                      isDate: true,
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
                      displayItem: (item) => item['nome'] ?? 'Nome não disponível',
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      label: 'Linha',
                      items: linhas,
                      value: _linhaSelecionada,
                      onChanged: (value) {
                        setState(() {
                          _linhaSelecionada = value;
                        });
                      },
                      displayItem: (item) => item['nome'],
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
                      onPressed: _updateExtintor,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF011689),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Atualizar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
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