import 'package:flutter/painting.dart';

/// The usual car colours, offered as swatches when registering a car. The swatch is
/// only a picture; the colour is kept as its name, in the captain's language.
enum CarColor {
  white(Color(0xFFFFFFFF)),
  black(Color(0xFF111111)),
  silver(Color(0xFFC0C4CA)),
  gray(Color(0xFF6B7280)),
  beige(Color(0xFFD8C8A8)),
  brown(Color(0xFF7A4E2D)),
  red(Color(0xFFC62828)),
  blue(Color(0xFF1E4FA8)),
  green(Color(0xFF2E7D4F)),
  yellow(Color(0xFFF2C230));

  const CarColor(this.swatch);

  final Color swatch;
}
