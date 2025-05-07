import 'dart:convert';
import 'package:app_movil/provider/usuario.provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

class Three_Tap extends StatefulWidget {
  const Three_Tap({super.key});
  @override
  State<Three_Tap> createState() => _Three_TapState();
}

class _Three_TapState extends State<Three_Tap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<UsuarioProvider>(context, listen: false).RutaUsuario(context);      
    });
  }
  Widget build(BuildContext context) {
    //return const Placeholder();
    final data = Provider.of<UsuarioProvider>(context).rutaActiva;

    try{
      List<dynamic> listaDatos = json.decode(data);
        return Scaffold(
          body: Center(child: Text('data')),      
       );
    }catch(e){return Center(child: Text(data));}














  }
}

