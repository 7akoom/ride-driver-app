import 'package:flutter/painting.dart';

/// Colours that do not follow the light or dark theme.
abstract final class FixedColors {
  /// Behind a QR code: scanners read it dark on white, whatever the theme.
  static const Color qrPaper = Color(0xFFFFFFFF);
}
