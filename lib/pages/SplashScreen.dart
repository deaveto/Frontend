import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, 'login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.white, // o el color de fondo que prefieras
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', height: 240),
            SizedBox(height: 20),
            Image.asset('assets/images/loading2.gif', height: 120, gaplessPlayback: true),
            
              //gaplessPlayback: true, // importante para evitar que se congele
           
          ],
        ),
      ),
    );
  }
}
