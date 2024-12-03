import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TelaConta extends StatefulWidget {
  const TelaConta({super.key});

  @override
  _TelaContaState createState() => _TelaContaState();
}

class _TelaContaState extends State<TelaConta> {
  XFile? _imagemSelecionada; // Para armazenar a imagem selecionada
  String nome = 'Carregando...';
  String matricula = 'Carregando...';
  String cargo = 'Carregando...';
  int usuarioId = 0;

  @override
  void initState() {
    super.initState();
    _buscarUsuario();
  }

  Future<void> _buscarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('usuario_email');

    if (email == null) {
      setState(() {
        nome = 'Erro ao carregar';
        matricula = 'Erro ao carregar';
        cargo = 'Erro ao carregar';
        _imagemSelecionada = null; // Adicionado
      });
      return;
    }

    try {
      final response = await http
          .get(Uri.parse('http://localhost:3001/usuario?email=$email'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Dados do usuário: $data'); // Log para depuração

        setState(() {
          nome = data['nome'] ?? 'Nome não encontrado';
          matricula = data['matricula'] ?? 'Matrícula não encontrada';
          cargo = data['cargo'] ?? 'Cargo não encontrado';
          usuarioId = data['id'] ?? 0; // Atribui 0 caso o id seja nulo
          // Carregar a imagem do perfil
          if (data['foto_perfil'] != null) {
            _imagemSelecionada =
                XFile(data['foto_perfil']); // Se for um caminho local
          } else {
            _imagemSelecionada = null; // Se não houver imagem, defina como nulo
          }
        });
      } else {
        final errorMessage =
            jsonDecode(response.body)['message'] ?? 'Erro desconhecido';
        setState(() {
          nome = 'Erro ao carregar: $errorMessage';
          matricula = 'Erro ao carregar: $errorMessage';
          cargo = 'Erro ao carregar: $errorMessage';
          _imagemSelecionada = null; // Se houver erro, defina como nulo
        });
      }
    } catch (e) {
      setState(() {
        nome = 'Erro ao carregar';
        matricula = 'Erro ao carregar';
        cargo = 'Erro ao carregar';
        _imagemSelecionada = null; // Se houver erro, defina como nulo
      });
      print('Erro ao buscar usuário: $e'); // Log para depuração
    }
  }

  // Método para selecionar e enviar a imagem
  Future<void> _uploadImagem(int usuarioId) async {
    final picker = ImagePicker();
    final XFile? imagem = await picker.pickImage(source: ImageSource.gallery);

    if (imagem != null) {
      final bytes = await imagem.readAsBytes();

      var uri = Uri.parse('http://localhost:3001/upload');
      var request = http.MultipartRequest('POST', uri);

      // Enviando a imagem
      request.files.add(http.MultipartFile.fromBytes(
        'image', // O nome do campo para a imagem
        bytes,
        filename: imagem.name,
      ));

      // Enviando o ID do usuário
      request.fields['usuario_id'] = usuarioId.toString();

      // Enviar a requisição para o servidor
      var response = await request.send();

      if (response.statusCode == 200) {
        print('Imagem salva com sucesso!');
        setState(() {
          _imagemSelecionada = imagem; // Atualiza a imagem local
        });
        // Recarregar os dados do usuário para garantir que a imagem mais recente seja exibida
        await _buscarUsuario();
      } else {
        print('Falha ao salvar a imagem. Status: ${response.statusCode}');
        final responseBody = await response.stream
            .bytesToString(); // Captura o corpo da resposta
        print('Resposta do servidor: $responseBody'); // Log para depuração
      }
    }
  }

  // Método para trocar a foto de perfil
  Future<void> _trocarFotoPerfil() async {
    await _uploadImagem(usuarioId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Minha Conta',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFFD9D9D9))),
        backgroundColor: const Color(0xFF011689),
        centerTitle: true,
        elevation: 4,
        iconTheme: const IconThemeData(color: Color(0xFFD9D9D9)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _trocarFotoPerfil, // Chama o método para trocar a foto
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: CircleAvatar(
    key: ValueKey<String>(_imagemSelecionada?.path ?? 'default'),
    radius: 60,
    backgroundImage: _imagemSelecionada != null
        ? NetworkImage(_imagemSelecionada!.path) // Usar NetworkImage para URLs
        : const AssetImage('assets/images/default_profile.png') as ImageProvider,
),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 18,
                    child: Icon(Icons.camera_alt, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _trocarFotoPerfil, // Chama o método implementado
              child: const Text(
                'Trocar Foto de Perfil',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF004AAD),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildInfoTile(Icons.person, 'Nome', nome),
            _buildInfoTile(Icons.work, 'Cargo', cargo),
            _buildInfoTile(Icons.badge, 'Matrícula', matricula),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String info) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF004AAD), size: 28),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                info,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
