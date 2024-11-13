import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';
import 'screens/hub.dart';
import 'screens/login.dart';
import 'screens/cadastro.dart';
import 'screens/welcome.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _initUniLinks();
  }

  Future<void> _initUniLinks() async {
    _sub = linkStream.listen((String? link) {
      if (link != null) {
        final uri = Uri.parse(link);
        if (uri.pathSegments.contains('reset-password')) {
          final token = uri.queryParameters['token'] ?? '';
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(token: token),
            ),
          );
        }
      }
    }, onError: (err) {
      print('Erro ao processar link: $err');
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestão de Equipamentos',
      theme: ThemeData(
        primaryColor: const Color(0xFF001489),
      ),
      initialRoute: '/login',
      routes: {
        '/': (context) => const HubPage(),
        '/login': (context) => const LoginPage(),
        '/cadastro': (context) => const CadastroPage(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
        '/reset-password': (context) => ResetPasswordScreen(token: ''),
        '/welcome': (context) => const WelcomePage(),
      },
    );
  }
}
