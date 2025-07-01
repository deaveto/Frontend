//import 'dart:convert';
import 'dart:convert';

import 'package:app_movil/provider/login.provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import '../constantes.dart';

class RutasDisponiblesProvider with ChangeNotifier {
  String _rutasSinAsignar = "";
  String get rutasSinAsignar => _rutasSinAsignar;

  Future<void> cargarRutasSinAsignar(BuildContext context) async {
    notifyListeners();
    final accessToken = Provider.of<AuthProvider>(context, listen: false).accessToken;
    if (accessToken == null || JwtDecoder.isExpired(accessToken)) {
      _rutasSinAsignar = 'Token vencido';
      notifyListeners();
      Navigator.pushReplacementNamed(context, 'login');
      return;
    }
    DateTime now = new DateTime.now();
    String soloFecha = now.toIso8601String().split('T').first;
    final url = Uri.parse('$url_api/api/rutas-sin-asignacion/?fecha=$soloFecha');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      _rutasSinAsignar = response.body;
    } else {
      _rutasSinAsignar = 'Error: ${response.statusCode}';
      Navigator.pushReplacementNamed(context, 'login');
    }
    notifyListeners();
  }

  Future<void> actualizarRutaSinAsignar(int cod, BuildContext context) async{
    DateTime now = new DateTime.now();
    String Fecha = now.toIso8601String().split('T').first;
    final accessToken = Provider.of<AuthProvider>(context, listen: false).accessToken;
    if(accessToken == null || JwtDecoder.isExpired(accessToken!)){
      _rutasSinAsignar = 'Token vencido. Redirigiendo al login...';
      notifyListeners();
      Navigator.pushReplacementNamed(context, 'login');
      return;
    }
    final url= Uri.parse('$url_api/api/ruta-asignar-ruta-driver/');    
    final response = await http.post(
      url,
      headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode({
      "ruta_id": cod,
      "fecha": Fecha,
    }),
    );
    if (response.statusCode == 200) {
      print('Ruta actualizada exitosamente');
      // Opcional: volver a cargar las rutas activas si quieres actualizar la vista
      await cargarRutasSinAsignar(context);
      final responseJson = jsonDecode(response.body);
      final mensajeError = responseJson['detail'];
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) {
          // Guardamos el contexto del diálogo
          Future.delayed(Duration(seconds: 3), () {
            if (Navigator.of(ctx).canPop()) {
              Navigator.of(ctx).pop(); // Cierra el diálogo si aún se puede
              cargarRutasSinAsignar(context); // Llama la función
            }
          });
          return AlertDialog(
            title: Text('Alerta'),
            content: Text(mensajeError),
          );
        },
      );
    } else {
      print('Error al actualizar ruta: ${response.statusCode}');
      print('Detalle: ${response.body}');
      final responseJson = jsonDecode(response.body);
      final mensajeError = responseJson['detail'];
      await cargarRutasSinAsignar(context);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Alerta'),
          content: Text(mensajeError),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
        ),
      );
    }
  }



}
