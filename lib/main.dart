import 'package:flutter/material.dart';
import 'pages/login.page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Driver',
      routes: {
        'login' : (_) => Login(),
      },
      initialRoute: 'login',
    );
  }
}