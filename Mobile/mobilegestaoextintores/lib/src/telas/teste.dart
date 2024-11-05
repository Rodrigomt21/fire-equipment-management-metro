import 'package:flutter/material.dart';

final Color darkBlue = Color.fromARGB(255, 18, 32, 47);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: darkBlue),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                  child: Column(
                children: <Widget>[
                  Container(height: 100, color: Colors.red),
                  Container(height: 500, color: Colors.yellow),
                  Container(height: 200, color: Colors.green),
                ],
              )),
            ),
            Container(
                height: 100,
                color: Colors.orange,
                child: Center(child: Text("Propagandas chatas do caramba!")))
          ],
        ),
      ),
    );
  }
}
