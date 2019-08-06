import 'package:flutter/material.dart';
import 'primaryPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KVIS Science Fair',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: PrimaryHomepage(),
    );
  }
}
