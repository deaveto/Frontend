import 'dart:convert';

import 'package:app_movil/pages/taps.user/availability.page.user.dart';
import 'package:app_movil/pages/taps.user/profile.page.user.dart';
import 'package:app_movil/pages/taps.user/security.page.user.dart';
import 'package:app_movil/pages/taps/Avai_Trip.page.dart';
import 'package:app_movil/pages/taps/history.tap.dart';
import 'package:app_movil/pages/taps/earnings.tap.dart';
import 'package:app_movil/pages/taps/my_route.tap.dart';
import 'package:app_movil/provider/datos.personales.provider.dart';
import 'package:app_movil/provider/login.provider.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';

class Home_Page extends StatefulWidget {
  const Home_Page({super.key});

  @override
  State<Home_Page> createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<ProfileDatos>(context, listen: false).ProfileDatosPersonales(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<ProfileDatos>(context).DatoPersonal;
    final token = Provider.of<AuthProvider>(context, listen: false).accessToken;
    // Verificar si el contenido está vacío o inválido antes de hacer decode
      if (token == null || JwtDecoder.isExpired(token)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, 'login');
        });
      }
      if (data.isEmpty || data.trim() == "") {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
    try{
      final size =MediaQuery.of(context).size;
      final decoded = json.decode(data);
    
      return DefaultTabController(
        initialIndex: 0,
        length: 4,
        child:Scaffold(
          backgroundColor: Colors.green[900],
          //drawerScrimColor: Color.fromRGBO(38, 68, 165, 0.959),
          appBar: AppBar(
            title: const Text('One Driver', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold),),
            iconTheme: IconThemeData(color: Colors.white), // Cambia el color de iconos
            flexibleSpace: Container(
              decoration: BoxDecoration(
                color: Colors.green[900],
              ),
            ),          
          ),
          drawer: MenuLateral(decoded, context),
          body: Padding(          
            padding: EdgeInsets.all(0),
            child:  Column(
              children: [
                BarraNavegacion(size.width),
                SizedBox(height: 8),
                Expanded(child: getTabBarView())
              ],
            )
          ),
        )
      );
    }catch(e){
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
  }

  // ignore: non_constant_identifier_names
  NavigationDrawer MenuLateral(decoded, BuildContext context) {
    return NavigationDrawer(
      backgroundColor: Colors.white,
      tilePadding: EdgeInsetsGeometry.infinity,
      children: [
        Padding(padding: EdgeInsets.all(0)),
        Column(
          children: [
            Container(
              color: Colors.green[700],
              padding: EdgeInsets.only(top:MediaQuery.of(context).padding.top),//
              child: Center(
                child: Column(
                  children: [
                    CircleAvatar(radius: 80, backgroundImage: NetworkImage('https://cdn.pixabay.com/photo/2022/11/11/19/44/siberian-husky-7585704_1280.jpg')),
                    SizedBox(height: 5),
                    Text(decoded["first_name"],style: TextStyle(fontSize: 25, color: Colors.white)),
                    Text(decoded["email"],style: TextStyle(fontSize: 15 , color: Colors.white)),
                    SizedBox(height: 20)
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.home, color: Color.fromARGB(255, 0, 119, 4),size: 30),
              title: const Text('Home'),
              onTap: () =>
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const Home_Page(),
                ))
            ),
            ListTile(
              leading: const Icon(Icons.location_history, color: Color.fromARGB(255, 0, 119, 4),size: 30),
              title: const Text('Profile'),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const Profile(),
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month, color: Color.fromARGB(255, 0, 119, 4),size: 30),
              title: const Text('Availability'),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const availability(),
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.security, color: Color.fromARGB(255, 0, 119, 4),size: 30),
              title: const Text('Security'),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const security(),
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Color.fromARGB(255, 0, 119, 4),size: 30),
              title: const Text('Logout'),
              onTap: () async {
                final bool? confirmar = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    title: const Text('Log out'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Log out'),
                      ),
                    ],
                  ),
                );

                if (confirmar == true) {
                  Provider.of<AuthProvider>(context, listen: false).logout(context);
                }
              },
            )
          ],
        ),
        const Text('data',style: TextStyle(color: Colors.white),)
      ]
    );
  }
  // ignore: non_constant_identifier_names
  Container BarraNavegacion(size) {
    return Container(
      height: 46,
      width: size*0.94,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20)
      ),
      child: TabBar(
        indicator: BoxDecoration(
          color: Colors.blue[800], // Color del indicador de selección
          borderRadius: BorderRadius.circular(20),                    
        ),
        indicatorPadding: EdgeInsets.symmetric(vertical: 4,horizontal:-15), // Espacio del indicador cuadrado (entre mas negativo, mas grande es)
        labelColor: Colors.white, // color del icono cuando lo selecciona
        unselectedLabelColor: Colors.green[900],//color de los iconos
        dividerHeight: -1, // se coloca el -1 para eliminar la linea de divición
        tabs: const [
          Tab(text: 'my route', ),
          Tab(text: 'History',),
          Tab(text: 'Earnings',),
          Tab(text: 'Avai. Trip',),
        ],
      ),
    );
  }

  TabBarView getTabBarView() {
    return TabBarView(
        children: <Widget>[
          MyRoute(),          
          Hystory(),          
          earnings(),
          Avai_Trip(),
        ],
      );
  }

}

