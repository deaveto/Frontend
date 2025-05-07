import 'dart:convert';
import 'package:app_movil/provider/usuario.provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

// ignore: camel_case_types
class One_Tap extends StatefulWidget  {
  const One_Tap({super.key});
  @override
  State<One_Tap> createState() => _One_TapState();
}

// ignore: camel_case_types
class _One_TapState extends State<One_Tap> {
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


    try{
      List<dynamic> listaDatos = json.decode(data);
      String nombre = 'Diego Armando Velasquez Torres';
      String telefono = '+57 3105576478';
      String acompanante = '1';

      return Scaffold(
        backgroundColor: Color.fromARGB(0, 255, 255, 255),
        body: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(74, 128, 243, 1), // color de fondo del tap
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(vertical: 15), // separación entre el contenedor y el card
            child: ListView.builder(
              itemCount : listaDatos.length,
              itemBuilder: (context, index) {
                final datos = listaDatos[index];
                String fechaAsignacion = datos['fecha_asignacion'];
                String fecha = fechaAsignacion.split('T')[0];
                String hora = fechaAsignacion.split('T')[1].split('.')[0];
                String ruta = 'Ruta número ${index + 1}';
                return Column(
                  children: [
                    Ruta(fecha, ruta, nombre, telefono, acompanante, hora, datos),
                  ],
                );
              }
            ),
          ),
        ),
      );
    }catch(e){return Center(child: Text(data));}
  }

  // ignore: non_constant_identifier_names
  Card Ruta(String fecha, String ruta, String nombre, String telefono, String acompanante, String hora, Map<dynamic, dynamic> datos) {
    return Card(
      child: ExpansionTile(
        collapsedBackgroundColor: Color.fromRGBO(255, 255, 255, 1), // color del desplegable
        collapsedTextColor: Color.fromRGBO(38, 68, 165, 0.959), //Color de texto del titulo desdactivado
        collapsedIconColor: Color.fromRGBO(38, 68, 165, 0.959), // color de icono antes de desplegar
        iconColor: Color.fromRGBO(38, 68, 165, 0.959), // color de icono despues de desplegar
        title: Text('$ruta     $fecha      $hora', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15 ,)),
        subtitle: Texto2(nombre),
        children: [
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      SizedBox(height: 20),
                      Icon(
                        Icons.alt_route_rounded,
                        color: Color.fromRGBO(38, 68, 165, 0.959),
                        size: 70,
                      ),
                    ],
                  ),
                  Flexible(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Texto1('  Phone:             '),
                            Texto2('$telefono'), 
                          ],
                        ),
                        Row(
                          children: [
                            Texto1('  Companion:    '),
                            Texto2(acompanante), 
                          ],
                        ),
                        Row(
                          children: [
                            Texto1('  Valor:               '),
                            Texto2('${datos['valor_pago']}'), 
                          ],
                        ),
                        Row(
                          children: [
                            Texto1('  Origin:              '),
                            Expanded(child: Texto2('${datos['origen']}'),) 
                          ],
                        ),
                        Row(
                          children: [
                            Texto1('  Destination:    '),
                            Expanded(child: Texto2('${datos['destino']}'),) 
                          ],
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),              
            ],
          ),
          BotonesCard(datos),
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Row BotonesCard(Map<dynamic, dynamic> datos) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        MaterialButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          disabledColor: Colors.grey,
          color:const Color.fromARGB(255, 174, 187, 0),
          child: Container(
              //padding: EdgeInsets.symmetric(horizontal: 8,vertical: 15),
            child: Text('Map',style: TextStyle(color: Colors.white)),
          ),
          onPressed: (){_launchUrlMap(datos['origen'],datos['destino']);}
         ),
        const SizedBox(width: 8),
        MaterialButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          disabledColor: const Color.fromARGB(255, 94, 93, 93),
          color:const Color.fromARGB(255, 158, 0, 0),
          child: Container(
              //padding: EdgeInsets.symmetric(horizontal: 8,vertical: 15),
            child: Text('Cancel',style: TextStyle(color: Colors.white)),
          ),
          onPressed: (){ }
        ),
        const SizedBox(width: 8),
        MaterialButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          disabledColor: Colors.grey,
          color:const Color.fromARGB(255, 0, 150, 50),
          child: Container(
              //padding: EdgeInsets.symmetric(horizontal: 8,vertical: 15),
             child: Text('Finish Rout',style: TextStyle(color: Colors.white)),
          ),
          onPressed: (){
            Provider.of<UsuarioProvider>(context, listen: false)
            .actualizarEstadoRuta(datos['id'], 'completada', context);
          }
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  BoxDecoration imagen() {
    return BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/mapa1.png'),
        fit: BoxFit.fill, 
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Text Texto1(String texto) => Text(
    texto,
    style: TextStyle(
      fontWeight: FontWeight.bold, fontSize: 15 ,color: const Color.fromRGBO(38, 68, 165, 0.959)),
  );

  // ignore: non_constant_identifier_names
  Text Texto2(String texto) => Text(
    texto,
    style: TextStyle(fontSize: 15 ,color: const Color.fromARGB(255, 34, 95, 228)),
    softWrap: true,         // permite saltos de línea
    overflow: TextOverflow.visible, // muestra todo el texto, sin cortar
    maxLines: null,
  );

  Future<void> _launchUrlMap(String origen, String destino) async {
    Position posicion = await obtenerUbicacionActual();
    String UbicacionActual = '${posicion.latitude},${posicion.longitude}';

    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${Uri.encodeComponent(UbicacionActual)}'
      '&destination=${Uri.encodeComponent(destino)}'
      '&waypoints=${Uri.encodeComponent(origen)}'
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
}