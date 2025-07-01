import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:app_movil/provider/usuario.provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartColumData {
  final String dia;
  final double valor;
  ChartColumData(this.dia, this.valor);
}

// ignore: camel_case_types
class weekly extends StatefulWidget {
  const weekly({super.key});

  @override
  State<weekly> createState() => _weeklyState();
}

// ignore: camel_case_types
class _weeklyState extends State<weekly> {

  String formato = 'yyyy-MM-dd';
  String? FechaLunes ;
  String? FechaMartes;
  String? FechaMiercoles;
  String? FechaJueves;
  String? FechaViernes;
  String? FechaSabado;
  String? FechaDomingo;

  double sumaLunes = 0.0;
  double sumaMartes = 0.0;
  double sumaMiercoles = 0.0;
  double sumaJueves = 0.0;
  double sumaViernes = 0.0;
  double sumaSabado = 0.0;
  double sumaDomingo = 0.0;
  double sumaSemana = 0.0;

  List<double> SumaDescuentos = [0.0,0.0,0.0,0.0,0.0];

  bool cargado = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<UsuarioProvider>(context, listen: false).obtenerSemanaActual(context);    
      obtenerSemanaActual();
    });
  }

  void obtenerSemanaActual() {
    final data = Provider.of<UsuarioProvider>(context, listen: false).rutaActiva;
    try{
      DateTime hoy = DateTime.now();
      List<dynamic> listaDatos = json.decode(data);

      int diferenciaLunes = hoy.weekday - DateTime.monday;
      int diferenciaMartes = hoy.weekday - DateTime.tuesday;
      int diferenciaMiercoles = hoy.weekday - DateTime.wednesday;
      int diferenciaJueves = hoy.weekday - DateTime.thursday;
      int diferenciaViernes = hoy.weekday - DateTime.friday;
      int diferenciaSabado = hoy.weekday - DateTime.saturday;
      int diferenciaDomingo = DateTime.sunday - hoy.weekday;

      DateTime lunes = hoy.subtract(Duration(days: diferenciaLunes));
      DateTime martes = hoy.subtract(Duration(days: diferenciaMartes));
      DateTime miercoles = hoy.subtract(Duration(days: diferenciaMiercoles));
      DateTime jueves = hoy.subtract(Duration(days: diferenciaJueves));
      DateTime viernes = hoy.subtract(Duration(days: diferenciaViernes));
      DateTime sabado = hoy.subtract(Duration(days: diferenciaSabado));
      DateTime domingo = hoy.add(Duration(days: diferenciaDomingo));

      FechaLunes = DateFormat(formato).format(lunes);
      FechaMartes = DateFormat(formato).format(martes);
      FechaMiercoles = DateFormat(formato).format(miercoles);
      FechaJueves = DateFormat(formato).format(jueves);
      FechaViernes = DateFormat(formato).format(viernes);
      FechaSabado = DateFormat(formato).format(sabado);
      FechaDomingo = DateFormat(formato).format(domingo);

      // ignore: non_constant_identifier_names
      List<double> SumaDiasSemana = [0.0,0.0,0.0,0.0,0.0,0.0,0.0];

      double sumaSemanaT = 0.0;

      for(var item in listaDatos){
        SumaDescuentos[0] += double.tryParse(item["valor_pago"].toString()) ?? 0.0;
        SumaDescuentos[1] += double.tryParse(item["commission"].toString()) ?? 0.0;
        SumaDescuentos[2] += double.tryParse(item["copay"].toString()) ?? 0.0;
        SumaDescuentos[3] += double.tryParse(item["tech_fee"].toString()) ?? 0.0;
        SumaDescuentos[4] += double.tryParse(item["tolls"].toString()) ?? 0.0;

        if((item['estado_ruta'] == "completo")&&(item['fecha_inicio'] == FechaLunes)){
          SumaDiasSemana[0] += double.tryParse(item["total_final"].toString()) ?? 0.0;
        }

        if((item['estado_ruta'] == "completo")&&(item['fecha_inicio'] == FechaMartes)){
          SumaDiasSemana[1] += double.tryParse(item["total_final"].toString()) ?? 0.0;
        }

        if((item['estado_ruta'] == "completo")&&(item['fecha_inicio'] == FechaMiercoles)){
          SumaDiasSemana[2] += double.tryParse(item["total_final"].toString()) ?? 0.0;
        }

        if((item['estado_ruta'] == "completo")&&(item['fecha_inicio'] == FechaJueves)){
          SumaDiasSemana[3] += double.tryParse(item["total_final"].toString()) ?? 0.0;
        }
          if((item['estado_ruta'] == "completo")&&(item['fecha_inicio'] == FechaViernes)){
          SumaDiasSemana[4] += double.tryParse(item["total_final"].toString()) ?? 0.0;
        }

        if((item['estado_ruta'] == "completo")&&(item['fecha_inicio'] == FechaSabado)){
          SumaDiasSemana[5] += double.tryParse(item["total_final"].toString()) ?? 0.0;
        }
        if((item['estado_ruta'] == "completo")&&(item['fecha_inicio'] == FechaDomingo)){
          SumaDiasSemana[6] += double.tryParse(item["total_final"].toString()) ?? 0.0;
        }
      }      
      sumaSemanaT = SumaDiasSemana[0] + SumaDiasSemana[1] + SumaDiasSemana[2] + SumaDiasSemana[3] + SumaDiasSemana[4] + SumaDiasSemana[5] + SumaDiasSemana[6]; 

      setState(() {       
        sumaLunes = SumaDiasSemana[0];
        sumaMartes = SumaDiasSemana[1];
        sumaMiercoles = SumaDiasSemana[2];
        sumaJueves = SumaDiasSemana[3];
        sumaViernes = SumaDiasSemana[4];
        sumaSabado =SumaDiasSemana[5];
        sumaDomingo = SumaDiasSemana[6];
        sumaSemana = sumaSemanaT;
        cargado = true;
      });
    }catch(e){
      Center(
        child: Text("No tiene rutas para esta fecha"),
      );
      print('Error al procesar datos: $e');
    }    
  }

  @override
  Widget build(BuildContext context) {
    final size =MediaQuery.of(context).size;
    final data = Provider.of<UsuarioProvider>(context, listen: false).rutaActiva;
    if (data.isEmpty || data.trim() == "") {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    try{
      
      List<ChartColumData> chartData = <ChartColumData> [
        ChartColumData('Mon', sumaLunes),
        ChartColumData('Tue', sumaMartes),
        ChartColumData('Wed', sumaMiercoles),
        ChartColumData('Thu', sumaJueves),
        ChartColumData('Fri', sumaViernes),
        ChartColumData('Sat', sumaSabado),
        ChartColumData('Sun', sumaDomingo),
      ];

      return Scaffold(
        body: SingleChildScrollView(        
          child: Container(
            color: const Color.fromARGB(50, 0, 0, 0),
            height: size.height,
            width: size.width*1,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child:Padding(
                      padding: EdgeInsets.all(0.0),
                      child: Column(
                        children: [
                          SizedBox(height: 10.0),
                          SizedBox(height: size.height*0.25,child: GraficaSemana(chartData)),
                          SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [                           
                              Eficiencia('20','Dropped Off Trips'),
                              Eficiencia('0','Failed Trips'),
                              Eficiencia('87%','Efficiency'),                        
                            ],
                          ),
                          Row(
                        children: [
                          SizedBox(width: size.width*0.08),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start, // alinear hacia la izquierda
                            children: [
                              SizedBox(height: 10),
                              Text('Trip Value weekday', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                              SizedBox(height: 8),
                              Text('CoPay weekday', style: TextStyle(color: Colors.red[900], fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text('Commission weekday', style: TextStyle(color: Colors.red[900], fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text('Tech Fee weekday', style: TextStyle(color: Colors.red[900],fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text('Tolls weekday', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              //SizedBox(height: 15),
                            ],                            
                          ),
                          SizedBox(width: size.width*0.28),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end, // alinear hacia la derecha
                            children: [                              
                              SizedBox(height: 10),
                              Text('\$ ${SumaDescuentos[0].toStringAsFixed(2)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text('-\$ ${SumaDescuentos[1].toStringAsFixed(2)}', style: TextStyle(color: Colors.red[900], fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text('-\$ ${SumaDescuentos[2].toStringAsFixed(2)}', style: TextStyle(color: Colors.red[900], fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text('-\$ ${SumaDescuentos[3].toStringAsFixed(2)}', style: TextStyle(color: Colors.red[900],fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text('\$ ${SumaDescuentos[4].toStringAsFixed(2)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                          SizedBox(height: 15),
                          Container(
                            padding: EdgeInsets.all(8),
                            margin: EdgeInsets.all(0),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(97, 154, 198, 231),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(width: size.width*0.06),
                                Text('Payout weekday', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                SizedBox(width: size.width*0.37),
                                Text('\$${sumaSemana.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
  SfCartesianChart GraficaSemana(List<ChartColumData> chartData) {
    return SfCartesianChart(
      
      plotAreaBackgroundColor: Colors.transparent,// color de fondo del plana de la grafica
      margin: EdgeInsets.all(0),
       borderColor: Colors.transparent,
      borderWidth: 10,//grosor del borde de plano
      plotAreaBorderWidth: 0,
      enableSideBySideSeriesPlacement: false,

      primaryXAxis: CategoryAxis(
        axisLine: AxisLine(width: 0),
        majorGridLines: MajorGridLines(color: Colors.transparent,width: 0),
        majorTickLines: MajorTickLines(width: 0),
        crossesAt: 0,
        labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)), // ajustar tamaño si se ven apelmazadas
      ),

      primaryYAxis: NumericAxis(
        axisLine: AxisLine(width: 0),
        majorGridLines: MajorGridLines(color: Colors.transparent,width: 0),
        plotOffset: 22, 
        labelFormat: r'${value}',
        isInversed: false, minimum: 0, maximum: 200, interval: 100,
      ),

      series: <CartesianSeries> [
        ColumnSeries<ChartColumData,String>(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20), 
            bottomRight: Radius.circular(20),
          ),
          dataSource: [
            ChartColumData('Mon', 200),
            ChartColumData('Tue', 200),
            ChartColumData('Wed', 200),
            ChartColumData('Thu', 200),
            ChartColumData('Fri', 200),
            ChartColumData('Sat', 200),
            ChartColumData('Sun', 200),
          ],
          width: 0.5,
          color: const Color.fromARGB(55, 0, 0, 0),
          xValueMapper: (ChartColumData data, _)=> data.dia,                               
          yValueMapper: (ChartColumData data, _) => data.valor,                              
        ),
        ColumnSeries<ChartColumData,String>(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20), 
            bottomRight: Radius.circular(20),
          ),
          dataSource: chartData,
          width: 0.5,
          color: Colors.blue[800],
          xValueMapper: (ChartColumData data, _)=> data.dia,                               
          yValueMapper: (ChartColumData data, _) => data.valor,
        )
      ],
    );
  }    

  // ignore: non_constant_identifier_names
  Expanded Eficiencia(String cantidad, String valor) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(4),
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



