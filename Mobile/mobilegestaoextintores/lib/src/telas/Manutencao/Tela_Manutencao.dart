import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ManutencaoExtintorPage extends StatefulWidget {
  @override
  _ManutencaoExtintorPageState createState() => _ManutencaoExtintorPageState();
}

class _ManutencaoExtintorPageState extends State<ManutencaoExtintorPage> {
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController responsavelController = TextEditingController();
  final TextEditingController observacoesController = TextEditingController();
  DateTime? dataManutencao;
  DateTime? ultimaRecarga;
  DateTime? proximaInspecao;
  DateTime? vencimento;
  int? idExtintor;
  bool revisarStatus = false;

  List<Map<String, dynamic>> extintores = []; // Declare a lista extintores aqui
  List<Map<String, dynamic>> statusOptions = [];

  @override
  void initState() {
    super.initState();
    _carregarExtintores();
    _carregarStatus(); // Carregar status no initState
  }

  Future<void> _carregarStatus() async {
    final url = Uri.parse('http://10.2.0.32:3001/status');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          statusOptions = List<Map<String, dynamic>>.from(data['data']);
        });
      }
    }
  }

  Future<void> _carregarExtintores() async {
    final url = Uri.parse(
        'http://10.2.0.32:3001/extintores-com-problemas'); // Novo endpoint
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          extintores = List<Map<String, dynamic>>.from(data['extintores']);
        });
      }
    }
  }

  Future<void> _selecionarData(BuildContext context, String tipoData) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        switch (tipoData) {
          case 'manutencao':
            dataManutencao = picked;
            break;
          case 'recarga':
            ultimaRecarga = picked;
            break;
          case 'inspecao':
            proximaInspecao = picked;
            break;
          case 'vencimento':
            vencimento = picked;
            break;
        }
      });
    }
  }

  Future<void> _salvarManutencao() async {
    if (idExtintor == null ||
        descricaoController.text.isEmpty ||
        responsavelController.text.isEmpty ||
        dataManutencao == null ||
        ultimaRecarga == null ||
        proximaInspecao == null ||
        vencimento == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Todos os campos devem ser preenchidos"),
      ));
      return;
    }

    final url = Uri.parse('http://10.2.0.32:3001/salvar_manutencao');
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'patrimonio': idExtintor,
          'descricao': descricaoController.text,
          'responsavel': responsavelController.text,
          'observacoes': observacoesController.text,
          'data_manutencao': DateFormat('yyyy-MM-dd').format(dataManutencao!),
          'ultima_recarga': DateFormat('yyyy-MM-dd').format(ultimaRecarga!),
          'proxima_inspecao': DateFormat('yyyy-MM-dd').format(proximaInspecao!),
          'data_vencimento': DateFormat('yyyy-MM-dd').format(vencimento!),
          'revisar_status': revisarStatus,
        }));

    if (response.statusCode == 200) {
      // Excluir o registro de problema após salvar a manutenção
      final deleteUrl = Uri.parse('http://10.2.0.32:3001/excluir_problema');
      final deleteResponse = await http.post(deleteUrl,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'patrimonio': idExtintor}));

      // Verifique a resposta do deleteResponse
      if (deleteResponse.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Manutenção salva e problema excluído com sucesso!"),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Erro ao excluir problema: ${deleteResponse.body}"),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      appBar: AppBar(
        title: const Text(
          "Histórico de Manutenção", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD9D9D9)),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF011689),
        elevation: 4,
        iconTheme: const IconThemeData(color: Color(0xFFD9D9D9)),
      ),
      body: Center(
        child: Card(
          elevation: 8,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: const Color.fromARGB(255, 254, 252, 252), // Cor do card
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Selecione o Extintor:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: idExtintor,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white, // Cor do campo
                    ),
                    hint: const Text("Selecione o extintor"),
                    items: extintores.map((extintor) {
                      return DropdownMenuItem<int>(
                        value: extintor['Patrimonio'],
                        child: Text('Extintor ${extintor['Patrimonio']}'),
                      );
                    }).toList(),
                    onChanged: (int? value) {
                      setState(() {
                        idExtintor = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                      descricaoController, "Descrição da Manutenção"),
                  const SizedBox(height: 16),
                  _buildTextField(responsavelController, "Responsável"),
                  const SizedBox(height: 16),
                  _buildTextField(observacoesController, "Observações"),
                  const SizedBox(height: 16),

                  // Fila de duas datas (Data de Manutenção e Última Recarga)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildDateField(
                            "Data de Manutenção", dataManutencao, 'manutencao'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDateField(
                            "Última Recarga", ultimaRecarga, 'recarga'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Fila de duas datas (Próxima Inspeção e Vencimento)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildDateField(
                            "Próxima Inspeção", proximaInspecao, 'inspecao'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDateField(
                            "Vencimento", vencimento, 'vencimento'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: revisarStatus
                        ? 'Ativo'
                        : null, // Defina um valor padrão se necessário
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white, // Cor do campo
                    ),
                    hint: const Text("Selecione o Status"),
                    items: statusOptions.map((status) {
                      return DropdownMenuItem<String>(
                        value: status['nome'],
                        child: Text(status['nome']),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        revisarStatus = value ==
                            'Ativo'; // Atualiza a variável revisarStatus
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: _salvarManutencao,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF011689),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                      ),
                      child: const Text(
                        "Salvar Manutenção",
                        style:
                            TextStyle(fontSize: 16, color: Color(0xFFD9D9D9)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white, // Cor dos campos
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? date, String tipoData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            side: BorderSide(color: Colors.grey.shade400),
          ),
          onPressed: () => _selecionarData(context, tipoData),
          child: Text(
            date == null
                ? "Selecione a data"
                : DateFormat('dd/MM/yyyy').format(date),
            style: TextStyle(color: date == null ? Colors.grey : Colors.black),
          ),
        ),
      ],
    );
  }
}
