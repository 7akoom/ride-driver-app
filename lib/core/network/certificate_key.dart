import 'dart:convert';

import 'package:crypto/crypto.dart';

/// The pin of an X.509 certificate's key: the SHA-256 of its SubjectPublicKeyInfo, in
/// base64 (the form `openssl ... | openssl dgst -sha256 -binary | base64` prints).
/// Null when [der] is not a certificate.
///
/// The key, not the whole certificate, is pinned: a certificate renewed with the same
/// key (certbot --reuse-key) keeps its pin.
String? keyPinOf(List<int> der) {
  final key = subjectPublicKeyInfo(der);

  return key == null ? null : base64.encode(sha256.convert(key).bytes);
}

/// The SubjectPublicKeyInfo of a certificate in DER, as its own DER bytes; null when
/// [der] is not a certificate.
List<int>? subjectPublicKeyInfo(List<int> der) {
  try {
    final certificate = _Node(der, 0);
    final tbs = certificate.children().first;
    final fields = tbs.children();
    // [0] version is optional; then serial, signature, issuer, validity, subject, key.
    final first = fields.first.tag == 0xA0 ? 1 : 0;
    final key = fields[first + 5];

    return key.tag == 0x30 ? key.bytes : null;
  } on FormatException {
    return null;
  } on RangeError {
    return null;
  } on StateError {
    return null;
  }
}

/// One DER element: its tag and where its content lies.
class _Node {
  _Node(this.data, this.offset) {
    tag = data[offset];
    final first = data[offset + 1];

    if (first < 0x80) {
      headerLength = 2;
      length = first;
    } else {
      final count = first & 0x7f;
      if (count == 0 || count > 4) {
        throw const FormatException('DER length');
      }

      var value = 0;
      for (var i = 0; i < count; i++) {
        value = (value << 8) | data[offset + 2 + i];
      }

      headerLength = 2 + count;
      length = value;
    }

    if (end > data.length) {
      throw const FormatException('DER past the end');
    }
  }

  final List<int> data;
  final int offset;
  late final int tag;
  late final int headerLength;
  late final int length;

  int get end => offset + headerLength + length;

  List<int> get bytes => data.sublist(offset, end);

  List<_Node> children() {
    final found = <_Node>[];
    var at = offset + headerLength;

    while (at < end) {
      final child = _Node(data, at);
      found.add(child);
      at = child.end;
    }

    return found;
  }
}
