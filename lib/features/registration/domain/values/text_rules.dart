import '../../../../core/format/digits.dart';

/// Trimmed, with every run of spaces made one space.
String collapseSpaces(String input) => input.trim().split(RegExp(r'\s+')).join(' ');

/// A plate as the backend keeps it: Western digits, Latin letters in capitals, single
/// spaces. Arabic and Kurdish keyboards type Arabic-Indic digits.
String normalizePlate(String input) {
  final buffer = StringBuffer();

  for (final char in input.characters) {
    final digit = westernDigitsOnly(char);
    buffer.write(digit.isNotEmpty ? digit : char.toUpperCase());
  }

  return collapseSpaces(buffer.toString());
}

/// How many letters [text] has, the way the backend counts them (Unicode code points).
int letterCount(String text) => text.runes.length;

extension on String {
  Iterable<String> get characters => runes.map(String.fromCharCode);
}
