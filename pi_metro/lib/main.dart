import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'screens/hub.dart';
import 'screens/login.dart';
import 'screens/cadastro.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/welcome_dashboard.dart';
import 'screens/linha_opcoes.dart'; // Nova tela de opções para a linha
import 'screens/extintores_por_localizacao_screen.dart'; // Nova tela para o gráfico
import 'screens/relatorios_screen.dart';
import 'screens/manutencao_preventiva_screen.dart';
import 'screens/localizacao_extintores_screen.dart';
import 'screens/vencimento_extintores_screen.dart';
import 'screens/status_screen.dart';
import 'services/user_provider.dart';

class MyCustomPageRoute<T> extends MaterialPageRoute<T> {
  MyCustomPageRoute({required WidgetBuilder builder, RouteSettings? settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(
      BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    if (settings.name == '/') {
      return child; // Não anima a tela inicial
    }
    return FadeTransition(opacity: animation, child: child);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
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
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MyCustomPageRoute(builder: (_) => const HubPage());
          case '/login':
            return MyCustomPageRoute(builder: (_) => const LoginPage());
          case '/cadastro':
            return MyCustomPageRoute(builder: (_) => const CadastroPage());
          case '/forgot-password':
            return MyCustomPageRoute(builder: (_) => ForgotPasswordScreen());
          case '/reset-password':
            return MyCustomPageRoute(builder: (_) => ResetPasswordScreenHandler());
          case '/welcome-dashboard':
            return MyCustomPageRoute(
              builder: (_) => WelcomeDashboard(
                nomeUsuario: Provider.of<UserProvider>(context, listen: false).userName ?? 'Usuário',
                cargoUsuario: 'Administrador',
              ),
            );
          case '/linha-opcoes':
            final args = settings.arguments as Map<String, String>;
            final linha = args['linha'] ?? 'Linha Não Definida';
            return MyCustomPageRoute(
              builder: (_) => LinhaOpcoesScreen(linhaSelecionada: linha),
            );
          case '/relatorios':
            return MyCustomPageRoute(builder: (_) => const RelatoriosScreen());
          case '/manutencao-preventiva':
            return MyCustomPageRoute(builder: (_) => ManutencaoPreventivaScreen());
          case '/localizacao-extintores':
            return MyCustomPageRoute(builder: (_) => LocalizacaoExtintoresScreen());
          case '/vencimento-extintores':
            return MyCustomPageRoute(builder: (_) => VencimentoExtintoresScreen());
          case '/status':
            return MyCustomPageRoute(builder: (_) => StatusScreen());
          default:
            return null;
        }
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
