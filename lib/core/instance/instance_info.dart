import '../network/json.dart';

/// Which emergency service a number reaches; the app names each in the captain's
/// language.
enum EmergencyKind { general, police, ambulance, fire }

final class EmergencyNumber {
  const EmergencyNumber(this.kind, this.number);

  final EmergencyKind kind;

  /// As dialled: digits, maybe with a leading +.
  final String number;
}

/// What the copy's settings say (support-service instance-info): its terms and
/// privacy pages, and the emergency numbers of its country. Set on the server, so
/// they change without a new build.
final class InstanceInfo {
  const InstanceInfo({this.termsUrl = '', this.privacyUrl = '', this.emergency = const []});

  /// Empty when not set.
  final String termsUrl;
  final String privacyUrl;
  final List<EmergencyNumber> emergency;

  /// The server's values; a page it does not set falls back to the build's
  /// (TERMS_URL, PRIVACY_URL).
  static InstanceInfo fromJson(JsonMap json, {String fallbackTerms = '', String fallbackPrivacy = ''}) {
    String page(String key, String fallback) {
      final value = json[key];

      return value is String && value.trim().startsWith('https://') ? value.trim() : fallback;
    }

    final numbers = <EmergencyNumber>[];
    if (json['emergencyNumbers'] case final List<dynamic> list) {
      for (final item in list) {
        if (item is! Map) {
          continue;
        }

        final kind = _kinds[item['kind']];
        final number = item['number'];

        if (kind != null && number is String && RegExp(r'^\+?[0-9]{2,15}$').hasMatch(number)) {
          numbers.add(EmergencyNumber(kind, number));
        }
      }
    }

    return InstanceInfo(
      termsUrl: page('termsUrl', fallbackTerms),
      privacyUrl: page('privacyUrl', fallbackPrivacy),
      emergency: numbers,
    );
  }

  static const Map<Object?, EmergencyKind> _kinds = {
    'EMERGENCY_KIND_GENERAL': EmergencyKind.general,
    'EMERGENCY_KIND_POLICE': EmergencyKind.police,
    'EMERGENCY_KIND_AMBULANCE': EmergencyKind.ambulance,
    'EMERGENCY_KIND_FIRE': EmergencyKind.fire,
  };
}
