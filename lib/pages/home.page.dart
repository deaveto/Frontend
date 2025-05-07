import 'package:app_movil/pages/taps/four.page.dart';
import 'package:app_movil/pages/taps/history.tap.dart';
import 'package:app_movil/pages/taps/earnings.tap.dart';
import 'package:app_movil/pages/taps/my_route.tap.dart';
import 'package:flutter/material.dart';

class Home_Page extends StatelessWidget {
  const Home_Page({super.key});  
  @override
  Widget build(BuildContext context) {
    //final size =MediaQuery.of(context).size;
    return DefaultTabController(
      initialIndex: 0,
      length: 4,
      child:Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          title: const Text('One Driver', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold),),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                Color.fromRGBO(63, 118, 238, 1),
                Color.fromRGBO(38, 68, 165, 0.959),
                ]
              )
            ),
          ),          
        ),
        body: Padding(          
          padding: EdgeInsets.all(10),
          child:  Column(
            children: [
              BarraNavegacion(),
              SizedBox(height: 5),
              Expanded(child: getTabBarView())
            ],
          )
        ),
      )
    );
  }

  Container BarraNavegacion() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
          Color.fromRGBO(63, 118, 238, 1),
          Color.fromRGBO(38, 68, 165, 0.959),
          ]
        ),
        borderRadius: BorderRadius.circular(20)
      ),
      child: TabBar(
        indicator: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255), // Color del indicador de selección
          borderRadius: BorderRadius.circular(20),                    
        ),
        indicatorPadding: EdgeInsets.symmetric(vertical: 4,horizontal:-18), // Espacio del indicador cuadrado (entre mas negativo, mas grande es)
        labelColor: const Color.fromRGBO(38, 68, 165, 0.959), // color del icono cuando lo selecciona
        unselectedLabelColor: const Color.fromARGB(255, 255, 255, 255),//color de los iconos
        tabs: const [
          Tab(icon: Icon(Icons.add_location_alt_sharp), text: 'my route',),
          Tab(icon: Icon(Icons.account_balance_wallet_outlined),text: 'History',),
          Tab(icon: Icon(Icons.attach_money_outlined), text: 'earnings',),
          Tab(icon: Icon(Icons.cloud_outlined),text: 'Admin',),
        ],
      ),
    );
  }

  TabBarView getTabBarView() {
    return TabBarView(
        children: <Widget>[
          Two_Tap(),          
          One_Tap(),          
          Three_Tap(),
          Four_Tap(),
        ],
      );
  }  
}
