// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class RelatoriosScreen extends StatefulWidget {
//   const RelatoriosScreen({Key? key}) : super(key: key);

//   @override
//   _RelatoriosScreenState createState() => _RelatoriosScreenState();
// }

// class _RelatoriosScreenState extends State<RelatoriosScreen> {
//   late WebViewController _webViewController;

//   final String powerBiUrl =
//       'https://app.powerbi.com/view?r=eyJrIjoiMTU2MmI3ZmQtODA1Mi00ODg5LWJiNWMtZTljMzRhZjRjZTgwIiwidCI6ImM0OWUxOTM5LTRiNTMtNDczOC1iYjY0LTQxZmIyOTkwZTQxYyJ9'; // Substitua pelo link do seu relatório Power BI

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Relatórios'),
//         backgroundColor: const Color(0xFF001489),
//       ),
//       body: Column(
//         children: [
//           const Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Text(
//               'Relatórios Analíticos',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF001489),
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//           Expanded(
//             child: WebView(
//               initialUrl: powerBiUrl,
//               javascriptMode: JavascriptMode.unrestricted,
//               onWebViewCreated: (controller) {
//                 _webViewController = controller;
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RelatoriosScreen extends StatelessWidget {
  final String reportUrl =
      'https://app.powerbi.com/view?r=eyJrIjoiMTU2MmI3ZmQtODA1Mi00ODg5LWJiNWMtZTljMzRhZjRjZTgwIiwidCI6ImM0OWUxOTM5LTRiNTMtNDczOC1iYjY0LTQxZmIyOTkwZTQxYyJ9';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Relatório Power BI'),
      ),
      body: WebView(
        initialUrl: reportUrl,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
