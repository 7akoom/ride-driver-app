import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../config/app_env.dart';
import 'certificate_key.dart';

/// Certificate pinning for every connection to the copy's servers (the API and the
/// file store share one certificate).
///
/// With pins (API_PINS at build time) the phone's certificate authorities are not
/// trusted at all: only a server whose key is one of the pins, with a certificate in
/// its validity dates, is talked to. A certificate signed by a proxy or a root planted
/// on the phone is refused during the handshake, before anything (a token, a PIN) is
/// sent. Without pins (development) the phone's usual checks apply.
class CertificatePinning {
  CertificatePinning(this.pins);

  /// From the build: the current key's pin and a backup key's, comma separated.
  static final CertificatePinning ofBuild = CertificatePinning(parsePins(AppEnv.apiPins));

  final Set<String> pins;

  bool get enabled => pins.isNotEmpty;

  static Set<String> parsePins(String raw) =>
      raw.split(',').map((pin) => pin.trim()).where((pin) => pin.isNotEmpty).toSet();

  /// Whether a pin looks like one (the base64 of 32 bytes).
  static bool isPin(String pin) => RegExp(r'^[A-Za-z0-9+/]{43}=$').hasMatch(pin);

  bool accepts(X509Certificate certificate, {DateTime? now}) {
    final at = now ?? DateTime.now();

    if (at.isBefore(certificate.startValidity) || at.isAfter(certificate.endValidity)) {
      return false;
    }

    return pins.contains(keyPinOf(certificate.der));
  }

  /// Makes [dio] connect only to pinned servers; it is left as it is without pins.
  Dio apply(Dio dio) {
    if (!enabled) {
      return dio;
    }

    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        // No trusted roots: every certificate comes to the callback, which trusts
        // only the pinned keys.
        final client = HttpClient(context: SecurityContext(withTrustedRoots: false));
        client.badCertificateCallback = (certificate, host, port) => accepts(certificate);

        return client;
      },
    );

    return dio;
  }
}
