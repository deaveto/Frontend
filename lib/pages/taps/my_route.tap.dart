import 'dart:convert';
import 'dart:async';
import 'package:app_movil/provider/usuario.provider.dart';
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
  int conteo = 1;
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
      Provider.of<UsuarioProvider>(context, listen: false).RutaUsuarioActivas(context);
    });
  }


  @override
  Widget build(BuildContext context) {
    final data = Provider.of<UsuarioProvider>(context).rutaActiva;
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
      print(grupos);

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
                        //print('$pasajeroIndex');
                        return ExpansionOrigen(pasajeroIndex, pasajero, Icons.album);
                      }(),
                    ],
                    for (var pasajero in grupo)...[
                      (){
                        pasajeroIndex++;
                        //print('$pasajeroIndex');
                        return ExpansionDestino(pasajeroIndex, pasajero, Icons.fmd_good_outlined);
                      }(),
                    ],
                    //for (var pasajero in grupo) ExpansionDestino(ruta, pasajero, Icons.fmd_good_outlined),
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

   // ignore: non_constant_identifier_names
  Widget ExpansionDestino(ruta, pasajero, IconData icono) {
    if((pasajero['estado_ruta'] == 'completo')&&(ruta == conteo))[conteo++];
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
              ? Colors.green[700]
              : Colors.white,
            collapsedBackgroundColor: ruta == conteo 
              ? Colors.green[200] 
              : Colors.white,
            title: Text(pasajero['destino'],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),
            subtitle: Text('Trip ID: ${pasajero['numero_seguro']}\n${pasajero['nombre_cliente']}',style: TextStyle(fontSize: 12)),
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
              if((pasajero['estado_ruta'] == 'recogido')&&(ruta==conteo))...[
                MaterialButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),side: BorderSide(color: Color.fromARGB(255, 255, 151, 32), width: 3)),
                  color: Colors.white,
                  child: Text('Finalizar', style: TextStyle(color: Color.fromARGB(255, 255, 151, 32),fontWeight: FontWeight.bold,fontSize: 16)),
                  onPressed:(){
                    Provider.of<UsuarioProvider>(context, listen: false)
                    .actualizarEstadoRuta(pasajero['id'], 'completo', context);
                    Navigator.pushReplacementNamed(context, 'home');
                  }
                ),
              ],
              if(pasajero['estado_ruta'] == 'completo')...[
                Icon(Icons.add_task, color: Colors.green, size: 30,),         
              ],
              if(pasajero['estado_ruta'] == 'cancelado')...[
                Icon(Icons.block_flipped, color: Colors.red, size: 50,)
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
              ? Colors.green[700]
              : Colors.white,
            collapsedBackgroundColor: ruta == conteo 
              ? Colors.green[200]
              : Colors.white,
            title: Text(pasajero['origen'],style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15,)),           
            subtitle: Text('ID: ${pasajero['numero_seguro']}\n${pasajero['nombre_cliente']}   --   Pickup Time: ${pasajero['hora']}',style: TextStyle(fontSize: 13)),
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
    return Column(    
      mainAxisSize: MainAxisSize.max,  
      children: [        
        SizedBox(height: 10),
        Row(     
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(width: 10),
            Column(
              children: [                
                if (botonEsperaDeshabilitado && pasajero['estado_ruta'] == 'espera')
                  Icon(Icons.access_time,color: Colors.white,),
                SizedBox(height: 5),
                Icon(Icons.accessibility_new_sharp,
                  color: ruta == conteo 
                    ? Colors.white
                    : Color.fromARGB(255, 0, 120, 218)
                ),
                SizedBox(height: 3),
                Icon(Icons.api_sharp,
                  color: ruta == conteo 
                    ? Colors.white
                    : Color.fromARGB(255, 0, 120, 218)
                )
              ],
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, // alinear hacia la izquierda
              children: [
                if (botonEsperaDeshabilitado && pasajero['estado_ruta'] == 'espera')
                  Text(formatoTiempo(tiempoRestante),
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(height: 15),
                Text('Passenger: ${pasajero['pasajero']}', 
                  style: TextStyle(
                    color: ruta == conteo 
                      ? Colors.white
                      : Colors.black,
                  )
                ),               
                SizedBox(height: 5),
                Text('${pasajero['estado_ruta']}', 
                  style: TextStyle(
                    color: ruta == conteo 
                      ? Colors.white
                      : Colors.black,
                  )
                ),
              ],
            ),
            //SizedBox(width: 100),
            SizedBox(
              width: size.width*0.58, //tamaño del sizebox para que el botn tenga espacio para linearce a la derecha
              child: Column(     
                crossAxisAlignment: CrossAxisAlignment.end, // alinear hacia la derecha
                mainAxisSize: MainAxisSize.max,                 
                  children: [
                  if ((pasajero['estado_ruta'] == 'asignada')&&(ruta == conteo))...[
                    MaterialButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),side: BorderSide(color: Color.fromARGB(255, 255, 167, 67), width: 3)),
                      color: Colors.white,
                      child: Text('Iniciar', style: TextStyle(color: Color.fromARGB(255, 241, 131, 6), fontWeight: FontWeight.bold,fontSize: 16)),
                      onPressed:(){
                        Provider.of<UsuarioProvider>(context, listen: false)
                        .actualizarEstadoRuta(pasajero['id'], 'en curso', context);
                        //Navigator.pushReplacementNamed(context, 'home');
                      } 
                    ),
                  ],                  
                  if (pasajero['estado_ruta'] == 'en curso') ...[     
                    MaterialButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),side: BorderSide(color: Color.fromARGB(255, 59, 167, 255), width: 3)),
                      color: botonEsperaDeshabilitado
                          ? Colors.orange.withOpacity(0.5)
                          : Colors.white,
                      child: Text('Mapa', style: TextStyle(color: Color.fromARGB(255, 0, 120, 218) , fontWeight: FontWeight.bold,fontSize: 16)),
                      onPressed: botonEsperaDeshabilitado
                        ? null
                         : () {_launchUrlMap(pasajero['origen']);},
                    ),               
                    MaterialButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),side: BorderSide(color: Color.fromARGB(255, 255, 167, 67), width: 3)),
                      color: botonEsperaDeshabilitado
                          ? Colors.orange.withOpacity(0.5)
                          : Colors.white,
                      child: Text('Esperar', style: TextStyle(color: Color.fromARGB(255, 241, 131, 6),fontWeight: FontWeight.bold,fontSize: 16)),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),side: BorderSide(color: Color.fromARGB(255, 177, 93, 255), width: 3)),
                      color: botonEsperaDeshabilitado
                          ? Color.fromARGB(255, 146, 45, 240).withOpacity(0.5)
                          : Colors.white,
                       child: Text('Recogido', style: TextStyle(color: Color.fromARGB(255, 132, 0, 255),fontWeight: FontWeight.bold,fontSize: 16)),
                      onPressed: botonEsperaDeshabilitado
                        ? null
                        : () {                        
                          Provider.of<UsuarioProvider>(context, listen: false)
                          .actualizarEstadoRuta(pasajero['id'], 'recogido', context);
                          },
                    ),                
                  ],      
                  if (pasajero['estado_ruta'] == 'espera') ...[ 
                    MaterialButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),side: BorderSide(color: Color.fromARGB(255, 255, 167, 67), width: 3)),
                      color: Colors.white,
                      child: Text('Recogido', style: TextStyle(color: Color.fromARGB(255, 255, 167, 67), fontWeight: FontWeight.bold)),
                      onPressed: () {
                        // acción recogido
                        Provider.of<UsuarioProvider>(context, listen: false)
                        .actualizarEstadoRuta(pasajero['id'], 'recogido', context);
                      },
                    ),
                    MaterialButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),side: BorderSide(color: Color.fromARGB(255, 255, 61, 61), width: 3)),
                      color: Colors.white,
                      child: Text('Cancelar', style: TextStyle(color: Color.fromARGB(255, 255, 0, 0), fontWeight: FontWeight.bold)),
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
  
  void _mostrarDialogoNota(BuildContext context, pasajero) {
  TextEditingController _notaController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Agregar una nota'),
        content: TextField(
          controller: _notaController,
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
              String nota = _notaController.text;
              print('Nota agregada: $nota'); // Aquí puedes hacer lo que quieras con la nota
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
