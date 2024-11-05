import 'package:flutter/material.dart';

class TelaRegistrarExtintor extends StatefulWidget {
  @override
  _TelaRegistrarExtintorState createState() => _TelaRegistrarExtintorState();
}

class _TelaRegistrarExtintorState extends State<TelaRegistrarExtintor> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _composicaoController = TextEditingController();
  final TextEditingController _linhaController = TextEditingController();
  final TextEditingController _localizacaoController = TextEditingController();
  final TextEditingController _observacaoController = TextEditingController();
  final TextEditingController _dataRegistroController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        title: const Text('Registrar Extintor'),
        backgroundColor: const Color(0xFF004AAD),
        centerTitle: true,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context)
                    .openEndDrawer(); 
              },
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF004AAD),
              ),
              child: Text(
                'Menu de Navegação',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Tela Principal'),
              onTap: () {
                // Navegação para Tela Principal
              },
            ),
            ListTile(
              leading: const Icon(Icons.build),
              title: const Text('Manutenção'),
              onTap: () {
                // Navegação para Manutenção
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Localização'),
              onTap: () {
                // Navegação para Localização
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Consultar Extintor'),
              onTap: () {
                // Navegação para Consulta de Extintores
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurações'),
              onTap: () {
                // Navegação para Configurações
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Preencha os dados do extintor",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF004AAD),
                  ),
                ),
                const SizedBox(height: 20),
                _buildInputCard(
                  controller: _numeroController,
                  label: 'Número do Extintor',
                  icon: Icons.confirmation_number,
                ),
                const SizedBox(height: 20),
                _buildInputCard(
                  controller: _composicaoController,
                  label: 'Composição',
                  icon: Icons.science,
                ),
                const SizedBox(height: 20),
                _buildInputCard(
                  controller: _linhaController,
                  label: 'Linha',
                  icon: Icons.train,
                ),
                const SizedBox(height: 20),
                _buildInputCard(
                  controller: _localizacaoController,
                  label: 'Localização',
                  icon: Icons.location_on,
                ),
                const SizedBox(height: 20),
                _buildInputCard(
                  controller: _observacaoController,
                  label: 'Observação',
                  icon: Icons.note_alt,
                  isOptional: true,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _dataRegistroController.text =
                            '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: _buildInputCard(
                      controller: _dataRegistroController,
                      label: 'Data do Registro',
                      icon: Icons.calendar_today,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Extintor registrado com sucesso!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004AAD),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Confirmar Registro',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isOptional = false,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF004AAD), size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: label,
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (!isOptional && (value == null || value.isEmpty)) {
                    return 'Por favor, insira $label';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
