import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/components/components.dart';
import '../domain/entities/captain_trip.dart';
import 'panels/on_trip_panel.dart';
import 'panels/to_pickup_panel.dart';
import 'panels/waiting_panel.dart';
import 'sheets/cancel_sheet.dart';
import 'sheets/no_show_sheet.dart';
import 'trip_controller.dart';
import 'trip_state.dart';

/// The sheet over the trip map: the panel of where the trip stands, and the questions
/// asked before cancelling or reporting a no-show.
class TripPanel extends ConsumerWidget {
  const TripPanel({super.key, required this.state, required this.trip, required this.scroll});

  final TripState state;
  final CaptainTrip trip;
  final ScrollController scroll;

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final answer = await askCancelReason(context);

    if (answer != null) {
      await ref.read(tripControllerProvider(trip).notifier).cancel(answer.$1, detail: answer.$2);
    }
  }

  Future<void> _noShow(BuildContext context, WidgetRef ref) async {
    final arrived = state.trip.arrivedAt;
    final waited = arrived == null ? Duration.zero : DateTime.now().difference(arrived);

    if (await confirmNoShow(context, waited: waited, terms: state.terms)) {
      await ref.read(tripControllerProvider(trip).notifier).reportNoShow();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(tripControllerProvider(trip).notifier);
    void cancel() => unawaited(_cancel(context, ref));

    final panel = switch (state.phase) {
      TripPhase.toPickup => ToPickupPanel(state: state, onArrived: controller.arrive, onCancel: cancel),
      TripPhase.waiting => WaitingPanel(
          state: state,
          onStart: controller.start,
          onNoShow: () => unawaited(_noShow(context, ref)),
          onCancel: cancel,
        ),
      _ => OnTripPanel(state: state, onReachStop: controller.reachStop, onFinish: controller.finish),
    };

    return LayoutBuilder(
      builder: (context, sheet) => SingleChildScrollView(
        controller: scroll,
        child: ConstrainedBox(
          // The panel's colour reaches the sheet's bottom, however short it is.
          constraints: BoxConstraints(minHeight: sheet.maxHeight),
          child: MapPanel(handle: true, children: [panel]),
        ),
      ),
    );
  }
}
