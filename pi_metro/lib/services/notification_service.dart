import 'package:http/http.dart' as http;

class NotificationService {
  static const String baseUrl = 'http://localhost:3000';

  static Future<void> markAsRead(int notificationId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notificacoes/$notificationId/markAsRead'),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao marcar notificação como lida');
    }
  }

  static Future<void> markAsUnread(int notificationId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notificacoes/$notificationId/markAsUnread'),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao marcar notificação como não lida');
    }
  }

  static fetchNotifications() {}
}
