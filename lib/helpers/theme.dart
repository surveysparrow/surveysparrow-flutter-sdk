import 'package:flutter/material.dart';

convertRgbToColor(String colorToConvert, opacity) {
  if (colorToConvert.contains("#")) {
    String color = colorToConvert.replaceAll('#', '0xff');
    return Color(int.parse(color));
  }
  var convertedString = colorToConvert
      .substring(4, colorToConvert.length - 1)
      .replaceAll(RegExp(' +'), ' ')
      .split(',');
  if (convertedString.length < 3) {
    return Color.fromRGBO(255, 255, 255, opacity);
  }
  return Color.fromRGBO(int.parse(convertedString[0]),
      int.parse(convertedString[1]), int.parse(convertedString[2]), opacity);
}


Color darkenColor(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}