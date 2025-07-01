import 'dart:convert';
import 'dart:async';
import 'package:app_movil/provider/rutas_disponibles.provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:url_launcher/url_launcher.dart';


class Avai_Trip extends StatefulWidget {
  const Avai_Trip({super.key});

  @override
  State<Avai_Trip> createState() => _Avai_TripState();
}

class _Avai_TripState extends State<Avai_Trip> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => false;
  bool _isLoading = false;  
  

  Future<void> _loadRutas() async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<RutasDisponiblesProvider>(context, listen: false)
        .cargarRutasSinAsignar(context);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRutas());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final data = Provider.of<RutasDisponiblesProvider>(context).rutasSinAsignar;
    if (data.isEmpty || data.trim() == "") {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    List<dynamic> listaDatos = [];
    try {
      listaDatos = json.decode(data);
      listaDatos.sort((a, b) {
        final formato = RegExp(r'(\d+):(\d+)\s(AM|PM)');
        DateTime parseHora(String horaStr) {
          final match = formato.firstMatch(horaStr);
          if (match == null) return DateTime(0);
          int hour = int.parse(match.group(1)!);
          int minute = int.parse(match.group(2)!);
          String period = match.group(3)!;
          if (period == 'PM' && hour != 12) hour += 12;
          if (period == 'AM' && hour == 12) hour = 0;
          return DateTime(0, 1, 1, hour, minute);
        }
        final horaA = parseHora(a['hora']);
        final horaB = parseHora(b['hora']);
        return horaA.compareTo(horaB);
      });
    } catch (e) {
      return Scaffold(
        body: Center(child: Text("No hay rutas sin asignar para esta fecha")),
        floatingActionButton: FloatingActionButton(
          onPressed: _loadRutas,
          child: Icon(Icons.refresh),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              child: Column(
                children: [
                  const SizedBox(height: 5),
                  CardDatos(listaDatos),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[700], // color del fondo del boton
        focusColor : Colors.blue[500], // color del icono
        onPressed: _loadRutas,
        tooltip: 'Refrescar',
        child: const Icon(Icons.refresh,color: Colors.white,),
      ),
    );
  }

  Expanded CardDatos(List<dynamic> listaDatos) {
    final size = MediaQuery.of(context).size;
    return Expanded(
      child: listaDatos.isEmpty
          ? const Center(child: Text("No hay rutas sin asignar para esta fecha"))
          : ListView.builder(
              itemCount: listaDatos.length,
              itemBuilder: (context, index) {
                final datos = listaDatos[index];
                return Card(
                  elevation: 5,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue[800],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 15),
                            SizedBox(
                              width: size.width * 0.5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  Texto1(datos['nombre_cliente']),
                                  Texto2('ID: ${datos['numero_seguro']}'),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: size.width * 0.35,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const SizedBox(height: 10),
                                  Texto1('passengers: ${datos['pasajero']}'),
                                  Texto2(datos['telefono']),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          const SizedBox(width: 15),
                          SizedBox(
                            width: size.width * 0.35,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Texto11('Pickup'),
                                Texto22('${datos['hora']}'),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: size.width * 0.5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Texto22('${datos['origen']}'),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          const SizedBox(width: 15),
                          SizedBox(
                            width: size.width * 0.35,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Texto11('Dropoff'),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: size.width * 0.5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Texto22('${datos['destino']}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          const SizedBox(width: 10),
                          SizedBox(
                            width: size.width * 0.35,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MaterialButton(
                                  minWidth: 100,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  color: Colors.white,
                                  child: Text('Tomar Ruta', style: TextStyle(color: Color.fromARGB(255, 219, 117, 0), fontWeight: FontWeight.bold)),
                                  onPressed:(){
                                    Provider.of<RutasDisponiblesProvider>(context, listen: false)
                                    .actualizarRutaSinAsignar(datos['id'], context);
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: size.width * 0.52,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                MaterialButton(
                                  minWidth: 100,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  color: Colors.white,
                                  child: Text('Ver Ruta', style: TextStyle(color: Color.fromARGB(255, 219, 117, 0), fontWeight: FontWeight.bold)),
                                  onPressed:(){
                                    _launchUrlMap(datos['origen'],datos['destino']);
                                  },
                                ),
                              ],
                            ),
                          )
                        ],
                      ),   
                      Container(
                        width: double.infinity,
                        height: 2,
                        color: const Color.fromARGB(14, 0, 0, 0),
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 15),
                          SizedBox(
                            width: size.width * 0.5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Texto3('Trip Value'),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: size.width * 0.35,
                            child: Column(
                               crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Texto3('\$${datos['total_final']}'),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ],
                      ),             
                    ],
                  ),
                );
              },
            ),
    );
  }

  Text Texto1(String texto) =>
      Text(texto, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold));

  Text Texto2(String texto) => Text(texto, style: const TextStyle(color: Colors.white));

  Text Texto11(String texto) =>
      Text(texto, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold));

  Text Texto22(String texto) => Text(texto, style: const TextStyle(color: Colors.black));

  Text Texto3(String texto) => Text(texto,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
      );

  Text Texto4(String texto) => Text( texto,
        style: TextStyle(
          color: Colors.deepOrangeAccent[700],
          fontWeight: FontWeight.bold,
          fontSize: 15,
          decoration: TextDecoration.lineThrough,
        ),
      );

  Future<void> _launchUrlMap(String origen, String destino) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${Uri.encodeComponent(origen)}'
      '&destination=${Uri.encodeComponent(destino)}'
      //'&waypoints=${Uri.encodeComponent(origen)}'
      '&travelmode=driving',
    );
    if (!await launchUrl(url, mode:LaunchMode.externalApplication)) {
    throw Exception('Could not launch $url');
    }
  }

}
