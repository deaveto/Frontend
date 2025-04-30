import 'package:app_movil/provider/usuario.provider.dart';
import 'package:app_movil/widgets/Campo_Contrase%C3%B1a.dart';
import 'package:app_movil/widgets/input_decoration.dart';
import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final size =MediaQuery.of(context).size;
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            //contenedor de color azul gradiante
            ContenedorAzul(size),
            //contenedor del icono
            ContenedorIcono(),
            //contenedor de login
            ContenedorFromularioLogin(size, context)
          ],
        ),
      ),
    );
  }
 
  // ignore: non_constant_identifier_names
  SingleChildScrollView ContenedorFromularioLogin(Size size, BuildContext context) {
    final TextEditingController usuarioController = TextEditingController();
    final TextEditingController claveController = TextEditingController();
    final Usuario_Login login = Usuario_Login(
      usuarioController: usuarioController,
      claveController: claveController,
    );
    return SingleChildScrollView(
      child: Column(
              children: [
                SizedBox(height: size.height * 0.37),
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  width: double.infinity,
                  //height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                        color:Colors.black12,
                        blurRadius: 15,
                        offset: Offset(0 , 5),
                      )
                    ]
                  ),
                  //contenedor del login
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Text('Login', style: Theme.of(context).textTheme.headlineMedium),
                      SizedBox(height: 30,),
                      Form(
                        child: Column(
                          children: [
                            TextFormField(
                              controller: usuarioController,
                              autocorrect: false,
                              decoration: Input_Decoration.inputDecoration(
                                hintext: 'Nombre de ususario registrado', 
                                labeltext: 'Usuario', 
                                icono: Icon(IconData(0xee35, fontFamily: 'MaterialIcons')),
                              ),
                            ),
                            SizedBox(height: 30),
                            CampoContrasena(controller: claveController),
                            SizedBox(height: 30),
                            MaterialButton(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              disabledColor: Colors.grey,
                              color:const Color.fromARGB(255, 12, 112, 194),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 80,vertical: 15),
                                child: Text('Ingresar',style: TextStyle(color: Colors.white)),
                              ),
                              onPressed: () {
                                login.loginUsuario(context);
                              },
                            )      
                          ],
                        ),
                      )
                    ],
                  ),
                ), 
                // Texto de crear cuenta
                SizedBox(height: 50),    
                Text('Crear una cuenta', style:TextStyle(fontSize:18, fontWeight: FontWeight.bold))       
              ],
            ),
    );
  }

  // ignore: non_constant_identifier_names
  SafeArea ContenedorIcono() {
    return SafeArea(
            child: Container( 
              margin: EdgeInsets.only(top:80),
              width: double.infinity,
              child: Icon(
                Icons.person_pin, 
                color:Colors.white,
                size: 100,
                ),
            ),
          );
  }

  // ignore: non_constant_identifier_names
  Container ContenedorAzul(Size size) {
    return Container( 
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Color.fromRGBO(38, 67, 165, 1),
          Color.fromRGBO(63, 118, 238, 1),
        ])
      ),
      width: double.infinity,
      height: size.height * 0.4,
      child: Stack(
        children: [
          Positioned(top: 110, left: 60, child: Burbuja(95)),
          Positioned(top: -40, left: -30, child: Burbuja(150)),
          Positioned(top: -50, right: -20, child: Burbuja(100)),
          Positioned(bottom: -50, left: -15, child: Burbuja(200)),
          Positioned(bottom: 90, right: 20, child: Burbuja(150)),
          Positioned(bottom: 40, right: 20, child: Burbuja(90)),
          Positioned(top: -5, right: 120, child: Burbuja(100)),
          Positioned(top: 200, left: 200, child: Burbuja(60)),
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Container Burbuja(double radio) {
    return Container(      
      width: radio,
      height: radio,
      decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radio),
      color: Color.fromRGBO(255, 255, 255, 0.047)),
    );
  }
}
