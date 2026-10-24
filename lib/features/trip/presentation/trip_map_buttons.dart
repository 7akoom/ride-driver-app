import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../design/components/components.dart';
import '../../../design/design_context.dart';
import '../../../design/map/app_map.dart';
import '../../../design/tokens/metrics.dart';
import '../domain/entities/captain_trip.dart';
import 'navigation_app.dart';
import 'sheets/sos_sheet.dart';
import 'trip_controller.dart';
import 'trip_state.dart';

/// The buttons over the trip map: SOS, back to the car, and the phone's navigation app
/// to where the captain heads now.
class TripMapButtons extends ConsumerWidget {
  const TripMapButtons({super.key, required this.state, required this.map, required this.trip});

  final TripState state;
  final AppMapController? Function() map;
  final CaptainTrip trip;

  Future<void> _navigate(BuildContext context) async {
    final opened = await openNavigationApp(state.trip.heading);

    if (!opened && context.mounted) {
      showAppToast(context, context.l10n.tripNoNavigationApp, tone: Tone.warning);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final position = state.position;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Space.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              color: context.palette.danger,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => showSosSheet(context, raise: ref.read(tripControllerProvider(trip).notifier).raiseSos),
                child: SizedBox.square(
                  dimension: Sizes.iconButton + Space.x2,
                  child: Center(child: Text(l10n.sosShort, style: context.typo.button.copyWith(color: context.palette.onInk))),
                ),
              ),
            ),
            const SizedBox(height: Space.x3),
            AppIconButton(
              icon: Icons.navigation_outlined,
              semanticLabel: l10n.tripOpenNavigation,
              floating: true,
              onPressed: () => unawaited(_navigate(context)),
            ),
            const SizedBox(height: Space.x3),
            AppIconButton(
              icon: Icons.my_location,
              semanticLabel: l10n.actionRecentre,
              floating: true,
              onPressed: position == null ? null : () => map()?.moveTo(position),
            ),
          ],
        ),
      ),
    );
  }
}
