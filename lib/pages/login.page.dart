import 'package:app_movil/provider/usuario.provider.dart';
import 'package:app_movil/widgets/Campo_Contraseña.dart';
import 'package:app_movil/widgets/input_decoration.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController claveController = TextEditingController();
  bool guardarCredenciales = false;

  @override
  void initState() {
    super.initState();
    _cargarCredenciales();
  }

  Future<void> _cargarCredenciales() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool guardar = prefs.getBool('guardarCredenciales') ?? false;
    if (guardar) {
      setState(() {
        guardarCredenciales = true;
        usuarioController.text = prefs.getString('usuario') ?? '';
        claveController.text = prefs.getString('clave') ?? '';
      });
    }
  }

  Future<void> _guardarCredenciales() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (guardarCredenciales) {
      await prefs.setString('usuario', usuarioController.text);
      await prefs.setString('clave', claveController.text);
    } else {
      await prefs.remove('usuario');
      await prefs.remove('clave');
    }
    await prefs.setBool('guardarCredenciales', guardarCredenciales);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final Usuario_Login login = Usuario_Login(
      usuarioController: usuarioController,
      claveController: claveController,
    );

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [

            ContenedorAzul(size),
            ContenedorIcono(size),
            ContenedorFromularioLogin(size, context, login),
          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  SingleChildScrollView ContenedorFromularioLogin(Size size, BuildContext context, Usuario_Login login) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: size.height * 0.30),
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 30),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text('Login', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 30),
                Form(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: usuarioController,
                        autocorrect: false,
                        decoration: Input_Decoration.inputDecoration(
                          hintext: 'Nombre de usuario registrado',
                          labeltext: 'Usuario',
                          icono: const Icon(Icons.account_circle_outlined),
                        ),
                      ),
                      const SizedBox(height: 30),
                      CampoContrasena(controller: claveController),
                      const SizedBox(height: 20),

                      // Checkbox para guardar credenciales
                      Row(
                        children: [
                          Checkbox(
                            value: guardarCredenciales,
                            onChanged: (value) {
                              setState(() {
                                guardarCredenciales = value ?? false;
                              });
                            },
                          ),
                          const Text("Guardar credenciales"),
                        ],
                      ),
                      const SizedBox(height: 20),
                      MaterialButton(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        disabledColor: Colors.grey,
                        color: Colors.green[800],
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                          child: const Text('Ingresar', style: TextStyle(color: Colors.white)),
                        ),
                        onPressed: () async {
                          await _guardarCredenciales();
                          login.loginUsuario(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // ignore: non_constant_identifier_names
  SafeArea ContenedorIcono(Size size) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100)),
        //margin: EdgeInsets.symmetric(horizontal: size.height * 0.145,vertical: size.width*0.2),
        margin: EdgeInsets.symmetric(horizontal: 142,vertical: 75),
        child: Image.asset('assets/images/logo.png', width: 200, height: 150),
        //const Icon(Icons.person_pin, color: Colors.white,size: 100,),
      )
    );
  }


  // ignore: non_constant_identifier_names
  Container ContenedorAzul(Size size) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [
          Color.fromARGB(255, 0, 109, 4),
          Color.fromARGB(202, 0, 109, 4),
        ]),
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
        color: const Color.fromRGBO(255, 255, 255, 0.047),
      ),
    );
  }
}
