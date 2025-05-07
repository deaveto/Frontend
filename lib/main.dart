import 'package:app_movil/pages/home.page.dart';
import 'package:app_movil/pages/prueba.page.dart';
import 'package:app_movil/provider/usuario.provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/login.page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UsuarioProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Driver',
      routes: {
        'login': (_) => Login(),
        'home': (_) => const Home_Page(),
        'prueba': (_) => const pruebas(),
      },
      initialRoute: 'login',
    );
  }
}