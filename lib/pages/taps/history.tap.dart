import 'dart:convert';
import 'package:app_movil/provider/usuario.provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


// ignore: camel_case_types
class Hystory extends StatefulWidget  {
  const Hystory({super.key});
  @override
  State<Hystory> createState() => _HystoryState();
}

// ignore: camel_case_types
class _HystoryState extends State<Hystory> {
  TextEditingController _dateController = TextEditingController();
  String FechaSeleccionada = new DateTime.now().toString().split(" ")[0];
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<UsuarioProvider>(context, listen: false).RutaUsuarioFecha(FechaSeleccionada,context);      
    });
  } 
  
  @override 
  Widget build(BuildContext context) {
    final data = Provider.of<UsuarioProvider>(context).rutaActiva;

    List<dynamic> listaDatos = [];

    try {
      listaDatos = json.decode(data);
      // Ordenar por hora
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
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Calendario(),
              const Expanded(
                child: Center(
                  child: Text("No tiene rutas para esta fecha"),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
        child: Column(
          children: [
            const SizedBox(height: 5),
            Calendario(),
            const SizedBox(height: 5),
            CardDatos(listaDatos),
          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Expanded CardDatos(List<dynamic> listaDatos) {
    final size = MediaQuery.of(context).size;
    return Expanded(
      child: listaDatos.isEmpty ? Center(
        child: Text("No tiene rutas para la fecha: $FechaSeleccionada",style: const TextStyle(fontSize: 16)),
      )
      :ListView.builder(
        itemCount: listaDatos.length,
        itemBuilder: (context, index) {
          final datos = listaDatos[index];
          return Card(
            //color: const Color.fromARGB(183, 227, 248, 227), // Color de fonde del card
            elevation: 5,
            child: Column(
              children: [
                Row(
                  children: [
                    const SizedBox(width: 15),
                    SizedBox(
                      width: size.width*0.5,
                      child: Column(                      
                        crossAxisAlignment: CrossAxisAlignment.start, // alinear hacia la izquierda
                        children: [
                          const SizedBox(height: 10),
                          Texto1(datos['nombre_cliente']),
                          //const SizedBox(height: 10),
                          Texto2('ID: ${datos['numero_seguro']}'),          
                        ]
                      ),
                    ),                                     
                    SizedBox(
                      width: size.width*0.35,                      
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end, // alinear hacia la derecha
                        children: [
                          const SizedBox(height: 10),
                          Texto1('passengers: ${datos['pasajero']}'),
                          //const SizedBox(height: 10),
                          Texto2(datos['telefono']),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                  const SizedBox(width: 15),
                  Texto2('State: ${datos['estado_ruta']}'),
                  ],
                ),
                Container(
                  width: double.infinity,   // Se ajusta al ancho del contenedor padre
                  height: 2,              // Grosor de la línea
                  color: const Color.fromARGB(14, 0, 0, 0),    // Color de la línea
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
                Row(
                  children: [
                    const SizedBox(width: 15),
                    SizedBox(
                      width: size.width*0.35,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [                              
                          Texto1('Pickup'),
                          Texto2('${datos['hora']}'),
                        ]                            
                      ),
                    ),  
                    SizedBox(
                      width: size.width*0.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end, // alinear hacia la derecha
                        children: [
                          Texto2('${datos['origen']}'),
                        ]                            
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
                      width: size.width*0.35,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [                              
                          Texto1('Dropoff'),
                        ]                            
                      ),
                    ),  
                    SizedBox(
                      width: size.width*0.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end, // alinear hacia la derecha
                        children: [
                          Texto2('${datos['destino']}'),
                        ]                            
                      ),
                    ), 
                  ],
                ),
                Container(
                  width: double.infinity,   // Se ajusta al ancho del contenedor padre
                  height: 2,              // Grosor de la línea
                  color: const Color.fromARGB(14, 0, 0, 0),    // Color de la línea
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
                if(datos['estado_ruta']=='cancelado')...[
                  Row(
                    children: [
                      const SizedBox(width: 15),
                      SizedBox(
                        width: size.width*0.5,
                        child: Column(                      
                          crossAxisAlignment: CrossAxisAlignment.start, // alinear hacia la izquierda
                          children: [
                            Texto4('Trip Value'),                              
                            //Texto4('CoPay'),      
                            const SizedBox(height: 10),
                          ]
                        ),
                      ),                                     
                      SizedBox(
                        width: size.width*0.35,                      
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end, // alinear hacia la derecha
                          children: [
                            Texto4('\$${datos['total_final']}'),
                            //Texto4('-\$${datos['copay']}'), 
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ]
                else...[
                  Row(
                    children: [
                      const SizedBox(width: 15),
                      SizedBox(
                        width: size.width*0.5,
                        child: Column(                      
                          crossAxisAlignment: CrossAxisAlignment.start, // alinear hacia la izquierda
                          children: [
                            Texto3('Trip Value'),
                            const SizedBox(height: 10),
                          ]
                        ),
                      ),                                     
                      SizedBox(
                        width: size.width*0.35,                      
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end, // alinear hacia la derecha
                          children: [
                            Texto3('\$${datos['total_final']}'),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                
              ],
            ),
          );
        },
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Text Texto1(String texto) => Text(texto, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,),);
  // ignore: non_constant_identifier_names
  Text Texto2(String texto) => Text(texto, style: TextStyle(color: Colors.black),);
  // ignore: non_constant_identifier_names
  Text Texto3(String texto) => Text(texto, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),);
  // ignore: non_constant_identifier_names
  Text Texto4(String texto) => Text(texto, style: TextStyle(color: Colors.deepOrangeAccent[700], fontWeight: FontWeight.bold, fontSize: 15,decoration: TextDecoration.lineThrough));

  // ignore: non_constant_identifier_names
  TextField Calendario() {
    return TextField(
      controller: _dateController,
      decoration: InputDecoration(
        labelText: DateTime.now().toString().split(" ")[0],
        filled: true,
        prefixIcon: Icon(Icons.calendar_today, color: Colors.blue,),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue)
        ),
      ),
      readOnly: true,
      onTap: (){
        _selectDate();
       },
    );
  }

  Future<void> _selectDate() async{
    //DateTime initialDate = DateTime.tryParse(FechaSeleccionada) ?? DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context, 
      //initialDate: DateTime.now(),
      initialDate: DateTime.tryParse(FechaSeleccionada),
      firstDate: DateTime(2025), 
      lastDate: DateTime(2030), 
    );
    if(picked != null){
      final nuevaFecha = picked.toString().split(" ")[0];
      setState(() {
        _dateController.text = nuevaFecha;
        FechaSeleccionada = nuevaFecha;
      });
      // ignore: use_build_context_synchronously
      Provider.of<UsuarioProvider>(context, listen: false)
      // ignore: use_build_context_synchronously
      .RutaUsuarioFecha(FechaSeleccionada, context);
    }
  }
  
}