import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class TelaConta extends StatefulWidget {
  const TelaConta({super.key});

  @override
  _TelaContaState createState() => _TelaContaState();
}

class _TelaContaState extends State<TelaConta> {
  PickedFile? _imagemSelecionada;

  Future<void> _trocarFotoPerfil() async {
    final picker = ImagePicker();
    final imagem = await picker.getImage(source: ImageSource.gallery);
    if (imagem != null) {
      setState(() {
        _imagemSelecionada = imagem;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Conta'),
        backgroundColor: const Color(0xFF004AAD), 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _trocarFotoPerfil, 
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: CircleAvatar(
                      key: ValueKey<String>(_imagemSelecionada?.path ?? 'default'),
                      radius: 60,
                      backgroundImage: _imagemSelecionada != null
                          ? FileImage(File(_imagemSelecionada!.path))
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
              onPressed: _trocarFotoPerfil,
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
            _buildInfoTile(Icons.person, 'Nome', 'Lucas Silva'),
            _buildInfoTile(Icons.work, 'Cargo', 'Gestor de Extintor'),
            _buildInfoTile(Icons.badge, 'Matrícula', '123456'),
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
