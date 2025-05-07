import 'package:flutter/material.dart';

// ignore: camel_case_types
class pruebas extends StatelessWidget {
  const pruebas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [      
            Text('data'),
            Card(
              child: ExpansionTile(
                backgroundColor: Color.fromRGBO(63, 118, 238, 1), // color de fondo del desplegable
                collapsedBackgroundColor: Color.fromRGBO(38, 68, 165, 0.959), // color del desplegable
                collapsedTextColor: Color.fromRGBO(255, 255, 255, 1),
                collapsedIconColor: Colors.white,
                title: Text('Ruta'),
                subtitle: Texto1('Diego Armando Velasquez Torres'),
                children: [ViewRuta()],
              ),
            ),                                               
          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Row ViewRuta() {
    return Row(
            children: [
              Icon(
                Icons.accessible,
                color: Colors.white,
                size: 70,
              ),
              Column(
                mainAxisSize: MainAxisSize.min, // Esto hace que la Column se ajuste a su contenido
                crossAxisAlignment: CrossAxisAlignment.start, // Alineación a la izquierda
                children: [ 
                  Texto1('  Phone:  '),
                  Texto1('  Companion:  '),
                  //Texto1('date:'),
                  Texto1('  Hour:'),
                  Texto1('  Origin:  '),                  
                  Texto1('  Destination:  '), 
                  //SizedBox(height: 10),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min, // Esto hace que la Column se ajuste a su contenido
                crossAxisAlignment: CrossAxisAlignment.start, // Alineación a la izquierda
                children: [                     
                  Texto2('+57 3105576478'),
                  Texto2('1'),
                  //Texto2('03-05-2025'),
                  Texto2('13:30'),                  
                  Texto2('Bogota carrera 70c # 01 - 72'),                  
                  Texto2('Villavicencio, calle 26A #08 87'),
                ],

              )
            ],
          );
  }

  // ignore: non_constant_identifier_names
  Text Texto1(String texto) => Text(texto,style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15 ,color: const Color.fromARGB(255, 255, 255, 255)));
  // ignore: non_constant_identifier_names
  Text Texto2(String texto) => Text(texto,style: TextStyle(fontSize: 15 ,color: const Color.fromARGB(255, 255, 255, 255)));

  BoxDecoration imagen() {
    return BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/mapa1.png'),
        fit: BoxFit.fill, 
      ),
    );
  }

}