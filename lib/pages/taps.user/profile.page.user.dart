import 'dart:convert';
import 'package:app_movil/provider/datos.personales.provider.dart';
import 'package:app_movil/provider/login.provider.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with AutomaticKeepAliveClientMixin{
  @override
  bool get wantKeepAlive => false; // <-- Esto fuerza la destrucción
  bool inicializado = false;


  // Controladores para el formulario
  late TextEditingController nombreController;
  late TextEditingController apellidoController;
  late TextEditingController usuarioController;
  late TextEditingController correoController;
  late TextEditingController generoController;
  late TextEditingController estadoController;
  late TextEditingController telefonoController;
  late TextEditingController licenciaConducirController;
  late TextEditingController licenciaTLLController;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<ProfileDatos>(context, listen: false).ProfileDatosPersonales(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final data = Provider.of<ProfileDatos>(context).DatoPersonal;
    final token = Provider.of<AuthProvider>(context, listen: false).accessToken;
    // Verificar si el contenido está vacío o inválido antes de hacer decode
      if (token == null || JwtDecoder.isExpired(token)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, 'login');
        });
      }
      if (data.isEmpty || data.trim() == "") {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
 
    try{
      
      final decoded = json.decode(data);
      final perfil = decoded["perfil"]; 

      if (!inicializado) {
        nombreController = TextEditingController(text: decoded["first_name"]);
        apellidoController = TextEditingController(text: decoded["last_name"]);
        usuarioController = TextEditingController(text: decoded["username"]);
        correoController = TextEditingController(text: decoded["email"]);
        generoController = TextEditingController(text: perfil["genero"] == "F" ? "Femenino":"Masculino");
        estadoController = TextEditingController(text: decoded["is_active"] == true ? "Activo" : "Inactivo");
        telefonoController = TextEditingController(text: perfil["telefono"]);
        licenciaConducirController = TextEditingController(text: perfil["numeroLicenciaConducir"]);
        licenciaTLLController = TextEditingController(text: perfil["numeroLicenciaTLL"]);
        inicializado = true;
      }
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green[700],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: campoFormulario("Names", nombreController)),
                  const SizedBox(width: 10),
                  Expanded(child: campoFormulario("Last Name", apellidoController)),
                ],
              ),
              SizedBox(height: 20),
              campoFormulario("User", usuarioController, readOnly: true),
              SizedBox(height: 20),
              campoFormulario("Email", correoController),
              Row(
                children: [
                  Expanded(child: campoFormulario("Gender", generoController)),
                  const SizedBox(width: 10),
                  Expanded(child: campoFormulario("State", estadoController, readOnly: true)),
                ],
              ),
              SizedBox(height: 20),           
              campoFormulario("Phone", telefonoController),
              SizedBox(height: 20),
              campoFormulario("Driver's License", licenciaConducirController),
              SizedBox(height: 20),
              campoFormulario("TLL License", licenciaTLLController),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white, // Color del texto
                  minimumSize: Size(100, 55), // ancho: 200, alto: 50
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  final profileProvider = Provider.of<ProfileDatos>(context, listen: false);

                  final data = {
                    "username": usuarioController.text,
                    "first_name": nombreController.text,
                    "last_name": apellidoController.text,
                    "email": correoController.text,
                    "perfil": {
                      "telefono": telefonoController.text,
                      "direccion": "calle falsa 123", // puedes agregar otro campo si lo incluyes en el formulario
                      "genero": generoController.text == "Femenino" ? "F" : "M",
                      "numeroLicenciaConducir": licenciaConducirController.text,
                      "numeroLicenciaTLL": licenciaTLLController.text
                    }
                  };
                  profileProvider.actualizarDatosUsuario(context, data);
                },
                child: Text("Save changes"),
                
              ),
            ],
          ),
        ),
      );
    }catch(e){      
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }    
  }

  // Widget auxiliar para no repetir
  Widget campoFormulario(String label, TextEditingController controller, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        readOnly: readOnly, // <--- aquí se aplica
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color.fromARGB(255, 3, 94, 0), // ← Cambia el color aquí
            fontWeight: FontWeight.bold, // Opcional: negrita
          ),
          border: const OutlineInputBorder(),
          filled: true, // Activar el color de fondo
          fillColor: Colors.green[90], // Color de fondo del campo
          enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromARGB(255, 3, 94, 0), width: 1.5), // Borde cuando no está enfocado
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color.fromARGB(255, 3, 94, 0), width: 2), // Borde cuando se enfoca
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
    
}

