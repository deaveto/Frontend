import 'package:app_movil/constantes.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

String? accessToken;

class Usuario_Login {
  final TextEditingController usuarioController;
  final TextEditingController claveController;

  Usuario_Login(
    {
    required this.usuarioController,
    required this.claveController,
    }
  );
  Future<void> loginUsuario(BuildContext context) async {
    final url = Uri.parse('$url_api/api/token/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': usuarioController.text,
        'password': claveController.text,
      }),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      accessToken = data['access'];
      // Aquí puedes guardar el token si deseas
      print('Token: $accessToken');
      // Navegar a la página de inicio
      Navigator.pushReplacementNamed(context, 'home');
    } else {
      // Error: usuario o contraseña incorrecta
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('Usuario o contraseña incorrecta'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
        ),
      );
    }
  }
}

class UsuarioProvider with ChangeNotifier {
  String _rutaActiva = ""; // Variable para almacenar la respuesta de la API.
  String get rutaActiva => _rutaActiva;
  // Función para verificar si el token ha expirado
  // ignore: unused_element
  bool _isTokenExpired(String token) {
    final decodedToken = JwtDecoder.decode(token); // Si usas jwt_decoder (deberás agregarlo en pubspec.yaml)
    final expirationDate = DateTime.fromMillisecondsSinceEpoch(decodedToken['exp'] * 1000);
    // Compara la fecha de expiración con la fecha actual
    print('tiempo de expiración de la API:');
    print(expirationDate);
    return expirationDate.isBefore(DateTime.now());
  }
  
  Future<void> RutaUsuario(BuildContext context) async {    
    final url = Uri.parse('$url_api/api/ruta-activa/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = response.body;
      _rutaActiva = data.toString(); // Almacena la respuesta en la variable.
      notifyListeners(); // Notifica a los listeners para que se actualice la UI.
    } else {
      _rutaActiva = 'Error: ${response.statusCode}'; // En caso de error, muestra el código de error.
      notifyListeners();
      print('Error: ${response.statusCode}');
      print('Respuesta: ${response.body}');
      Navigator.pushReplacementNamed(context, 'login');
    }
  }
}