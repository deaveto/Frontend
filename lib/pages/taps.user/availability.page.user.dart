import 'dart:convert';
import 'package:app_movil/provider/datos.personales.provider.dart';
import 'package:app_movil/provider/login.provider.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';

class availability extends StatefulWidget {
  const availability({super.key});
  @override
  State<availability> createState() => _availabilityState();
}

class _availabilityState extends State<availability> with AutomaticKeepAliveClientMixin{
  @override
  bool get wantKeepAlive => false; // <-- Esto fuerza la destrucción
  bool inicializado = false;
  List<Map<String, dynamic>> horarios = [];

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

    try {
      final decoded = json.decode(data);

      // Inicializar horarios una sola vez
      if (!inicializado) {
        final horariosRaw = decoded["horarios"] as List<dynamic>;
        horarios = horariosRaw.map((h) => {
          "dia": h["dia"],
          "hora_inicio": TextEditingController(text: h["hora_inicio"].toString().substring(0, 5)),
          "hora_fin": TextEditingController(text: h["hora_fin"].toString().substring(0, 5),),
        }).toList();
        
        final ordenDias = {
          "lunes": 1,
          "martes": 2,
          "miércoles": 3,
          "miercoles": 3, // por si llega sin tilde
          "jueves": 4,
          "viernes": 5,
          "sábado": 6,
          "sabado": 6, // por si llega sin tilde
          "domingo": 7,
        };

        horarios.sort((a, b) {
          final diaA = ordenDias[a["dia"].toLowerCase()] ?? 99;
          final diaB = ordenDias[b["dia"].toLowerCase()] ?? 99;
          return diaA.compareTo(diaB);
        });

        inicializado = true;
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('Schedule Availability', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green[700],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Row(
                children: [
                  Expanded(child: Text("Day", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 19))),
                  Expanded(child: Text("Start Time", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 19))),
                  Expanded(child: Text("End time", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 19))),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: horarios.length,
                  itemBuilder: (context, index) {
                    final h = horarios[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          Expanded(child: Text(h["dia"],style: TextStyle(fontSize: 18))),
                          Expanded(
                            child: TextField(
                              controller: h["hora_inicio"],
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color.fromARGB(255, 3, 94, 0), width: 1.5), // Cuando no está enfocado
                                ),
                                isDense: true,
                                contentPadding: EdgeInsets.all(10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: h["hora_fin"],
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color.fromARGB(255, 3, 94, 0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color.fromARGB(255, 3, 94, 0), width: 1.5), // Cuando no está enfocado
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color.fromARGB(255, 3, 94, 0), width: 2.0), // Cuando está enfocado
                                ),
                                isDense: true,
                                contentPadding: EdgeInsets.all(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              //const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  final provider = Provider.of<ProfileDatos>(context, listen: false);
                  final RegExp horaRegex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');

                  // Validar que todos los campos cumplan el formato hh:mm
                  bool esValido = true;
                  for (var h in horarios) {
                    final inicio = (h['hora_inicio'] as TextEditingController).text.trim();
                    final fin = (h['hora_fin'] as TextEditingController).text.trim();

                    if (!horaRegex.hasMatch(inicio) || !horaRegex.hasMatch(fin)) {
                      esValido = false;
                      break;
                    }
                  }

                  if (!esValido) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Por favor usa el formato correcto hh:mm (ej: 08:30)')),
                    );
                    return; // No se continúa con el guardado
                  }

                  // Si es válido, construye el JSON y envía
                  final List<Map<String, String>> horariosFinal = horarios.map((h) => {
                    'dia': h['dia'] as String,
                    'hora_inicio': (h['hora_inicio'] as TextEditingController).text,
                    'hora_fin': (h['hora_fin'] as TextEditingController).text,
                  }).toList();


                  provider.actualizarHorarios(context, horariosFinal);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Save"),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    } catch (e) {
      return const Scaffold(
        body: Center(child: Text("Error al procesar los datos")),
      );
    }
  }
  
}
