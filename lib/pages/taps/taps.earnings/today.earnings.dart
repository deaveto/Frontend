import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:app_movil/provider/usuario.provider.dart';
import 'package:provider/provider.dart';

// ignore: camel_case_types
class today extends StatefulWidget {
  const today({super.key});

  @override
  State<today> createState() => _todayState();
}

// ignore: camel_case_types
class _todayState extends State<today> {
  //String FechaActual = new DateTime.now().toString().split(" ")[0];
  double totalValorPago = 0.0;
  double totalCommission = 0.0;
  double totalCopay = 0.0;
  double totalTechFee = 0.0;
  double totalTolls = 0.0;
  double totalPayout = 0.0;
  bool cargado = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<UsuarioProvider>(context, listen: false).RutaUsuarioActivas(context);   
      procesarDatos();   
    });
  } 

  void procesarDatos() {
    final data = Provider.of<UsuarioProvider>(context, listen: false).rutaActiva;
    
    try {
      List<dynamic> listaDatos = json.decode(data);
      double sumaValor = 0.0;
      double sumaCommission = 0.0;
      double sumaCopay = 0.0;
      double sumaTech = 0.0;
      double sumaTolls = 0.0;
      double sumaPayout = 0.0;

      for (var item in listaDatos) {
        if(item["estado_ruta"] == "completo"){
          sumaValor += double.tryParse(item["valor_pago"].toString()) ?? 0.0;
          sumaCommission += double.tryParse(item["commission"].toString()) ?? 0.0;
          sumaCopay += double.tryParse(item["copay"].toString()) ?? 0.0;
          sumaTech += double.tryParse(item["tech_fee"].toString()) ?? 0.0;
          sumaTolls += double.tryParse(item["tolls"].toString()) ?? 0.0;
          sumaPayout = sumaValor-sumaCommission-sumaCopay-sumaTech+sumaTolls;
        }       
      }
      sumaPayout = sumaValor-sumaCommission-sumaCopay-sumaTech+sumaTolls;
      setState(() {
        totalValorPago = sumaValor;
        totalCommission = sumaCommission;
        totalCopay = sumaCopay;
        totalTechFee = sumaTech;
        totalTolls = sumaTolls;
        totalPayout = sumaPayout;
        cargado = true;
      });
    } catch (e) {
      Center(
        child: Text("No tiene rutas para esta fecha"),
      );
      print('Error al procesar datos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final data = Provider.of<UsuarioProvider>(context, listen: false).rutaActiva;
    if (data.isEmpty || data.trim() == "") {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    try{
      return Scaffold(
        backgroundColor: const Color.fromARGB(34, 0, 0, 0),
        body: Center(
          child: Column(
            children: [ 
              SizedBox(height: 20),             
              Card(
                elevation: 15,
                child: SizedBox(
                  width: size.width*1.0,
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Text("\$ ${totalPayout.toStringAsFixed(2)}",style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [                           
                          Eficiencia('20','Dropped Off Trips'),
                          Eficiencia('0','Failed Trips'),
                          Eficiencia('87%','Efficiency'),
                          //SizedBox(width: size.width*0.15),                        
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(width: size.width*0.08),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start, // alinear hacia la izquierda
                            children: [
                              SizedBox(height: 10),
                              Text('Trip Value', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                              SizedBox(height: 8),
                              Text('CoPay', style: TextStyle(color: Colors.red[900], fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text('Commission', style: TextStyle(color: Colors.red[900], fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text('Tech Fee', style: TextStyle(color: Colors.red[900],fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text('Tolls', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(height: 15),
                            ],                            
                          ),
                          SizedBox(width: size.width*0.5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end, // alinear hacia la derecha
                            children: [                              
                              SizedBox(height: 10),
                              Text('\$ ${totalValorPago.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text('-\$ ${totalCopay.toStringAsFixed(2)}', style: TextStyle(color: Colors.red[900], fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text('-\$ ${totalCommission.toStringAsFixed(2)}', style: TextStyle(color: Colors.red[900], fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text('-\$ ${totalTechFee.toStringAsFixed(2)}', style: TextStyle(color: Colors.red[900],fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text('\$ ${totalTolls.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(height: 15),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(97, 154, 198, 231),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(width: size.width*0.06),
                            Text('Payout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(width: size.width*0.58),
                            Text('\$${totalPayout.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

    }catch(e){
      return Container(
        color: Colors.white,
        child: Center(child: Text('No tienes rutas activas para esta fecha')),
      );
    }
  }

  // ignore: non_constant_identifier_names
  Expanded Eficiencia(String cantidad, String valor) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          border: Border.all(color: const Color.fromARGB(255, 0, 63, 114)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10),  
            Text(cantidad),
            Text(valor),
            SizedBox(height: 10), 
          ],
        ),
        //child: Text(valor),
      ),
    );
  }
}