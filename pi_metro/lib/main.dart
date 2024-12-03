// import 'dart:io' show Platform;
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:pi_metro/screens/Tela_Principal/notificacao.dart';
// import 'package:pi_metro/screens/Telas_Usuarios/cadastro.dart';
// import 'package:pi_metro/screens/Telas_Usuarios/forgot_password_screen.dart';
// import 'package:pi_metro/screens/Telas_Usuarios/hub.dart';
// import 'package:pi_metro/screens/Telas_Usuarios/login.dart';
// import 'package:pi_metro/screens/Telas_Usuarios/reset_password_screen.dart';
// import 'package:provider/provider.dart';
// import 'package:uni_links/uni_links.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:async';
// import 'screens/Tela_Principal/welcome_dashboard.dart';
// import 'screens/Telas_Relatorios/linha_opcoes.dart'; // Nova tela de opções para a linha
// import 'screens/Telas_Relatorios/relatorios_screen.dart';
// import 'screens/Telas_Relatorios/manutencao_preventiva_screen.dart';
// import 'screens/Telas_Relatorios/localizacao_extintores_screen.dart';
// import 'screens/Telas_Relatorios/vencimento_extintores_screen.dart';
// import 'screens/Telas_Relatorios/status_screen.dart';
// import 'services/user_provider.dart';

// class MyCustomPageRoute<T> extends MaterialPageRoute<T> {
//   MyCustomPageRoute({required WidgetBuilder builder, RouteSettings? settings})
//       : super(builder: builder, settings: settings);

//   @override
//   Widget buildTransitions(
//       BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
//     if (settings.name == '/') {
//       return child; // Não anima a tela inicial
//     }
//     return FadeTransition(opacity: animation, child: child);
//   }
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final prefs = await SharedPreferences.getInstance();
//   final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => UserProvider()),
//       ],
//       child: MyApp(isLoggedIn: isLoggedIn),
//     ),
//   );
// }

// class MyApp extends StatefulWidget {
//   final bool isLoggedIn;

//   const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   StreamSubscription? _sub;

//   @override
//   void initState() {
//     super.initState();
//     if (kIsWeb) {
//       _checkWebQueryParameters();
//     } else if (Platform.isAndroid || Platform.isIOS) {
//       _initUniLinks();
//     }
//   }

//   void _checkWebQueryParameters() {
//     final uri = Uri.base;
//     final token = uri.queryParameters['token'];
//     if (token != null) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ResetPasswordScreen(token: token),
//         ),
//       );
//     }
//   }

//   Future<void> _initUniLinks() async {
//     try {
//       _sub = linkStream.listen((String? link) {
//         if (link != null) {
//           final uri = Uri.parse(link);
//           if (uri.pathSegments.contains('reset-password')) {
//             final token = uri.queryParameters['token'] ?? '';
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => ResetPasswordScreen(token: token),
//               ),
//             );
//           }
//         }
//       }, onError: (err) {
//         print('Erro ao processar link: $err');
//       });
//     } catch (e) {
//       print('Erro ao inicializar UniLinks: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _sub?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Gestão de Equipamentos',
//       theme: ThemeData(
//         primaryColor: const Color(0xFF001489),
//       ),
//       initialRoute: widget.isLoggedIn ? '/welcome-dashboard' : '/login',
//       onGenerateRoute: (settings) {
//         switch (settings.name) {
//           case '/':
//             return MyCustomPageRoute(builder: (_) => const HubPage());
//           case '/login':
//             return MyCustomPageRoute(builder: (_) => const LoginPage());
//           case '/cadastro':
//             return MyCustomPageRoute(builder: (_) => const CadastroPage());
//           case '/forgot-password':
//             return MyCustomPageRoute(builder: (_) => ForgotPasswordScreen());
//           case '/reset-password':
//             return MyCustomPageRoute(builder: (_) => ResetPasswordScreenHandler());
//           case '/welcome-dashboard':
//             return MyCustomPageRoute(
//               builder: (_) => WelcomeDashboard(
//                 nomeUsuario: Provider.of<UserProvider>(context, listen: false).userName ?? 'Usuário',
//                 cargoUsuario: 'Administrador',
//               ),
//             );
//           case '/linha-opcoes':
//             final args = settings.arguments as Map<String, String>;
//             final linha = args['linha'] ?? 'Linha Não Definida';
//             return MyCustomPageRoute(
//               builder: (_) => LinhaOpcoesScreen(linhaSelecionada: linha),
//             );
//           case '/relatorios':
//             return MyCustomPageRoute(builder: (_) => const RelatoriosScreen());
//           case '/manutencao-preventiva':
//             return MyCustomPageRoute(builder: (_) => ManutencaoPreventivaScreen());
//           case '/localizacao-extintores':
//             return MyCustomPageRoute(builder: (_) => ExtintoresPorLocalizacaoScreen());
//           case '/vencimento-extintores':
//             return MyCustomPageRoute(builder: (_) => VencimentoExtintoresScreen());
//           case '/status':
//             return MyCustomPageRoute(builder: (_) => StatusScreen());
//           case '/notificacoes':
//             return MyCustomPageRoute(
//               builder: (_) => NotificacoesPage(userId: Provider.of<UserProvider>(context, listen: false).userId),
//             );

//           default:
//             return null;
//         }
//       },
//     );
//   }
// }

// class ResetPasswordScreenHandler extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final uri = Uri.base;
//     final token = uri.queryParameters['token'];
//     if (token != null) {
//       return ResetPasswordScreen(token: token);
//     } else {
//       return Scaffold(
//         body: Center(
//           child: Text(
//             'Token inválido ou ausente.',
//             style: TextStyle(fontSize: 18, color: Colors.red),
//           ),
//         ),
//       );
//     }
//   }
// }


import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pi_metro/screens/Dashboard.dart';
import 'package:pi_metro/screens/Telas_Usuarios/cadastro.dart';
import 'package:pi_metro/screens/Telas_Usuarios/forgot_password_screen.dart';
import 'package:pi_metro/screens/Telas_Usuarios/login.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi_metro/services/user_provider.dart';

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

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestão de Equipamentos',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: isLoggedIn ? '/welcome-dashboard' : '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/cadastro': (_) => const CadastroPage(),
        '/welcome-dashboard': (_) => const Dashboard(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
      },
    );
  }
}
