import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/core/instance/instance_info.dart';

void main() {
  test('the server pages and numbers, in order; bad entries are left out', () {
    final info = InstanceInfo.fromJson({
      'termsUrl': 'https://taxi.example.com/terms',
      'emergencyNumbers': [
        {'kind': 'EMERGENCY_KIND_POLICE', 'number': '104'},
        {'kind': 'EMERGENCY_KIND_AMBULANCE', 'number': '122'},
        {'kind': 'EMERGENCY_KIND_UNSPECIFIED', 'number': '999'},
        {'kind': 'EMERGENCY_KIND_FIRE', 'number': 'call us'},
        'nonsense',
      ],
    }, fallbackPrivacy: 'https://build.example.com/privacy');

    expect(info.termsUrl, 'https://taxi.example.com/terms');
    expect(info.privacyUrl, 'https://build.example.com/privacy');
    expect([for (final n in info.emergency) (n.kind, n.number)], [
      (EmergencyKind.police, '104'),
      (EmergencyKind.ambulance, '122'),
    ]);
  });

  test('nothing set: no pages, no numbers; a page that is not https is ignored', () {
    final info = InstanceInfo.fromJson({'privacyUrl': 'http://x.example.com'});

    expect(info.termsUrl, isEmpty);
    expect(info.privacyUrl, isEmpty);
    expect(info.emergency, isEmpty);
  });
}
