import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TelaAtualizarExtintor extends StatefulWidget {
  @override
  _TelaAtualizarExtintorState createState() => _TelaAtualizarExtintorState();
}

class _TelaAtualizarExtintorState extends State<TelaAtualizarExtintor> {
  final _patrimonioController = TextEditingController();
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
  String? _qrCodeUrl;

  List<Map<String, dynamic>> tipos = [];
  List<Map<String, dynamic>> linhas = [];
  List<Map<String, dynamic>> status = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true;
    });
    await Future.wait([fetchTipos(), fetchLinhas(), fetchStatus()]);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> fetchTipos() async {
    final response = await http.get(Uri.parse('http://localhost:3001/tipos-extintores'));
    if (response.statusCode == 200) {
      setState(() {
        tipos = List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
      });
    }
  }

  Future<void> fetchLinhas() async {
    final response = await http.get(Uri.parse('http://localhost:3001/linhas'));
    if (response.statusCode == 200) {
      setState(() {
        linhas = List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
      });
    }
  }

  Future<void> fetchStatus() async {
    final response = await http.get(Uri.parse('http://localhost:3001/status'));
    if (response.statusCode == 200) {
      setState(() {
        status = List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
      });
    }
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '';
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(date));
    } catch (e) {
      return ''; // Return an empty string if parsing fails
    }
  }

  Future<void> _buscarExtintor() async {
    final patrimonio = _patrimonioController.text;
    if (patrimonio.isEmpty) {
      _showErrorDialog('Por favor, insira o patrimônio.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse('http://localhost:3001/extintor/$patrimonio'));
    if (response.statusCode == 200) {
      final extintor = json.decode(response.body)['extintor'];
      _codigoFabricanteController.text = extintor['Codigo_Fabricante'] ?? '';
      _dataFabricacaoController.text = _formatDate(extintor['Data_Fabricacao']);
      _dataValidadeController.text = _formatDate(extintor['Data_Validade']);
      _ultimaRecargaController.text = _formatDate(extintor['Ultima_Recarga']);
      _proximaInspecaoController.text = _formatDate(extintor['Proxima_Inspecao']);
      _descricaoLocalController.text = extintor['Descricao_Local'] ?? '';
      _observacaoLocalController.text = extintor['Observacoes_Local'] ?? '';
      _estacaoController.text = extintor['Estacao'] ?? '';
      _tipoSelecionado = extintor['Tipo_ID'].toString();
      _linhaSelecionada = extintor['Linha_ID']. toString();
      _statusSelecionado = extintor['status_id'].toString();
      _qrCodeUrl = extintor['QR_Code'] ?? '';
    } else {
      _showErrorDialog('Erro ao buscar extintor: ${response.body}');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _atualizarExtintor() async {
    final patrimonio = _patrimonioController.text;
    if (patrimonio.isEmpty) {
      _showErrorDialog('Por favor, insira o patrimônio.');
      return;
    }

    // Validate date fields
    String dataFabricacao = _dataFabricacaoController.text;
    String dataValidade = _dataValidadeController.text;
    String ultimaRecarga = _ultimaRecargaController.text;
    String proximaInspecao = _proximaInspecaoController.text;

    if (dataFabricacao.isEmpty || dataValidade.isEmpty || 
        ultimaRecarga.isEmpty || proximaInspecao.isEmpty) {
      _showErrorDialog('Por favor, preencha todos os campos de data.');
      return;
    }

    DateTime? parsedDataFabricacao;
    DateTime? parsedDataValidade;
    DateTime? parsedUltimaRecarga;
    DateTime? parsedProximaInspecao;

    try {
      parsedDataFabricacao = DateFormat('dd/MM/yyyy').parseStrict(dataFabricacao);
      parsedDataValidade = DateFormat('dd/MM/yyyy').parseStrict(dataValidade);
      parsedUltimaRecarga = DateFormat('dd/MM/yyyy').parseStrict(ultimaRecarga);
      parsedProximaInspecao = DateFormat('dd/MM/yyyy').parseStrict(proximaInspecao);
    } catch (e) {
      _showErrorDialog('Formato de data inválido. Por favor, use DD/MM/YYYY.');
      return;
    }

    String formattedDataFabricacao = DateFormat('yyyy-MM-dd').format(parsedDataFabricacao);
    String formattedDataValidade = DateFormat('yyyy-MM-dd').format(parsedDataValidade);
    String formattedUltimaRecarga = DateFormat('yyyy-MM-dd').format(parsedUltimaRecarga);
    String formattedProximaInspecao = DateFormat('yyyy-MM-dd').format(parsedProximaInspecao);

    final response = await http.put(
      Uri.parse('http://localhost:3001/extintor/$patrimonio'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "Codigo_Fabricante": _codigoFabricanteController.text,
        "Data_Fabricacao": formattedDataFabricacao,
        "Data_Validade": formattedDataValidade,
        "Ultima_Recarga": formattedUltimaRecarga,
        "Proxima_Inspecao": formattedProximaInspecao,
        "Tipo_ID": _tipoSelecionado,
        "Linha_ID": _linhaSelecionada,
        "Status_ID": _statusSelecionado,
        "Observacoes": _observacoesController.text,
        "Descricao_Local": _descricaoLocalController.text,
        "Observacao_Local": _observacaoLocalController.text,
        "Estacao": _estacaoController.text,
      }),
    );

    if (response.statusCode == 200) {
      _showSuccessDialog('Extintor atualizado com sucesso!');
    } else {
      _showErrorDialog('Erro ao atualizar extintor: ${response.body}');
    }
  }

  Future<void> _gerarQRCode(String patrimonio) async {
    final response = await http.post(
      Uri.parse('http://localhost:3001/gerar_qrcode'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"patrimonio": patrimonio}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _qrCodeUrl = data['qrCodeUrl'] ?? '';
      });
    } else {
      _showErrorDialog('Erro ao gerar QR Code: ${response.body}');
    }
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
      appBar: AppBar(
        title: const Text('Atualizar Extintor',
        style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFFD9D9D9))),
        centerTitle: true,
        backgroundColor: const Color(0xFF011689),
        elevation: 4,
        iconTheme: const IconThemeData(color: Color(0xFFD9D9D9)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 20),
                    _buildOptionCard(
                      title: "Buscar Extintor",
                      description:
                          "Insira o patrimônio do extintor para buscar suas informações.",
                      child: _buildTextField(
                          controller: _patrimonioController,
                          label: 'Patrimônio'),
                      onPressed: _buscarExtintor,
                    ),
                    const SizedBox(height: 20),
                    _buildOptionCard(
                      title: "Atualizar Dados do Extintor",
                      description:
                          "Atualize as informações do extintor após a busca.",
                      child: Column(
                        children: [
                          _buildTextField(
                              controller: _codigoFabricanteController,
                              label: 'Código do Fabricante'),
                          const SizedBox(height: 12),
                          _buildTextField(
                              controller: _dataFabricacaoController,
                              label: 'Data de Fabricação',
                              isDate: true),
                          const SizedBox(height: 12),
                          _buildTextField(
                              controller: _dataValidadeController,
                              label: 'Data de Validade',
                              isDate: true),
                          const SizedBox(height: 12),
                          _buildTextField(
                              controller: _ultimaRecargaController,
                              label: 'Última Recarga',
                              isDate: true),
                          const SizedBox(height: 12),
                          _buildTextField(
                              controller: _proximaInspecaoController,
                              label: 'Próxima Inspeção',
                              isDate: true),
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
                            displayItem: (item) => item['nome'],
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
                          _buildTextField(
                              controller: _estacaoController, label: 'Estação'),
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
                              label: 'Descrição do Local'),
                          const SizedBox(height: 12),
                          _buildTextField(
                              controller: _observacaoLocalController,
                              label: 'Observação sobre o local'),
                          const SizedBox(height: 12),
                          _buildTextField(
                              controller: _observacoesController,
                              label: 'Observações do Extintor'),
                        ],
                      ),
                      onPressed: _atualizarExtintor,
                    ),
                    const SizedBox(height: 20),
                    if (_qrCodeUrl != null) ...[
                      Image.network(
                        _qrCodeUrl!,
                        errorBuilder: (context, error, stackTrace) {
                          print("Erro ao carregar imagem: $error");
                          return const Text("Erro ao carregar QR Code.");
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _printQRCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF011689),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                        ),
                        child: const Text('Imprimir QR Code',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String description,
    required Widget child,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF011689),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            child,
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF011689),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                "Confirmar",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
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
        filled: true,
        fillColor: const Color(0xFFE3F2FD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: const Color(0xFF011689)),
        ),
      ),
      onTap: isDate ? () => _selectDate(controller) : null,
      validator: (value) {
        if (isDate && (value == null || value.isEmpty)) {
          return 'Data é obrigatória';
        }
        return null;
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
    bool isValueValid = items.any((item) => item['id'].toString() == value);

    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: isValueValid ? value : null,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item['id'].toString(),
          child: Text(displayItem(item)),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFE3F2FD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: const Color(0xFF011689)),
        ),
      ),
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
}
