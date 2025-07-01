import 'dart:convert';

import 'package:app_movil/provider/login.provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import '../constantes.dart';

class ProfileDatos with ChangeNotifier {
  String _rutasSinAsignar = "";
  String get DatoPersonal => _rutasSinAsignar;  

  //API datos del usuario
  // ignore: non_constant_identifier_names
  Future<void> ProfileDatosPersonales(BuildContext context, ) async {
    notifyListeners(); 
    final accessToken = Provider.of<AuthProvider>(context, listen: false).accessToken;   
    if (accessToken == null || JwtDecoder.isExpired(accessToken)) {
      _rutasSinAsignar = 'Token vencido';
      notifyListeners();
      Navigator.pushReplacementNamed(context, 'login');
      return;
    }
    final url = Uri.parse('$url_api/api/usuario/');
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

  // API actualizar datos personales del usuario
  Future<void> actualizarDatosUsuario(BuildContext context, Map<String, dynamic> data) async {
    final accessToken = Provider.of<AuthProvider>(context, listen: false).accessToken;   
    if (accessToken == null || JwtDecoder.isExpired(accessToken)) {
      Navigator.pushReplacementNamed(context, 'login');
      return;
    }
    final url = Uri.parse('$url_api/api/actualizar-usuario/');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Perfil actualizado exitosamente")),
      );
      // Puedes volver a cargar los datos si quieres
      await ProfileDatosPersonales(context);
    } else {
      // Error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al actualizar perfil: ${response.body}")),
      );
    }
  }

    // API actualizar horarios del usuario
  Future<void> actualizarHorarios(BuildContext context, List<Map<String, String>> horariosData) async {
    final accessToken = Provider.of<AuthProvider>(context, listen: false).accessToken;
    
    if (accessToken == null || JwtDecoder.isExpired(accessToken)) {
      Navigator.pushReplacementNamed(context, 'login');
      return;
    }

    final url = Uri.parse('$url_api/api/actualizar-horarios/');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({'horarios': horariosData}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Horarios actualizados correctamente")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al actualizar horarios: ${response.body}")),
      );
    }
  }

  Future<void> cambiarPassword(
    BuildContext context, {
    required String claveActual,
    required String nuevaClave,
    required String confirmacion,
  }) async {
    final accessToken = Provider.of<AuthProvider>(context, listen: false).accessToken;

    if (accessToken == null || JwtDecoder.isExpired(accessToken)) {
      Navigator.pushReplacementNamed(context, 'login');
      return;
    }

    final url = Uri.parse('$url_api/api/cambiar-password/');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'clave_actual': claveActual,
        'nueva_clave': nuevaClave,
        'confirmacion': confirmacion,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contraseña actualizada exitosamente")),
      );

      // Limpiar el token y redirigir al login
      Provider.of<AuthProvider>(context, listen: false).clearToken();
      Navigator.pushReplacementNamed(context, 'login');
    } else {
      final Map<String, dynamic> errorBody = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${errorBody['error'] ?? 'Ocurrió un error'}")),
      );
    }
  }

}
