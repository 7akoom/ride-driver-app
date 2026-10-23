import 'package:flutter/services.dart';

import '../../../core/format/digits.dart';

/// Keeps only digits as the captain types, written as Western digits (Arabic and Kurdish
/// keyboards type Arabic-Indic ones), up to [maxLength].
class WesternDigitsFormatter extends TextInputFormatter {
  const WesternDigitsFormatter({this.maxLength});

  final int? maxLength;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = westernDigitsOnly(newValue.text);
    final max = maxLength;

    if (max != null && digits.length > max) {
      digits = digits.substring(0, max);
    }

    if (digits == newValue.text) {
      return newValue;
    }

    return TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: digits.length),
    );
  }
}
