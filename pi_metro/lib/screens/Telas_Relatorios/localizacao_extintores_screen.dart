import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pi_metro/services/notification_service.dart';

class ExtintoresPorLocalizacaoScreen extends StatefulWidget {
  @override
  _ExtintoresPorLocalizacaoScreenState createState() =>
      _ExtintoresPorLocalizacaoScreenState();
}

class _ExtintoresPorLocalizacaoScreenState
    extends State<ExtintoresPorLocalizacaoScreen> {
  List<Map<String, dynamic>> notifications = [];

  @override
void initState() {
  super.initState();
  _fetchNotifications();
}

Future<void> _fetchNotifications() async {
  try {
    final fetchedNotifications = await NotificationService.fetchNotifications();
    setState(() {
      notifications = List<Map<String, dynamic>>.from(fetchedNotifications);
    });
  } catch (error) {
    print('Erro ao buscar notificações: $error');
  }
}

Future<void> _markNotificationAsRead(int notificationId) async {
  try {
    await NotificationService.markAsRead(notificationId);
    // Atualize a interface ou o estado após marcar como lida
  } catch (error) {
    // Trate o erro adequadamente
    print('Erro ao marcar notificação como lida: $error');
  }
}


  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        if (notifications.isEmpty) {
          return Center(child: Text('Nenhuma notificação no momento.'));
        } else {
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                title: Text(notification['mensagem']),
                subtitle: Text(notification['data_criacao']),
                trailing: IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () async {
                    await NotificationService.markAsRead(notification['id']);
                    setState(() {
                      notifications.removeAt(index);
                    });
                  },
                ),
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF001489),
        title: Text(
          "Extintores por Localização",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: _showNotifications,
              ),
              if (notifications.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      notifications.length.toString(),
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Gráfico de Extintores por Localização",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF001489),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                height: 300,
                width: double.infinity,
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: Text(
                  "Aqui será exibido o gráfico",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF001489),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Voltar",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