/*
// ignore: camel_case_types
class Home_Page extends StatelessWidget {
  const Home_Page({super.key});  

  @override
  Widget build(BuildContext context) {

    final size =MediaQuery.of(context).size;
    
    return DefaultTabController(
      initialIndex: 0,
      length: 4,
      child:Scaffold(
        backgroundColor: Colors.green[900],
        //drawerScrimColor: Color.fromRGBO(38, 68, 165, 0.959),
        appBar: AppBar(
          title: const Text('One Driver', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold),),
          iconTheme: IconThemeData(color: Colors.white), // Cambia el color de iconos
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: Colors.green[900],
            ),
          ),          
        ),
        drawer: MenuLateral(context),
        body: Padding(          
          padding: EdgeInsets.all(0),
          child:  Column(
            children: [
              BarraNavegacion(size.width),
              SizedBox(height: 8),
              Expanded(child: getTabBarView())
            ],
          )
        ),
      )
    );
  }

  // ignore: non_constant_identifier_names
  NavigationDrawer MenuLateral(BuildContext context) {
    return NavigationDrawer(
      backgroundColor: Colors.white,
      tilePadding: EdgeInsetsGeometry.infinity,
      children: [
        Padding(padding: EdgeInsets.all(0)),
        Column(
          children: [
            Container(
              color: Colors.green[700],
              padding: EdgeInsets.only(top:MediaQuery.of(context).padding.top),//
              child: Center(
                child: Column(
                  children: [
                    CircleAvatar(radius: 80, backgroundImage: NetworkImage('https://cdn.pixabay.com/photo/2022/11/11/19/44/siberian-husky-7585704_1280.jpg')),
                    SizedBox(height: 5),
                    Text('Orion David',style: TextStyle(fontSize: 25, color: Colors.white)),
                    Text('Orion@abs.com',style: TextStyle(fontSize: 16, color: Colors.white)),
                    SizedBox(height: 20)
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.home, color: Color.fromARGB(255, 0, 119, 4),size: 30),
              title: const Text('Home'),
              onTap: () =>
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const Home_Page(),
                ))
            ),
            ListTile(
              leading: const Icon(Icons.location_history, color: Color.fromARGB(255, 0, 119, 4),size: 30),
              title: const Text('Profile'),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const Profile(),
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month, color: Color.fromARGB(255, 0, 119, 4),size: 30),
              title: const Text('Availability'),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const availability(),
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.security, color: Color.fromARGB(255, 0, 119, 4),size: 30),
              title: const Text('Security'),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const security(),
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Color.fromARGB(255, 0, 119, 4),size: 30),
              title: const Text('Logout'),
              onTap: () async {
                final bool? confirmar = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    title: const Text('Log out'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Log out'),
                      ),
                    ],
                  ),
                );

                if (confirmar == true) {
                  Provider.of<AuthProvider>(context, listen: false).logout(context);
                }
              },
            )
          ],
        ),
        const Text('data',style: TextStyle(color: Colors.white),)
      ]
    );
  }

  // ignore: non_constant_identifier_names
  Container BarraNavegacion(size) {
    return Container(
      height: 46,
      width: size*0.94,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20)
      ),
      child: TabBar(
        indicator: BoxDecoration(
          color: Colors.blue[800], // Color del indicador de selección
          borderRadius: BorderRadius.circular(20),                    
        ),
        indicatorPadding: EdgeInsets.symmetric(vertical: 4,horizontal:-15), // Espacio del indicador cuadrado (entre mas negativo, mas grande es)
        labelColor: Colors.white, // color del icono cuando lo selecciona
        unselectedLabelColor: Colors.green[900],//color de los iconos
        dividerHeight: -1, // se coloca el -1 para eliminar la linea de divición
        tabs: const [
          //Tab(icon: Icon(Icons.add_location_alt_sharp), text: 'my route', ),
          //Tab(icon: Icon(Icons.account_balance_wallet_outlined),text: 'History',),
          //Tab(icon: Icon(Icons.attach_money_outlined), text: 'Earnings',),
          //Tab(icon: Icon(Icons.account_circle_outlined),text: 'Profile',),
          Tab(text: 'my route', ),
          Tab(text: 'History',),
          Tab(text: 'Earnings',),
          Tab(text: 'Avai. Trip',),
        ],
      ),
    );
  }

  TabBarView getTabBarView() {
    return TabBarView(
        children: <Widget>[
          MyRoute(),          
          Hystory(),          
          earnings(),
          Avai_Trip(),
        ],
      );
  }  
}
*/