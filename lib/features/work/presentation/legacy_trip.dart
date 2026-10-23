import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/location/geo_point.dart';
import '../../../core/security/session_storage.dart';
import '../../../legacy/core/api/api_exception.dart' as legacy;
import '../../../legacy/core/models/geo_point.dart' as legacy;
import '../../../legacy/features/trip/active_trip_screen.dart';
import '../../../legacy/state/api_providers.dart' as legacy;
import '../../../legacy/state/lookups.dart' as legacy;

// The trip screens are still the old ones (lib/legacy) until batch 3 replaces them.
// These two functions are the only link from the new home to them.

/// Opens the trip the captain is on in the old trip screens, and returns when they
/// close. Nothing opens when there is no trip or it cannot be read.
Future<void> openLegacyTrip(BuildContext context, WidgetRef ref) async {
  final driverId = await SessionStorage.readDriverId();
  if (driverId == null) {
    return;
  }

  try {
    final trip = await ref.read(legacy.tripApiProvider).activeTrip(driverId);

    if (trip != null && context.mounted) {
      await Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => ActiveTripScreen(trip: trip)));
    }
  } on legacy.ApiException {
    // A dropped connection: the next check for work opens it.
  }
}

/// Gives the old trip screens the captain's position, which they read from their own
/// provider.
void shareLegacyPosition(WidgetRef ref, GeoPoint position) {
  ref.read(legacy.driverPositionProvider.notifier).state = legacy.GeoPoint(position.latitude, position.longitude);
}
