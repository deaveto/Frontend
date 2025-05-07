import 'dart:convert';
import 'package:app_movil/provider/usuario.provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class Two_Tap extends StatefulWidget {
  const Two_Tap({super.key});
  @override
  State<Two_Tap> createState() => _Two_TapState();
}

class _Two_TapState extends State<Two_Tap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<UsuarioProvider>(context, listen: false).RutaUsuario(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<UsuarioProvider>(context).rutaActiva;

    try {
      List<dynamic> listaDatos = json.decode(data);
      // Ordenar por hora
      listaDatos.sort((a, b) {
        final horaA = DateFormat('hh:mm a').parse(a['hora']);
        final horaB = DateFormat('hh:mm a').parse(b['hora']);
        return horaA.compareTo(horaB);
      });

      List<List<dynamic>> grupos = [];
      List<dynamic> grupoActual = [];

      DateTime? ultimaHora;

      for (var pasajero in listaDatos) {
        final horaPasajero = DateFormat('hh:mm a').parse(pasajero['hora']);

        if (ultimaHora == null) {
          grupoActual.add(pasajero);
          ultimaHora = horaPasajero;
        } else {
          final diferencia = horaPasajero.difference(ultimaHora).inMinutes;

          if (diferencia <= 30) {
            grupoActual.add(pasajero);
            ultimaHora = horaPasajero;
          } else if (diferencia > 45) {
            grupos.add(grupoActual);
            grupoActual = [pasajero];
            ultimaHora = horaPasajero;
          } else {
            // caso intermedio: se puede adaptar según reglas específicas
            grupos.add(grupoActual);
            grupoActual = [pasajero];
            ultimaHora = horaPasajero;
          }
        }
      }

      if (grupoActual.isNotEmpty) grupos.add(grupoActual);

      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: ListView.builder(
              itemCount: grupos.length,
              itemBuilder: (context, grupoIndex) {
                final grupo = grupos[grupoIndex];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(thickness: 2),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Recogidas:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    for (var pasajero in grupo)
                      ExpansionTile(
                        leading: const Icon(Icons.album),
                        title: Text(pasajero['origen'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text(
                          'Trip ID: ${pasajero['numero_seguro']}\n${pasajero['nombre_cliente']}\nPickup Time: ${pasajero['hora']}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Destinos:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    for (var pasajero in grupo)
                      ExpansionTile(
                        leading: const Icon(Icons.fmd_good_outlined),
                        title: Text(pasajero['destino'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text(
                          'Trip ID: ${pasajero['numero_seguro']}\n${pasajero['nombre_cliente']}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    } catch (e) {
      return Center(child: Text('Error al cargar datos:\n$data'));
    }
  }
}
