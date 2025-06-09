import 'package:app_movil/constantes.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
    //final url = Uri.parse('http://10.0.2.2:8000/api/token/');
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
    final decodedToken = JwtDecoder.decode(token);
    final expirationDate = DateTime.fromMillisecondsSinceEpoch(decodedToken['exp'] * 1000);
    return expirationDate.isBefore(DateTime.now());
  }
  
  // Funcion para traer todas las rutas de la fecha actual de un usuario a consultar
  Future<void> RutaUsuarioActivas(BuildContext context) async {    
    DateTime now = new DateTime.now();
    String soloFecha = now.toIso8601String().split('T').first;
    print(soloFecha);
    final url = Uri.parse('$url_api/api/ruta-activa-por-fecha/?fecha=$soloFecha');
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

  Future<void> obtenerSemanaActual(BuildContext context) async {
    DateTime hoy = DateTime.now();    
    // Ajustamos para que el lunes sea el primer día (en DateTime, lunes es 1, domingo es 7)
    int diferenciaLunes = hoy.weekday - DateTime.monday;
    int diferenciaDomingo = DateTime.sunday - hoy.weekday;
    DateTime lunes = hoy.subtract(Duration(days: diferenciaLunes));
    DateTime domingo = hoy.add(Duration(days: diferenciaDomingo));
    // Formato dd-MM-yyyy
    String formato = 'yyyy-MM-dd';
    String lunesFormateado = DateFormat(formato).format(lunes);
    String domingoFormateado = DateFormat(formato).format(domingo);

    final url = Uri.parse('$url_api/api/rutas-rango/?fecha_inicio=$lunesFormateado&fecha_fin=$domingoFormateado');
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
    // Funcion para traer todas las rutas por fecha de un usuario a consultar
  // ignore: non_constant_identifier_names
  Future<void> RutaUsuarioFecha(fecha, BuildContext context) async {    
    //DateTime now = new DateTime.now();
    String soloFecha = fecha;
    //print(soloFecha);
    final url = Uri.parse('$url_api/api/ruta-por-fecha/?fecha=$soloFecha');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      print(soloFecha);
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

  // función que actualiza el estado de una ruta 
  Future<void> actualizarEstadoRuta(int RutaId, String NuevoEstado, BuildContext context) async{
    if(accessToken == null || JwtDecoder.isExpired(accessToken!)){
      _rutaActiva = 'Token vencido. Redirigiendo al login...';
      notifyListeners();
      Navigator.pushReplacementNamed(context, 'login');
      return;
    }
    final url= Uri.parse('$url_api/api/ruta-actualizar/$RutaId/');
    final response = await http.patch(
      url,
      headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'estado_ruta': NuevoEstado,
    }),
    );
    if (response.statusCode == 200) {
      print('Ruta actualizada exitosamente');
      // Opcional: volver a cargar las rutas activas si quieres actualizar la vista
      await RutaUsuarioActivas(context);
    } else {
      print('Error al actualizar ruta: ${response.statusCode}');
      print('Detalle: ${response.body}');
    }
  }

  // Funcion para actualizar las notas de una ruta
  Future<void> actualizarNotasRuta(int RutaId, String NuevasNotas, BuildContext context) async{
    if(accessToken == null || JwtDecoder.isExpired(accessToken!)){
      _rutaActiva = 'Token vencido. Redirigiendo al login...';
      notifyListeners();
      Navigator.pushReplacementNamed(context, 'login');
      return;
    }
    final url= Uri.parse('$url_api/api/notas/$RutaId/');
    final response = await http.patch(
      url,
      headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'notas': NuevasNotas,
    }),
    );
    if (response.statusCode == 200) {
      print('Ruta actualizada exitosamente');
      // Opcional: volver a cargar las rutas activas si quieres actualizar la vista
      await RutaUsuarioActivas(context);
    } else {
      print('Error al actualizar ruta: ${response.statusCode}');
      print('Detalle: ${response.body}');
    }
  } 

}

