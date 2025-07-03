import 'dart:convert';
import 'dart:async';
import 'package:app_movil/constantes.dart';
import 'package:app_movil/provider/usuario.provider.dart';
import 'package:app_movil/widgets/Ubicacion.dart';
import 'package:app_movil/widgets/UbicacionContinua.dart';

import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

// ignore: camel_case_types
class MyRoute extends StatefulWidget {
  const MyRoute({super.key});
  @override
  State<MyRoute> createState() => _MyRouteState();
}

// ignore: camel_case_types
class _MyRouteState extends State<MyRoute> {
  final token = accessToken;
  int conteo = 1;
  String estadoT = 'inicio'; // inicio, espera, final
  bool botonEsperaDeshabilitado = false;
  Duration tiempoRestante = Duration(minutes: 5);
  Timer? temporizador;
  double? distanciaAlPasajero;

  // ignore: unused_field
  StreamSubscription<Position>? _posicionSub;
  Position? _posicionActual;

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
    _iniciarSeguimientoUbicacion();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<UsuarioProvider>(context, listen: false).RutaUsuarioActivas(context);
    });
  }
  
  void _iniciarSeguimientoUbicacion() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  LocationPermission permission = await Geolocator.checkPermission();
  if (!serviceEnabled || permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
    // Solicitar permisos o mostrar error
    await Geolocator.requestPermission();
    return;
  }

  _posicionSub = obtenerUbicacionContinua().listen((Position position) {
    setState(() {
      _posicionActual = position;
    });
  });
}
  @override
  Widget build(BuildContext context) {
    
    final data = Provider.of<UsuarioProvider>(context).rutaActiva;
    if (data.isEmpty || data.trim() == "") {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    int pasajeroIndex = 0; // Contador global de pasajeros
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
            padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
            child: ListView.builder(
              itemCount: grupos.length,
              itemBuilder: (context, grupoIndex) {
                final grupo = grupos[grupoIndex];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    for (var pasajero in grupo)...[
                      (){
                        pasajeroIndex++;

                        return ExpansionOrigen(pasajeroIndex, pasajero, Icons.album);
                      }(),
                    ],
                    for (var pasajero in grupo)...[
                      (){
                        pasajeroIndex++;

                        return ExpansionDestino(pasajeroIndex, pasajero, Icons.fmd_good_outlined);
                      }(),
                    ],

                  ],
                );
              },
            ),
          ),
        ),
      );
    } catch (e) {
      return Container(
        color: Colors.white,
        child: Center(child: Text('No tienes rutas activas para esta fecha')),
      );
    }
  }

  Future<double?> obtenerDistanciaGoogleMatrix(pasajero) async {
    final origenStr = '${_posicionActual ?.latitude},${_posicionActual ?.longitude}';
    final destinoEncoded = Uri.encodeComponent(pasajero);
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/distancematrix/json?'
      'origins=$origenStr&destinations=$destinoEncoded&mode=driving&key=$DistanceMatrixapi',
    );    
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final distanciaValor = data['rows'][0]['elements'][0]['distance']['value']; // en metros
      if (distanciaValor != null) {
        setState(() {
          distanciaAlPasajero = distanciaValor.toDouble();
          print('distancia: $distanciaAlPasajero');
        });
      }
    } else {
      print('Error: ${response.body}');
      return null;
    }
    return null;
  }

  Future<double?> obtenerDistanciaGoogleMatrix1(pasajero) async {
    final origenStr = '${_posicionActual ?.latitude},${_posicionActual ?.longitude}';
    final destinoEncoded = Uri.encodeComponent(pasajero);
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/distancematrix/json?'
      'origins=$origenStr&destinations=$destinoEncoded&mode=driving&key=$DistanceMatrixapi',
    );    
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final distanciaValor = data['rows'][0]['elements'][0]['distance']['value']; // en metros
      if (distanciaValor != null) {
        setState(() {
          distanciaAlPasajero = distanciaValor.toDouble();
          print('distancia: $distanciaAlPasajero');
        });
      }
    } else {
      print('Error: ${response.body}');
      return null;
    }
    return null;
  }

   // ignore: non_constant_identifier_names
  Widget ExpansionDestino(ruta, pasajero, IconData icono) {
    if((pasajero['estado_ruta'] == 'completo')&&(ruta == conteo))[conteo++];

    Timer.periodic(Duration(seconds: 3), (timer) {
      if (mounted && pasajero['estado_ruta'] == 'recogido') {
        obtenerDistanciaGoogleMatrix1(pasajero['destino']);
      } else {
        timer.cancel();
      }
    });
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna izquierda con ícono y línea
        Column(
          children: [
            Icon(icono, size: 20, color: Color.fromARGB(155, 1, 109, 1)),
            Container(
              width: 2,
              height: 65, // ajusta según necesites
              color: Color.fromARGB(155, 0, 0, 0),
            ),
          ],
        ),
        const SizedBox(width: 8), // Espacio entre la línea y el contenido
        Expanded(
          child: ExpansionTile(
            backgroundColor: ruta == conteo 
              ? Colors.blue[800]
              : Colors.white,
            collapsedBackgroundColor: ruta == conteo 
              ? Colors.blue[100] 
              : Colors.white,
            title: Text(pasajero['destino'],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
            subtitle: Text('Trip ID: ${pasajero['numero_seguro']}\n${pasajero['nombre_cliente']}',style: TextStyle(fontSize: 15)),
            textColor:ruta == conteo 
              ? Colors.white
              : Colors.black,
            trailing: Row(
              mainAxisSize: MainAxisSize.min, // ¡Importante! Para que la fila se ajuste al contenido
              children: [// Acción del botón de navegación
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: ruta == conteo 
                    ? Colors.white
                    : Colors.amber,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.navigation, 
                      size: 20, 
                      color: ruta == conteo 
                    ? Colors.amber
                    : Colors.white,
                    ),
                    onPressed: () => _launchUrlMap(pasajero['destino'])
                  ),
                ),
              ],
            ),
            children: [
              SizedBox(height: 10),
              if((pasajero['estado_ruta'] == 'recogido')&&(ruta==conteo)&&(distanciaAlPasajero != null && distanciaAlPasajero! <= 50))...[
                MaterialButton(
                  minWidth: 100,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  color: Colors.white,
                  child: Text('Finalizar', style: TextStyle(color: Color.fromARGB(255, 219, 117, 0),fontWeight: FontWeight.bold,fontSize: 16)),
                  onPressed:(){
                    Provider.of<UsuarioProvider>(context, listen: false)
                    .actualizarEstadoRuta(pasajero['id'], 'completo', context);
                    Navigator.pushReplacementNamed(context, 'home');
                  }
                ),
              ],
              if(pasajero['estado_ruta'] == 'completo')...[
                Text('Finalized', style: TextStyle(color: Colors.green[800],fontWeight: FontWeight.bold,fontSize: 16)),
                  
                //Icon(Icons.add_task, color: Colors.green, size: 30,),         
              ],

              SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }

  // ignore: non_constant_identifier_names
  Widget ExpansionOrigen(ruta, pasajero, IconData icono) {     
    if(((pasajero['estado_ruta'] == 'recogido')||(pasajero['estado_ruta'] == 'completo'))&&(ruta == conteo))[conteo++,print(conteo)];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna izquierda con ícono y línea
        Column(
          children: [
            Icon(icono, size: 20, color: const Color.fromARGB(155, 1, 109, 1)),
            Container(
              width: 2,
              height: 65, // ajusta de tamalo de la linea que conecta las rutas
              color: Color.fromARGB(155, 0, 0, 0),
            ),
          ],
        ),
        const SizedBox(width: 8), // Espacio entre la línea y el contenido
        Expanded(
          child: ExpansionTile(
            backgroundColor: ruta == conteo 
              ? Colors.blue[800]
              : Colors.white,
            collapsedBackgroundColor: ruta == conteo 
              ? Colors.blue[100]
              : Colors.white,
            title: Text(pasajero['origen'],style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),           
            subtitle: Text('ID: ${pasajero['numero_seguro']}\n${pasajero['nombre_cliente']}   --   Pickup Time: ${pasajero['hora']}',style: TextStyle(fontSize: 15)),
            textColor:ruta == conteo 
              ? Colors.white
              : Colors.black,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color:  ruta == conteo 
                    ? Colors.white
                    : Colors.blueAccent,
                    //Colors.blueAccent,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.call, 
                      size: 20, 
                      color: ruta == conteo 
                    ? Colors.blueAccent
                    : Colors.white,
                    ),
                    onPressed: () => _makePhoneCall(pasajero['telefono'])
                  ),
                ),         
              ],
            ),
            children: [
              DatosRuta(conteo, ruta, pasajero),
              SizedBox(height: 25),
              Text('Trio Value........................ \$ ${pasajero['total_final']}\n',
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  color: ruta == conteo 
              ? Colors.white
              : Colors.black,
                )
              ),
              //SizedBox(height: 1),
            ],
          ),
        ),
      ],
    );
  }
  
  // ignore: non_constant_identifier_names
  Column DatosRuta(conteo, ruta, pasajero) { 
    final size = MediaQuery.of(context).size;
    /*Timer.periodic(Duration(seconds: 3), (timer) {
      if (mounted && pasajero['estado_ruta'] == 'en curso') {
        obtenerDistanciaGoogleMatrix(pasajero['origen']);
      } else {
        timer.cancel();
      }
    });*/
    
    return Column(    
      mainAxisSize: MainAxisSize.max,  
      children: [        
        SizedBox(height: 10),
        Row(     
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, // alinear hacia la izquierda
              children: [
                if (botonEsperaDeshabilitado && pasajero['estado_ruta'] == 'espera')
                  Text(formatoTiempo(tiempoRestante),
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 16)),
                /*SizedBox(height: 15),
                if (pasajero['estado_ruta'] == 'en curso')
                  Text('${distanciaAlPasajero?.toStringAsFixed(2)} m',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 16)),
                */
                SizedBox(height: 15),
                Text('Passenger: ${pasajero['pasajero']}', 
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ruta == conteo 
                      ? Colors.white
                      : Colors.black,
                  )
                ),               
                SizedBox(height: 5),
                Text('State: ${pasajero['estado_ruta']}', 
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ruta == conteo 
                      ? Colors.white
                      : Colors.black,
                  )
                ),
              ],
            ),

            SizedBox(
              width: size.width*0.54, //tamaño del sizebox para que el botn tenga espacio para linearce a la derecha
              child: Column(     
                crossAxisAlignment: CrossAxisAlignment.end, // alinear hacia la derecha
                mainAxisSize: MainAxisSize.max,                 
                  children: [
                  if ((pasajero['estado_ruta'] == 'asignada')&&(ruta == conteo))...[
                    MaterialButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      color: Colors.white,
                      child: Text('Iniciar', style: TextStyle(color: Color.fromARGB(255, 219, 117, 0), fontWeight: FontWeight.bold,fontSize: 16)),
                      onPressed:(){
                        Provider.of<UsuarioProvider>(context, listen: false)
                        .actualizarEstadoRuta(pasajero['id'], 'en curso', context);
                        _launchUrlMap(pasajero['origen']);
                        Navigator.pushReplacementNamed(context, 'home');
                      } 
                    ),
                  ],
                  if (pasajero['estado_ruta'] == 'en curso') ...[   
                    MaterialButton(
                      minWidth: 100,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      color: botonEsperaDeshabilitado
                          ? Colors.orange.withOpacity(0.5)
                          : Colors.white,
                      child: Text('Mapa', style: TextStyle(color: Color.fromARGB(255, 0, 110, 201) , fontWeight: FontWeight.bold,fontSize: 16)),
                      onPressed: botonEsperaDeshabilitado
                        ? null
                        : () {_launchUrlMap(pasajero['origen']);},
                    ),

                    MaterialButton(
                      minWidth: 100,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      color: botonEsperaDeshabilitado
                          ? Colors.orange.withOpacity(0.5)
                          : Colors.white,
                      child: Text('Esperar', style: TextStyle(color: Color.fromARGB(255, 219, 117, 0),fontWeight: FontWeight.bold,fontSize: 16)),
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
                      minWidth: 100,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      color: botonEsperaDeshabilitado
                          ? Color.fromARGB(255, 146, 45, 240).withOpacity(0.5)
                          : Colors.white,
                       child: Text('Recogido', style: TextStyle(color: Color.fromARGB(255, 0, 117, 16),fontWeight: FontWeight.bold,fontSize: 16)),
                      onPressed: botonEsperaDeshabilitado
                        ? null
                        : () {                        
                          Provider.of<UsuarioProvider>(context, listen: false)
                          .actualizarEstadoRuta(pasajero['id'], 'recogido', context);
                          },
                    ),                
                  ],
                  /*if ((pasajero['estado_ruta'] == 'en curso')&&(distanciaAlPasajero != null && distanciaAlPasajero! <= 50)) ...[                  
                    MaterialButton(
                      minWidth: 100,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      color: botonEsperaDeshabilitado
                          ? Colors.orange.withOpacity(0.5)
                          : Colors.white,
                      child: Text('Esperar', style: TextStyle(color: Color.fromARGB(255, 219, 117, 0),fontWeight: FontWeight.bold,fontSize: 16)),
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
                      minWidth: 100,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      color: botonEsperaDeshabilitado
                          ? Color.fromARGB(255, 146, 45, 240).withOpacity(0.5)
                          : Colors.white,
                       child: Text('Recogido', style: TextStyle(color: Color.fromARGB(255, 0, 117, 16),fontWeight: FontWeight.bold,fontSize: 16)),
                      onPressed: botonEsperaDeshabilitado
                        ? null
                        : () {                        
                          Provider.of<UsuarioProvider>(context, listen: false)
                          .actualizarEstadoRuta(pasajero['id'], 'recogido', context);
                          },
                    ),                
                  ],  */    
                  if (pasajero['estado_ruta'] == 'espera') ...[ 
                    MaterialButton(
                      minWidth: 100,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      color: Colors.white,
                      child: Text('Recogido', style: TextStyle(color: Color.fromARGB(255, 219, 117, 0), fontWeight: FontWeight.bold,fontSize: 16)),
                      onPressed: () {
                        // acción recogido
                        Provider.of<UsuarioProvider>(context, listen: false)
                        .actualizarEstadoRuta(pasajero['id'], 'recogido', context);
                      },
                    ),
                    MaterialButton(
                      minWidth: 100,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      color: Colors.white,
                      child: Text('Cancelar', style: TextStyle(color: Color.fromARGB(255, 185, 0, 0), fontWeight: FontWeight.bold,fontSize: 16)),
                      onPressed: () {
                        // acción cancelar
                        _mostrarDialogoNota(context, pasajero); 
                        Provider.of<UsuarioProvider>(context, listen: false)
                        .actualizarEstadoRuta(pasajero['id'], 'cancelado', context);                     
                      },
                    ),
                  ],
                  if(pasajero['estado_ruta'] == 'recogido')...[
                    Icon(Icons.add_task_outlined, color: Colors.green, size: 30,)
                  ],
                  if(pasajero['estado_ruta'] == 'completo')...[
                    Icon(Icons.add_task, color: Colors.green, size: 30,),         
                  ],
                ],
              ),
            )                
          ],
        ),
      ],
    );
  }

  Future<void> _launchUrlMap(String destino) async {
    Position posicion = await obtenerUbicacionActual();
    // ignore: non_constant_identifier_names
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
  
  void _mostrarDialogoNota(BuildContext context, pasajero) {
  TextEditingController notaController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Agregar una nota'),
        content: TextField(
          controller: notaController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Escribe tu nota aquí...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo
            },
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              String nota = notaController.text;

              Navigator.of(context).pop(); // Cierra el diálogo
              Provider.of<UsuarioProvider>(context, listen: false)
              .actualizarEstadoRuta(pasajero['id'], 'cancelado', context);
              Provider.of<UsuarioProvider>(context, listen: false)
              .actualizarNotasRuta(pasajero['id'], nota, context);
              
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

}
