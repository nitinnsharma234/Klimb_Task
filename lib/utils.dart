import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'device_profile_screen.dart';

getSnackBar(String message) {
  return SnackBar(

    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 2),
    margin: const EdgeInsets.only(bottom: 30.0, left: 100, right: 100),
    content: Text(
      message,
      style: const TextStyle(color: Colors.red),
      textAlign: TextAlign.center,
    ),
  );
}


Widget customTextField(
    {String? prefix,
      TextEditingController? textEditingController,
      String? label,
      IconData? suffix,
      Function(String)? validate,
      bool obscure = false,
      bool enabled = true}) {
  return TextField(
    controller: textEditingController,
    enabled: enabled,
    obscureText: obscure,
    inputFormatters:  [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
    keyboardType:   const TextInputType.numberWithOptions(decimal: true),
    textAlignVertical: TextAlignVertical.center,
    style: const TextStyle(
        color: Colors.black, fontWeight: FontWeight.w500, fontSize: 14),
    cursorColor: const Color(0xFFAEA3A5),
    decoration: InputDecoration(
      label: Center(child: Text(label!)),
      labelStyle: const TextStyle(color: Color(0xFFAEA3A5), fontSize: 14),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      filled: true,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      fillColor: Colors.grey[300],
      disabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
              width: 1, color: Color(0xFFFDFDFD), style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
              width: 1, color: Color(0xFFFDFDFD), style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(16)),
      suffixIcon: Icon(
        suffix,
        color: const Color(0xFF7B6F72),
      ),
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
              width: 1, color: Color(0xFFFDFDFD), style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(16)),
    ),
  );
}




extension MaterialColorExtension on String {
  toMaterialColor() {
    var hexColor = this.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      Color color = Color(
        int.parse("$hexColor", radix: 16),
      );

      Map<int, Color> swatch = {
        50: color.withOpacity(0.1),
        100: color.withOpacity(0.2),
        200: color.withOpacity(0.3),
        300: color.withOpacity(0.4),
        400: color.withOpacity(0.5),
        500: color.withOpacity(0.6),
        600: color.withOpacity(0.7),
        700: color.withOpacity(0.8),
        800: color.withOpacity(0.9),
        900: color.withOpacity(1.0),
      };
      return MaterialColor(int.parse("$hexColor", radix: 16), swatch);
    }
  }
}
