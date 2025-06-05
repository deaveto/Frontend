import 'package:app_movil/pages/taps/taps.earnings/today.earnings.dart';
import 'package:app_movil/pages/taps/taps.earnings/weekly.earnings.dart';
import 'package:app_movil/provider/usuario.provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: camel_case_types
class earnings extends StatefulWidget {
  const earnings({super.key});
  @override
  State<earnings> createState() => _earningsState();
}

// ignore: camel_case_types
class _earningsState extends State<earnings> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<UsuarioProvider>(context, listen: false).RutaUsuarioActivas(context);      
    });
  }
  @override
  Widget build(BuildContext context) {
    //return const Placeholder();
    final size =MediaQuery.of(context).size;
    final data = Provider.of<UsuarioProvider>(context).rutaActiva;

    try{
      //List<dynamic> listaDatos = json.decode(data);
      return DefaultTabController(
        initialIndex: 0,
        length: 2, 
        child: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(0),
            child: Column(
              children: [
                BarraNavegacion(size.width),
                getTabBarView()
              ],
            ),
          ),
        ),
      );
    }catch(e){return Center(child: Text(data));}


  }

  Expanded getTabBarView() {
    return Expanded(
      child: TabBarView(
        children: [
          today(),
          weekly(),
        ]
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Container BarraNavegacion(size) {
    return Container(
      height: 30,
      width: size*1.0,
      decoration: BoxDecoration(
        color: Colors.green[900],
        //borderRadius: BorderRadius.circular(16)
      ),
      child: TabBar(
        indicatorPadding: EdgeInsets.symmetric(vertical: 2,horizontal:-60), // Espacio del indicador cuadrado (entre mas negativo, mas grande es)
        indicatorColor: Colors.white,
        labelColor: const Color.fromARGB(245, 255, 255, 255), // color del icono cuando lo selecciona
        unselectedLabelColor: const Color.fromARGB(255, 255, 255, 255),//color de los iconos
        dividerHeight: -1, // se coloca el -1 para eliminar la linea de divición
        tabs: const [
          Tab(text: 'Today', ),
          Tab(text: 'Weekly',),
        ],
      ),
    );
  }

}
