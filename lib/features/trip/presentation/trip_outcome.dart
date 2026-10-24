import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/result.dart';
import '../../../core/l10n/l10n.dart';
import '../../../design/components/components.dart';
import '../../work/presentation/legacy_trip.dart';
import '../domain/entities/captain_trip.dart';
import '../trip_providers.dart';
import 'trip_screen.dart';

/// Opens the trip the captain is on, and returns when its screens close. Nothing opens
/// when there is no trip or it cannot be read (the next check for work tries again).
Future<void> openCaptainTrip(BuildContext context, WidgetRef ref) async {
  final work = await ref.read(tripRepositoryProvider).active();

  if (work case Ok(value: final now?) when context.mounted) {
    await Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => TripScreen(trip: now.trip)));
  }
}

/// The trip ended: on to collecting the fare, or back home saying why it was cancelled.
Future<void> closeTrip(BuildContext context, WidgetRef ref, CaptainTrip trip) async {
  if (trip.phase == TripPhase.completed) {
    return openLegacySummary(context, ref, trip.id);
  }

  final l10n = context.l10n;
  final message = trip.riderNoShow
      ? l10n.tripEndedNoShow
      : trip.cancelledByCaptain
          ? l10n.tripEndedByCaptain
          : l10n.tripEndedByRider;

  showAppToast(context, message, tone: Tone.info);
  Navigator.of(context).pop();
}
