import 'package:flutter/material.dart';

class Input_Decoration {
  static InputDecoration  inputDecoration({
    required String hintext,
    required String labeltext,
    required Icon icono,
    Widget? suffixIcon,
  }){
    return InputDecoration(
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green, width: 2)),
      hintText: hintext,
      labelText: labeltext,
      prefixIcon: icono,
      suffixIcon: suffixIcon,
    );
  }
}