import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../legacy/core/api/api_exception.dart' as legacy;
import '../../../legacy/features/trip/trip_summary_screen.dart';
import '../../../legacy/state/api_providers.dart' as legacy;

// Collecting the fare and rating the rider are still the old screen (lib/legacy) until
// batch 3b replaces it. This is the only link from the new trip screens to it.

/// Replaces the trip screen with the old end-of-trip screen. When the trip cannot be
/// read there, the trip screen simply closes.
Future<void> openLegacySummary(BuildContext context, WidgetRef ref, String tripId) async {
  try {
    final trip = await ref.read(legacy.tripApiProvider).getTrip(tripId);

    if (context.mounted) {
      await Navigator.of(context).pushReplacement<void, void>(
        MaterialPageRoute(builder: (_) => TripSummaryScreen(trip: trip)),
      );
    }
  } on legacy.ApiException {
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
