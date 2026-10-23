import '../../../../core/format/digits.dart';

enum DocumentNumberProblem { missing, invalid }

/// A document's number as the backend accepts it: 3 to 50 letters, digits, spaces,
/// '-' or '/'. Arabic-Indic digits are written as Western digits.
abstract final class DocumentNumber {
  static final RegExp _shape = RegExp(r'^[\p{L}\p{N} /-]{3,50}$', unicode: true);

  static String clean(String typed) {
    final buffer = StringBuffer();

    for (final rune in typed.runes) {
      final char = String.fromCharCode(rune);
      final digit = westernDigitsOnly(char);
      buffer.write(digit.isNotEmpty ? digit : char);
    }

    return buffer.toString().trim().split(RegExp(r'\s+')).join(' ');
  }

  static DocumentNumberProblem? check(String typed) {
    final value = clean(typed);

    if (value.isEmpty) {
      return DocumentNumberProblem.missing;
    }

    return _shape.hasMatch(value) ? null : DocumentNumberProblem.invalid;
  }
}
