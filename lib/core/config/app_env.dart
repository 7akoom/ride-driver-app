import 'package:flutter/foundation.dart';

import '../network/certificate_pinning.dart';
import 'hex_color.dart';

/// Something about the build's configuration that makes it unsafe or unusable.
enum EnvProblem {
  /// The API address is not a valid absolute URL.
  invalidApiUrl,

  /// A release build would talk to the API over plain HTTP.
  insecureApiUrl,

  /// A release build would load the map over plain HTTP.
  insecureTilesUrl,

  /// BRAND_COLOR or BRAND_STRONG_COLOR is not a #RRGGBB colour.
  invalidBrandColor,

  /// A release build has no API_PINS: it would trust any certificate the phone does.
  missingApiPins,

  /// An entry of API_PINS is not a key pin (the base64 of a SHA-256).
  invalidApiPins,
}

/// Values set per build with `--dart-define` (one build per investor's copy).
///
/// Example:
///   flutter build apk --release --obfuscate --split-debug-info=build/symbols \
///     --dart-define=API_BASE_URL=https://ride-api.example.com \
///     --dart-define=MAP_TILES_URL=https://ride-tiles.example.com \
///     --dart-define=APP_NAME='Ride Captain' --dart-define=BRAND_COLOR=#F3D59A \
///     --dart-define=API_PINS=<current pin>,<backup pin>
abstract final class AppEnv {
  /// The API gateway. The default reaches a backend on the developer's computer from
  /// the Android emulator, and only debug builds accept plain HTTP.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  /// The map server (styles, tiles, fonts).
  static const String mapTilesUrl = String.fromEnvironment(
    'MAP_TILES_URL',
    defaultValue: 'https://ride-tiles.lenda-agency.com',
  );

  /// The product name shown by the system (task switcher) and on the start screen.
  /// Not translated: it is the operator's brand name for the captain app.
  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'Ride Captain',
  );

  /// The investor's brand colour: primary buttons, selections, highlights.
  static const String brandColor = String.fromEnvironment(
    'BRAND_COLOR',
    defaultValue: '#F3D59A',
  );

  /// Optional: the brand colour for text and icons on light backgrounds. When empty it
  /// is derived from [brandColor] with enough contrast.
  static const String brandStrongColor = String.fromEnvironment('BRAND_STRONG_COLOR');

  /// The country calling code shown before phone numbers (one country per copy).
  static const String phoneDialCode = String.fromEnvironment(
    'PHONE_DIAL_CODE',
    defaultValue: '+964',
  );

  /// Where the map opens before the phone's position is known: the copy's main city,
  /// as "latitude,longitude". Erbil by default.
  static const String mapCenter = String.fromEnvironment(
    'MAP_CENTER',
    defaultValue: '36.1911,44.0092',
  );

  /// The copy's terms of use and privacy policy pages (https). The account shows a link
  /// to each that is set; the stores ask for the privacy policy.
  static const String termsUrl = String.fromEnvironment('TERMS_URL');
  static const String privacyUrl = String.fromEnvironment('PRIVACY_URL');

  /// The pins of the server's key (certificate pinning), comma separated: the current
  /// key and a backup one. Printed by `scripts/deploy/tls-pins.sh` on the server.
  /// Required in release builds; empty in development (the phone's usual checks).
  static const String apiPins = String.fromEnvironment('API_PINS');

  /// Sent with every login so the backend can tell which app a session belongs to.
  static const String clientId = 'driver-app';

  /// Sent with every login. Keep in step with `version:` in pubspec.yaml.
  static const String appVersion = '0.1.0';

  /// The problems with this build's configuration; empty when it is fine to run.
  static List<EnvProblem> problems() => check(
        apiBaseUrl: apiBaseUrl,
        mapTilesUrl: mapTilesUrl,
        isRelease: kReleaseMode,
        brandColor: brandColor,
        brandStrongColor: brandStrongColor,
        apiPins: apiPins,
      );

  @visibleForTesting
  static List<EnvProblem> check({
    required String apiBaseUrl,
    required String mapTilesUrl,
    required bool isRelease,
    String brandColor = '#F3D59A',
    String brandStrongColor = '',
    String apiPins = '',
  }) {
    final found = <EnvProblem>[];
    final api = Uri.tryParse(apiBaseUrl);

    if (api == null || !api.hasScheme || api.host.isEmpty) {
      found.add(EnvProblem.invalidApiUrl);
    } else if (isRelease && api.scheme != 'https') {
      found.add(EnvProblem.insecureApiUrl);
    }

    final tiles = Uri.tryParse(mapTilesUrl);
    if (isRelease && (tiles == null || tiles.scheme != 'https')) {
      found.add(EnvProblem.insecureTilesUrl);
    }

    final strongIsValid =
        brandStrongColor.isEmpty || parseHexColor(brandStrongColor) != null;
    if (parseHexColor(brandColor) == null || !strongIsValid) {
      found.add(EnvProblem.invalidBrandColor);
    }

    final pins = CertificatePinning.parsePins(apiPins);
    if (!pins.every(CertificatePinning.isPin)) {
      found.add(EnvProblem.invalidApiPins);
    } else if (isRelease && pins.isEmpty) {
      found.add(EnvProblem.missingApiPins);
    }

    return found;
  }
}
