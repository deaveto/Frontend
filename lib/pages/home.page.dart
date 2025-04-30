import 'package:app_movil/pages/taps/one.tap.dart';
import 'package:app_movil/pages/taps/three.tap.dart';
import 'package:app_movil/pages/taps/two.tap.dart';
import 'package:flutter/material.dart';

class Home_Page extends StatelessWidget {
  const Home_Page({super.key});  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
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
          bottom: getTabBar(),
        ),
        body: getTabBarView(),
      ),
    );
  }
  TabBar getTabBar() {
    return TabBar(
      indicatorColor:Colors.white, // Color del indicador de selección
      indicator: BoxDecoration(
        color: const Color.fromARGB(51, 255, 255, 255),
        borderRadius: BorderRadius.circular(10),
      ),
      indicatorPadding: EdgeInsets.symmetric(horizontal:-60), // Espacio del indicador cuadrado (entre mas negativo, mas grande es)
      labelColor: const Color.fromRGBO(255, 255, 255, 1), // color del icono cuando lo selecciona
      unselectedLabelColor: const Color.fromARGB(255, 158, 157, 157),//color de los iconos
      
      tabs: const <Widget>[
        Tab(icon: Icon(Icons.cloud_outlined)),
        Tab(icon: Icon(Icons.beach_access_sharp)),
        Tab(icon: Icon(Icons.brightness_5_sharp)),
      ],
    );
  }

  TabBarView getTabBarView() {
    return TabBarView(
        children: <Widget>[
          One_Tap(),
          Two_Tap(),
          Three_Tap(),
        ],
      );
  }  
}
