import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/sim/sim_providers.dart';
import '../../../core/voice/voice_providers.dart';
import '../../../design/components/components.dart';
import '../../../design/design_context.dart';
import '../../../design/map/app_map.dart';
import '../../../design/tokens/metrics.dart';
import '../domain/entities/captain_trip.dart';
import 'navigation_app.dart';
import 'sheets/sos_sheet.dart';
import 'trip_controller.dart';
import 'trip_state.dart';

/// The buttons over the trip map: SOS, the phone's navigation app to where the captain
/// heads now, the voice on or off, and back to the car (following it again while
/// driving with guidance).
class TripMapButtons extends ConsumerWidget {
  const TripMapButtons({
    super.key,
    required this.state,
    required this.map,
    required this.trip,
    required this.following,
    required this.onFollow,
  });

  final TripState state;
  final AppMapController? Function() map;
  final CaptainTrip trip;
  final bool following;
  final VoidCallback onFollow;

  Future<void> _navigate(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(tripControllerProvider(trip).notifier);

    // The other app speaks its own directions; ours wait until the captain is back.
    controller.quiet(true);
    final opened = await openNavigationApp(state.trip.heading);

    if (!opened) {
      controller.quiet(false);

      if (context.mounted) {
        showAppToast(context, context.l10n.tripNoNavigationApp, tone: Tone.warning);
      }
    }
  }

  void _voice(BuildContext context, WidgetRef ref, bool on) {
    ref.read(voiceOnProvider.notifier).set(!on);
    showAppToast(context, on ? context.l10n.navVoiceMuted : context.l10n.navVoiceUnmuted, tone: Tone.info);
  }

  void _toCar() {
    final position = state.position;

    if (state.guiding) {
      onFollow();
    } else if (position != null) {
      unawaited(map()?.moveTo(position));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final voiceOn = ref.watch(voiceOnProvider);

    return Column(
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
          onPressed: () => unawaited(_navigate(context, ref)),
        ),
        if (state.guiding) ...[
          const SizedBox(height: Space.x3),
          AppIconButton(
            icon: voiceOn ? Icons.volume_up_outlined : Icons.volume_off_outlined,
            semanticLabel: voiceOn ? l10n.navVoiceOff : l10n.navVoiceOn,
            floating: true,
            onPressed: () => _voice(context, ref, voiceOn),
          ),
        ],
        // Development builds with SIM_DRIVE: the self-driving car takes a wrong street.
        if (ref.watch(simDriveProvider) case final sim? when state.guiding) ...[
          const SizedBox(height: Space.x3),
          AppIconButton(
            icon: Icons.alt_route,
            semanticLabel: l10n.simLeaveRoad,
            floating: true,
            onPressed: sim.leaveRoad,
          ),
        ],
        // Hidden while the camera already follows the car: nothing to bring back.
        if (!(state.guiding && following)) ...[
          const SizedBox(height: Space.x3),
          AppIconButton(
            icon: Icons.my_location,
            semanticLabel: l10n.actionRecentre,
            floating: true,
            onPressed: state.position == null ? null : _toCar,
          ),
        ],
      ],
    );
  }
}
