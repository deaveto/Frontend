import 'dart:convert';
import 'package:app_movil/provider/usuario.provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    
    //final size =MediaQuery.of(context).size;
    try{
      Map datos = json.decode(data);
      String fechaAsignacion = datos['fecha_asignacion'];
      // Separa en fecha y hora
      String fecha = fechaAsignacion.split('T')[0];              // "2025-04-09"
      String hora = fechaAsignacion.split('T')[1].split('.')[0]; // "22:53:56"
      return Scaffold(
        body: Center(
          child: Column(
            children: [
              Card.outlined(    
                color: const Color.fromARGB(255, 71, 159, 241),
                elevation: 10,
                //width: double.infinity,                                          
                child: Row(
                  children: [
                    Container( 
                          width: 150,
                          height: 200,
                          decoration: imagen(),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min, // 👈 Esto hace que la Column se ajuste a su contenido
                      crossAxisAlignment: CrossAxisAlignment.start, // 👈 Alineación a la izquierda
                      children: [                    
                        etiqueta('Origin:'),
                        SizedBox(height: 10),
                        etiqueta('Destination:'), 
                        SizedBox(height: 10),
                        etiqueta('Date In:'), 
                        SizedBox(height: 10), 
                        etiqueta('Hour In:'),
                        SizedBox(height: 10),
                        etiqueta('State:'),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min, // 👈 Esto hace que la Column se ajuste a su contenido
                      crossAxisAlignment: CrossAxisAlignment.start, // 👈 Alineación a la izquierda
                      children: [
                        etiqueta1('${datos['origen']}'),
                        SizedBox(height: 10),
                        etiqueta1('${datos['destino']}'),
                        SizedBox(height: 10),
                        etiqueta1('$fecha'),
                        SizedBox(height: 10),
                        etiqueta1('$hora'),
                        SizedBox(height: 10),
                        etiqueta1('${datos['estado']}'),
                      ],
                    )
                  ],
                )                      
              ),
              Card(child: Text('data'),)
            ],
          ),
          
        ),
      );
    }catch(e){return Center(child: Text(data));}
  }

  BoxDecoration imagen() {
    return BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/mapa1.png'),
        fit: BoxFit.fill, 
      ),
    );
  }

  Card etiqueta(String texto) {
    return Card.outlined(
      child: Text('  $texto  ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15 ,color: const Color.fromARGB(255, 0, 0, 0))),
      color: const Color.fromARGB(199, 255, 255, 255),
      elevation: 10,
    );
  }
  
  Card etiqueta1(String texto) {
    return Card(
      child: Text('  $texto  ', style: TextStyle(fontSize: 15 ,color: const Color.fromARGB(255, 0, 0, 0))),
      color: const Color.fromARGB(127, 255, 255, 255),
      elevation: 10,
    );
  }





}