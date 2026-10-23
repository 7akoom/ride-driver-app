import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/core/network/certificate_key.dart';
import 'package:driver_app/core/network/certificate_pinning.dart';

// Self-signed test certificates; their pins come from openssl:
//   openssl x509 -in c.pem -pubkey -noout | openssl pkey -pubin -outform der \
//     | openssl dgst -sha256 -binary | base64
final List<int> ecCertificate = base64.decode('MIIBlDCCATmgAwIBAgIUaZOVGUaiiSfO2P3dyyfLwXgEuJowCgYIKoZIzj0EAwIwHzEdMBsGA1UEAwwUcmlkZS1hcGkuZXhhbXBsZS5jb20wHhcNMjYxMDIwMDkwNDE1WhcNMzYxMDE3MDkwNDE1WjAfMR0wGwYDVQQDDBRyaWRlLWFwaS5leGFtcGxlLmNvbTBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABCiSdxFrWZI98C9p258JCS8aZ98CSCRh1vIhwWIjtFjSo0AVvvLGUIGSNp0Sh1bCt7IRKH6PPiILaBfbcCX0YJ+jUzBRMB0GA1UdDgQWBBTP1je5aBhrE3iSgPEwUMsvutf7WzAfBgNVHSMEGDAWgBTP1je5aBhrE3iSgPEwUMsvutf7WzAPBgNVHRMBAf8EBTADAQH/MAoGCCqGSM49BAMCA0kAMEYCIQCq17PcHbgQz/xUJ95C1pS2FLe/IOEDS5r1lTtguUfX8QIhAINkN99otpQyYh7qTIh0MSOTBNvuyx/PU9yROAz/F1G4');
const String ecPin = '/znoiggBJH+VHbPNIMUiGS/IANzoul96aYNRwo80AEc=';

final List<int> rsaCertificate = base64.decode('MIIC+TCCAeGgAwIBAgIUeacc6Xr3LsTLNUbJapSIRKdN9EIwDQYJKoZIhvcNAQELBQAwDDEKMAgGA1UEAwwBeDAeFw0yNjEwMjAwOTA0MTVaFw0zNjEwMTcwOTA0MTVaMAwxCjAIBgNVBAMMAXgwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCKDPFaQTez/UIocVOeA4e515xPy/6paSwHoYpA4I2062gS8QDMF6CiVRhKui+/oP/SFaJ9YySF4SjzClEwRyLhuJ4zYDXLQGXZqELLVzfw8i1lufVKcJGZP27Pf54U6w6fu4uc3ofTHlU+KGLKEfrJ9IYvagxM94qdX+gGc1Rf5mRHPlnEO8Z5TpIggEUamKpo9kMnwIkYZZsMfQd2KF33MxN5GUqFwgU6XfLrMAQXHJ0TicJKhP+vwzVZzHW+eSgkRsUXVVo7vDhtx49TTRBJchR7kmCZkYdxgeyZnUKDCi0/zPLo+n+VfYgjrZqImY6tO/PeDepL7WQOP0M4ACmdAgMBAAGjUzBRMB0GA1UdDgQWBBT5baKUlC+LyiTChSCho9cflFjybjAfBgNVHSMEGDAWgBT5baKUlC+LyiTChSCho9cflFjybjAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQBifvGjGJwlLxa+N2yyEbjUcSa1/pYgPCE+GifnP33CeOj3CYgOM+hx20f8Wn4donpy6inBkKbXtF4WsS7LeozwQUwtX2ixjBfYoDkHabBlwSbbwaypSZCCy07sQaw4V+NfteUl1x6kcAI2VJLgS3TWCO6+K4fNGbfY7a87t/cK7Wpg9t3fMRIDfJQwW+P3wMiQoDQXmRckJ/GosR53IPoZAYmynMb/CXszsO2GfkLYsmrdB02DHhXltNZAHoQc4SrbPeNWHI9wvQu5gUe1Q/5y3O1W481gRVVobTm/fweKqkVUtzLKhjpoD+ZROkjwaO7LsG337+ptoC5hnK8GAyaq');
const String rsaPin = 'aq2F/ouYLqjRaCulKG52etaTzRh6nHeDtNG/e2kvTaQ=';

class FakeCertificate implements X509Certificate {
  FakeCertificate(this.der, {DateTime? start, DateTime? end})
      : startValidity = start ?? DateTime(2020),
        endValidity = end ?? DateTime(2100);

  @override
  final Uint8List der;

  @override
  final DateTime startValidity;

  @override
  final DateTime endValidity;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('the key pin is the one openssl prints, for EC and RSA keys', () {
    expect(keyPinOf(ecCertificate), ecPin);
    expect(keyPinOf(rsaCertificate), rsaPin);
  });

  test('something that is not a certificate has no pin', () {
    expect(keyPinOf(<int>[]), isNull);
    expect(keyPinOf(<int>[0x30, 0x82, 0xff]), isNull);
    expect(keyPinOf(utf8.encode('hello')), isNull);
    expect(keyPinOf(ecCertificate.sublist(0, 100)), isNull);
  });

  test('only a pinned key in its validity dates is accepted', () {
    final pinning = CertificatePinning({ecPin});
    final now = DateTime(2030);

    expect(pinning.accepts(FakeCertificate(Uint8List.fromList(ecCertificate)), now: now), isTrue);
    expect(pinning.accepts(FakeCertificate(Uint8List.fromList(rsaCertificate)), now: now), isFalse);
    expect(
      pinning.accepts(FakeCertificate(Uint8List.fromList(ecCertificate), end: DateTime(2029)), now: now),
      isFalse,
    );
    expect(
      pinning.accepts(FakeCertificate(Uint8List.fromList(ecCertificate), start: DateTime(2031)), now: now),
      isFalse,
    );
  });

  test('the backup pin is accepted as well', () {
    final pinning = CertificatePinning(CertificatePinning.parsePins(' $ecPin , $rsaPin '));

    expect(pinning.pins, {ecPin, rsaPin});
    expect(pinning.accepts(FakeCertificate(Uint8List.fromList(rsaCertificate))), isTrue);
  });

  test('pins are checked for their form', () {
    expect(CertificatePinning.isPin(ecPin), isTrue);
    expect(CertificatePinning.isPin('abc'), isFalse);
    expect(CertificatePinning.parsePins(''), isEmpty);
  });

  test('without pins the client keeps the usual checks; with pins it gets its own', () {
    final plain = Dio();
    final adapter = plain.httpClientAdapter;

    expect(identical(CertificatePinning({}).apply(plain).httpClientAdapter, adapter), isTrue);
    expect(CertificatePinning({ecPin}).apply(Dio()).httpClientAdapter, isA<IOHttpClientAdapter>());
  });
}
