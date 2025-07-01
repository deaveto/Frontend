import 'package:app_movil/pages/SplashScreen.dart';
import 'package:app_movil/pages/home.page.dart';
import 'package:app_movil/provider/datos.personales.provider.dart';
import 'package:app_movil/provider/login.provider.dart';
import 'package:app_movil/provider/rutas_disponibles.provider.dart';
import 'package:app_movil/provider/usuario.provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/login.page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UsuarioProvider()),
        ChangeNotifierProvider(create: (_) => RutasDisponiblesProvider()),
        ChangeNotifierProvider(create: (_) => ProfileDatos()),
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
        'splash': (_) => SplashScreen(),
        'login': (_) => Login(),
        'home': (_) => const Home_Page(),
      },
      initialRoute: 'splash',
    );
  }
}