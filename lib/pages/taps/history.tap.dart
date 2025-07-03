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
class _HystoryState extends State<Hystory> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => false; // <-- Esto fuerza la destrucción
  // ignore: prefer_final_fields
  TextEditingController _dateController = TextEditingController();
  // ignore: non_constant_identifier_names
  String FechaSeleccionada = DateTime.now().toString().split(" ")[0];

  
  @override
  void initState() {
    super.initState();
    if (_dateController.text.isNotEmpty) {
    FechaSeleccionada = _dateController.text;
    } else {
      FechaSeleccionada = DateTime.now().toString().split(' ')[0];
      _dateController.text = FechaSeleccionada;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<UsuarioProvider>(context, listen: false).RutaUsuarioFecha(FechaSeleccionada,context);      
    });
  } 
  
  @override 
  Widget build(BuildContext context) {
    super.build(context);
    final data = Provider.of<UsuarioProvider>(context).rutaActiva;
    if (data.isEmpty || data.trim() == "") {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
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
            //color: Colors.blue[300], // Color de fonde del card
            elevation: 5,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[800],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 15),
                      SizedBox(
                        width: size.width*0.5,
                        child: Column(                      
                          crossAxisAlignment: CrossAxisAlignment.start, // alinear hacia la izquierda
                          children: [
                            SizedBox(height: 10),
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
                            Texto1('Passengers: ${datos['pasajero']}'),
                            //const SizedBox(height: 10),
                            Texto2(datos['telefono']),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.blue[800],                    
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 15),                      
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color:obtenerColorEstado(datos['estado_ruta']),
                        ),                        
                        child: Texto2('   ${datos['estado_ruta']}   '),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    const SizedBox(width: 15),
                    SizedBox(
                      width: size.width*0.35,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [                              
                          Texto11('Pickup'),
                          Texto22('${datos['hora']}'),
                        ]                            
                      ),
                    ),  
                    SizedBox(
                      width: size.width*0.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end, // alinear hacia la derecha
                        children: [
                          Texto22('${datos['origen']}'),
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
                          Texto11('Dropoff'),
                        ]                            
                      ),
                    ),  
                    SizedBox(
                      width: size.width*0.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end, // alinear hacia la derecha
                        children: [
                          Texto22('${datos['destino']}'),
                        ]                            
                      ),
                    ), 
                  ],
                ),
                Container(
                  width: double.infinity,   // Se ajusta al ancho del contenedor padre
                  height: 2,              // Grosor de la línea
                  color: Color.fromARGB(14, 0, 0, 0),    // Color de la línea
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
  Text Texto1(String texto) => Text(texto, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18));

  // ignore: non_constant_identifier_names
  Text Texto2(String texto) => Text(texto, style: TextStyle(color: Colors.white, fontSize: 16));

  // ignore: non_constant_identifier_names
  Text Texto11(String texto) => Text(texto, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16));

  // ignore: non_constant_identifier_names
  Text Texto22(String texto) => Text(texto, style: TextStyle(color: Colors.black, fontSize: 16));

  // ignore: non_constant_identifier_names
  Text Texto3(String texto) => Text(texto, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16));

  // ignore: non_constant_identifier_names
  Text Texto4(String texto) => Text(texto, style: TextStyle(color: Colors.deepOrangeAccent[700], fontWeight: FontWeight.bold, fontSize: 15,decoration: TextDecoration.lineThrough));

  // ignore: non_constant_identifier_names
  TextField Calendario() {
    return TextField(
      controller: _dateController,
      decoration: InputDecoration(
        labelText: 'DATE',
        filled: true,
        prefixIcon: Icon(Icons.calendar_today, color: Colors.blue[800]),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: const Color.fromARGB(255, 0, 103, 187))
        ),
      ),
      readOnly: true,
      onTap: (){
        _selectDate();
       },
    );
  }

  Future<void> _selectDate() async{
    // ignore: no_leading_underscores_for_local_identifiers
    DateTime? _picked = await showDatePicker(
      context: context, 
      //initialDate: DateTime.now(),
      initialDate: DateTime.tryParse(FechaSeleccionada),
      firstDate: DateTime(2025), 
      lastDate: DateTime(2030), 
    );
    if(_picked != null){
      print(FechaSeleccionada);
      final nuevaFecha = _picked.toString().split(" ")[0];
      setState(() {
        _dateController.text = nuevaFecha;
        FechaSeleccionada = nuevaFecha;
      });
      // ignore: use_build_context_synchronously
      Provider.of<UsuarioProvider>(context, listen: false)
      // ignore: use_build_context_synchronously
      .RutaUsuarioFecha(FechaSeleccionada, context);
    }else{print(FechaSeleccionada);}
  }
  
  Color? obtenerColorEstado(String? estado) {
    switch (estado) {
      case 'completo':
        return Colors.green[700];
      case 'cancelado':
        return Colors.red[700];
      case null:
        return Colors.grey[200];
      default:
        return Colors.orange;
    }
  }

}