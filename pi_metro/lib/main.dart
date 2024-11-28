import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'screens/hub.dart';
import 'screens/login.dart';
import 'screens/cadastro.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/welcome_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _checkWebQueryParameters();
    } else if (Platform.isAndroid || Platform.isIOS) {
      _initUniLinks();
    }
  }

  void _checkWebQueryParameters() {
    final uri = Uri.base;
    final token = uri.queryParameters['token'];
    if (token != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(token: token),
        ),
      );
    }
  }

  Future<void> _initUniLinks() async {
    try {
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
    } catch (e) {
      print('Erro ao inicializar UniLinks: $e');
    }
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
      initialRoute: widget.isLoggedIn ? '/welcome-dashboard' : '/login',
      routes: {
        '/': (context) => const HubPage(),
        '/login': (context) => const LoginPage(),
        '/cadastro': (context) => const CadastroPage(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
        '/reset-password': (context) => ResetPasswordScreenHandler(),
        '/welcome-dashboard': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map?;
          return WelcomeDashboard(
            nomeUsuario: args?['nomeUsuario'] ?? 'Usuário',
            cargoUsuario: 'Bem-vindo',
          );
        },
      },
    );
  }
}

class ResetPasswordScreenHandler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uri = Uri.base;
    final token = uri.queryParameters['token'];
    if (token != null) {
      return ResetPasswordScreen(token: token);
    } else {
      return Scaffold(
        body: Center(
          child: Text(
            'Token inválido ou ausente.',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }
  }
}
