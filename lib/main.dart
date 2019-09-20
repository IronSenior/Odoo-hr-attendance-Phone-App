import 'package:flutter/material.dart';


import 'ui/screens/index.dart';

Future main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Odoo Attendance',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Odoo Attendance'),
    );
  }
}
