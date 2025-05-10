import 'dart:convert';
import 'dart:async';
import 'package:app_movil/provider/usuario.provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

// ignore: camel_case_types
class Two_Tap extends StatefulWidget {
  const Two_Tap({super.key});
  @override
  State<Two_Tap> createState() => _Two_TapState();
}

// ignore: camel_case_types
class _Two_TapState extends State<Two_Tap> {
  String estadoT = 'inicio'; // inicio, espera, final
  bool botonEsperaDeshabilitado = false;
  Duration tiempoRestante = Duration(minutes: 5);
  Timer? temporizador;

  void activarEspera() {
    setState(() {
      estadoT = 'espera';
      botonEsperaDeshabilitado = true;
      tiempoRestante = Duration(minutes: 1);
    });

    temporizador = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (tiempoRestante.inSeconds > 0) {
          tiempoRestante = tiempoRestante - Duration(seconds: 1);
        } else {
          temporizador?.cancel();
          estadoT = 'final';
        }
      });
    });
  }

  String formatoTiempo(Duration duration) {
    String dosDigitos(int n) => n.toString().padLeft(2, '0');
    return "${dosDigitos(duration.inMinutes)}:${dosDigitos(duration.inSeconds % 60)}";
  }

  @override
  void dispose() {
    temporizador?.cancel();
    super.dispose();
  }

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
                      child: Text(
                        'Origen:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    for (var pasajero in grupo) ExpansionOrigen(pasajero),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Destino:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    for (var pasajero in grupo) ExpansionDestino(pasajero),
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

  // ignore: non_constant_identifier_names
  ExpansionTile ExpansionDestino(pasajero) {
    return ExpansionTile(
      leading: const Icon(Icons.fmd_good_outlined),
      title: Text(
        pasajero['destino'],
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(
        'Trip ID: ${pasajero['numero_seguro']}\n${pasajero['nombre_cliente']}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize:
            MainAxisSize
                .min, // ¡Importante! Para que la fila se ajuste al contenido
        children: [
          IconButton(
            icon: Icon(Icons.navigation),
            onPressed: () {_launchUrlMap(pasajero['destino']);},
          ),// Acción del botón de navegación
          //const Icon(Icons.expand_more), // Flecha desplegable
        ],
      ),
      children: [
        SizedBox(height: 10),
        if(pasajero['estado_ruta'] == 'recogido')...[
          MaterialButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: const Color.fromARGB(255, 255, 151, 32),
            child: Text('Finalizar', style: TextStyle(color: Colors.white)),
            onPressed:(){
              Provider.of<UsuarioProvider>(context, listen: false)
              .actualizarEstadoRuta(pasajero['id'], 'completo', context);
            }
          ),
        ],
        if(pasajero['estado_ruta'] == 'completo')...[
          Icon(Icons.add_task, color: Colors.green, size: 50,),
          //Text('Ruta: ${pasajero['estado_ruta']}'),          
        ],
        if(pasajero['estado_ruta'] == 'cancelado')...[
          Icon(Icons.block_flipped, color: Colors.red, size: 50,)
        ],
        SizedBox(height: 10),
      ],
    );
  }

  // ignore: non_constant_identifier_names
  ExpansionTile ExpansionOrigen(pasajero) {
    return ExpansionTile(
      leading: const Icon(Icons.album),
      title: Text(
        pasajero['origen'],
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(
        'Trip ID: ${pasajero['numero_seguro']}\n${pasajero['nombre_cliente']}\nPickup Time: ${pasajero['hora']}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize:
            MainAxisSize.min, // ¡Importante! Para que la fila se ajuste al contenido
        children: [
          IconButton(icon: Icon(Icons.call,size: 20,color: Colors.green),onPressed: () {_makePhoneCall(pasajero['telefono']);}), // Acción del botón de llamada
          IconButton(icon: Icon(Icons.navigation,size: 20,color: Colors.amber),onPressed: () {_launchUrlMap(pasajero['destino']);},), // Acción del botón de navegación
          //const Icon(Icons.expand_more), // Flecha desplegable
        ],
      ),
      children: [DatosRuta(pasajero)],
    );
  }

  // ignore: non_constant_identifier_names
  Column DatosRuta(pasajero) {
    return Column(
      children: [        
        SizedBox(height: 10),
        Row(          
          children: [
            SizedBox(width: 55),
            Column(
              children: [
                Icon(Icons.accessibility_new_sharp),
                Icon(Icons.call_outlined),
                Icon(Icons.api_sharp)
              ],
            ),
            SizedBox(width: 10),
            Column(
              children: [
                SizedBox(height: 5),
                Text('Passenger: ${pasajero['pasajero']}'),
                SizedBox(height: 5),
                Text(pasajero['telefono']),
                SizedBox(height: 5),
                Text('State: ${pasajero['estado_ruta']}'),
              ],
            ),
            SizedBox(width: 100),
            Column(            
    /* */     children: [
                //SizedBox(width: 100),
                if (pasajero['estado_ruta'] == 'asignada')...[
                  MaterialButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    color: const Color.fromARGB(255, 255, 151, 32),
                    child: Text('Iniciar', style: TextStyle(color: Colors.white)),
                    onPressed:(){
                      Provider.of<UsuarioProvider>(context, listen: false)
                      .actualizarEstadoRuta(pasajero['id'], 'en curso', context);
                    } //iniciarRecorrido,
                  ),
                ],                  
                if (pasajero['estado_ruta'] == 'en curso') ...[                    
                  MaterialButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    color: botonEsperaDeshabilitado
                        ? Colors.orange.withOpacity(0.5)
                        : const Color.fromARGB(255, 255, 151, 32),
                    child: Text('Esperar', style: TextStyle(color: Colors.white)),
                    onPressed: botonEsperaDeshabilitado
                      ? null
                       : () {
                          Provider.of<UsuarioProvider>(context, listen: false)
                          .actualizarEstadoRuta(pasajero['id'], 'espera', context);
                          activarEspera();
                        },
                  ),
                  SizedBox(width: 10),
                  MaterialButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    color: botonEsperaDeshabilitado
                        ? const Color.fromARGB(255, 132, 0, 255).withOpacity(0.5)
                        : const Color.fromARGB(255, 132, 0, 255),
                     child: Text('Recogido', style: TextStyle(color: Colors.white)),
                    onPressed: botonEsperaDeshabilitado
                      ? null
                      : () {                        
                        Provider.of<UsuarioProvider>(context, listen: false)
                        .actualizarEstadoRuta(pasajero['id'], 'recogido', context);
                        },
                  ),                
                ],      
                if (botonEsperaDeshabilitado && pasajero['estado_ruta'] == 'espera')
                    Text(                      
                      'Tiempo: ${formatoTiempo(tiempoRestante)}',
                      style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold),
                    ),
            
                if ((estadoT == 'final' && pasajero['estado_ruta'] == 'espera')||(estadoT == 'inicio' && pasajero['estado_ruta'] == 'espera')) ...[
                      MaterialButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    color: const Color.fromARGB(255, 255, 151, 32),
                    child: Text('Recogido', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      // acción recogido
                      Provider.of<UsuarioProvider>(context, listen: false)
                      .actualizarEstadoRuta(pasajero['id'], 'recogido', context);
                    },
                  ),
                  //SizedBox(width: 10),
                  MaterialButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    color: Colors.redAccent,
                    child: Text('Cancelar', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      // acción cancelar
                      Provider.of<UsuarioProvider>(context, listen: false)
                      .actualizarEstadoRuta(pasajero['id'], 'cancelado', context);
                    },
                  ),
                ],
                if(pasajero['estado_ruta'] == 'cancelado')...[
                  Icon(Icons.block_flipped, color: Colors.red, size: 50,)
                ]     
              ],
            )                
          ],
        ),
        Row(
          children: [
            SizedBox(width: 55),
            Column(
              children: [
                SizedBox(height: 30),                
                Container(
                  alignment: Alignment.centerLeft, // alinear a la izquierda
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black,
                      ), // estilo base
                      children: [
                        TextSpan(text:'Trio Value:........................ \$ ${pasajero['valor_pago']}\n',),
                        TextSpan(text: 'CoPay:.............................. -\$ 2.90',style: TextStyle(color: Colors.red),),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _launchUrlMap(String destino) async {
    Position posicion = await obtenerUbicacionActual();
    String UbicacionActual = '${posicion.latitude},${posicion.longitude}';

    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${Uri.encodeComponent(UbicacionActual)}'
      '&destination=${Uri.encodeComponent(destino)}'
      '&travelmode=driving',
    );
    if (!await launchUrl(url, mode:LaunchMode.externalApplication)) {
    throw Exception('Could not launch $url');
    }
  }

  Future<Position> obtenerUbicacionActual() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('El servicio de ubicación está desactivado.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permiso de ubicación denegado');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Los permisos de ubicación están permanentemente denegados');
    }

    return await Geolocator.getCurrentPosition();
  }

  void llamarNumero(String numero) async {
    final Uri url = Uri(scheme: 'tel', path: numero);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'No se pudo lanzar el marcador para $numero';
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }
  
}
