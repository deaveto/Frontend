import 'package:app_movil/widgets/input_decoration.dart';
import 'package:flutter/material.dart';

class CampoContrasena extends StatefulWidget {
  final TextEditingController controller;

  const CampoContrasena({Key? key, required this.controller}) : super(key: key);

  @override
  _CampoContrasenaState createState() => _CampoContrasenaState();
}

class _CampoContrasenaState extends State<CampoContrasena> {
  bool _mostrarClave = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      autocorrect: false,
      obscureText: !_mostrarClave,
      decoration: Input_Decoration.inputDecoration(
        hintext: '********',
        labeltext: 'Contraseña',
        icono: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _mostrarClave ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _mostrarClave = !_mostrarClave;
            });
          },
        ),
      ),
    );
  }
}
