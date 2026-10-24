import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure_messages.dart';
import '../../../core/l10n/l10n.dart';
import '../../../design/components/components.dart';
import '../../../design/map/app_map.dart';
import '../../../design/tokens/metrics.dart';
import '../domain/entities/captain_trip.dart';
import 'trip_controller.dart';
import 'trip_map_buttons.dart';
import 'trip_outcome.dart';
import 'trip_panel.dart';
import 'trip_state.dart';

/// 18–22: the captain's trip, from the way to the pickup to the end, the map under a
/// sheet. It closes by itself once the trip ends (to collecting the fare) or is
/// cancelled (back home).
class TripScreen extends ConsumerStatefulWidget {
  const TripScreen({super.key, required this.trip});

  final CaptainTrip trip;

  static const double sheetStart = 0.5;
  static const double sheetMin = 0.25;
  static const double sheetMax = 0.92;

  @override
  ConsumerState<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends ConsumerState<TripScreen> {
  AppMapController? _map;

  void _changed(TripState? before, TripState now) {
    final failure = now.failure;
    if (failure != null && before?.failure == null) {
      showAppToast(context, failure.message(context.l10n), tone: Tone.danger);
      ref.read(tripControllerProvider(widget.trip).notifier).dismissFailure();
    }

    if (before?.phase != now.phase && !now.trip.ongoing) {
      unawaited(closeTrip(context, ref, now.trip));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = tripControllerProvider(widget.trip);
    final state = ref.watch(provider);

    ref.listen(provider, _changed);

    // Back leads home; the trip goes on and home opens it again.
    return AppScaffold(
        padded: false,
        body: LayoutBuilder(
          builder: (context, box) => Stack(
            children: [
              Positioned.fill(
                child: AppMap(
                  center: state.position ?? state.trip.heading,
                  zoom: AppMap.streetZoom,
                  route: state.map,
                  vehicle: state.position,
                  frameBottom: box.maxHeight * TripScreen.sheetStart + Space.x6,
                  onCreated: (map) => _map = map,
                ),
              ),
              TripMapButtons(state: state, map: () => _map, trip: widget.trip),
              DraggableScrollableSheet(
                initialChildSize: TripScreen.sheetStart,
                minChildSize: TripScreen.sheetMin,
                maxChildSize: TripScreen.sheetMax,
                snap: true,
                builder: (context, scroll) => TripPanel(state: state, trip: widget.trip, scroll: scroll),
              ),
            ],
          ),
        ),
    );
  }
}
