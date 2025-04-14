import 'package:flutter/material.dart';

class Input_Decoration {
  static InputDecoration  inputDecoration({
    required String hintext,
    required String labeltext,
    required Icon icono
  }){
    return InputDecoration(
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color:const Color.fromARGB(255, 46, 93, 223))),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: const Color.fromARGB(255, 46, 93, 223), width: 2)),
      hintText: hintext,
      labelText: labeltext,
      prefixIcon: icono,
    );
  }

}