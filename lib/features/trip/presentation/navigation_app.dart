import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

import '../../../core/location/geo_point.dart';

/// Opens the phone's navigation app on [to], by car: on Android the system asks which
/// (Google Maps, Waze...); elsewhere, or when nothing answers the geo link, Google
/// Maps in its app or the browser. False when nothing could open it.
Future<bool> openNavigationApp(GeoPoint to) async {
  final at = '${to.latitude},${to.longitude}';

  if (Platform.isAndroid) {
    final geo = Uri.parse('geo:$at?q=$at');
    if (await launchUrl(geo, mode: LaunchMode.externalApplication)) {
      return true;
    }
  }

  return launchUrl(
    Uri.https('www.google.com', '/maps/dir/', {'api': '1', 'destination': at, 'travelmode': 'driving'}),
    mode: LaunchMode.externalApplication,
  );
}
