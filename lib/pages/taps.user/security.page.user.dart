
import 'package:app_movil/provider/datos.personales.provider.dart';
import 'package:app_movil/provider/login.provider.dart';
import 'package:app_movil/provider/usuario.provider.dart';
import 'package:flutter/material.dart';
import 'package:app_movil/widgets/Campo_Contraseña.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';

class security extends StatefulWidget {
  const security({super.key});

  @override
  State<security> createState() => _securityState();
}

class _securityState extends State<security> {
  final TextEditingController claveActualController = TextEditingController();
  final TextEditingController nuevaClaveController = TextEditingController();
  final TextEditingController confirmacionController = TextEditingController();
  
  get child => null;

  @override
  Widget build(BuildContext context) {
    final token = Provider.of<AuthProvider>(context, listen: false).accessToken;
    // Verificar si el contenido está vacío o inválido antes de hacer decode
      if (token == null || JwtDecoder.isExpired(token)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, 'login');
        });
      }
    try{
      return Scaffold(
        appBar: AppBar(
          title: const Text('password', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green[700],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [              
              Text('Current password', style: TextStyle(fontSize: 18)),
              CampoContrasena(controller: claveActualController),
              SizedBox(height: 60),
              Text('New password', style: TextStyle(fontSize: 18)),
              CampoContrasena(controller: nuevaClaveController),
              SizedBox(height: 60),
              Text('Confirm new password', style: TextStyle(fontSize: 18)),
              CampoContrasena(controller: confirmacionController),
              const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              final claveActual = claveActualController.text.trim();
              final nuevaClave = nuevaClaveController.text.trim();
              final confirmacion = confirmacionController.text.trim();

              // Validación básica
              if (claveActual.isEmpty || nuevaClave.isEmpty || confirmacion.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("All fields are required")),
                );
                return;
              }

              // Llamar al provider para cambiar la clave
              await Provider.of<ProfileDatos>(context, listen: false).cambiarPassword(
                context,
                claveActual: claveActual,
                nuevaClave: nuevaClave,
                confirmacion: confirmacion,
              );
            },
            child: const Text('Update password'),
          ),
            ],
          ),
        ),
      );
    }catch (e){
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
  }

  
}

