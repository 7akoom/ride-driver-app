import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure_messages.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/screen/keep_screen_on.dart';
import '../../../design/components/components.dart';
import '../../../design/map/app_map.dart';
import '../../../design/tokens/metrics.dart';
import '../domain/entities/captain_trip.dart';
import 'navigation/turn_card.dart';
import 'trip_controller.dart';
import 'trip_map_buttons.dart';
import 'trip_outcome.dart';
import 'trip_panel.dart';
import 'trip_state.dart';

/// 18–22: the captain's trip, from the way to the pickup to the end, the map under a
/// sheet. On the way, the map follows the car with the next turn over it and the turns
/// said aloud. It closes by itself once the trip ends (to collecting the fare) or is
/// cancelled (back home). The screen stays on while it is open.
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

  /// The camera follows the car until the captain moves the map; the position button
  /// brings it back.
  bool _following = true;

  /// Where the turn card ends, roughly: the following camera keeps the car under it.
  static const double _cardBottom = Space.gutter + Space.x3 * 2 + Sizes.avatar;

  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    unawaited(KeepScreenOn.acquire());

    // Back from another navigation app: our voice speaks again.
    _lifecycle = AppLifecycleListener(onResume: () => ref.read(tripControllerProvider(widget.trip).notifier).quiet(false));
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    unawaited(KeepScreenOn.release());
    super.dispose();
  }

  void _changed(TripState? before, TripState now) {
    final l10n = context.l10n;
    final failure = now.failure;
    if (failure != null && before?.failure == null) {
      showAppToast(context, failure.message(l10n), tone: Tone.danger);
      ref.read(tripControllerProvider(widget.trip).notifier).dismissFailure();
    }

    if (now.voiceNotice case final notice? when before?.voiceNotice == null) {
      showAppToast(context, notice == VoiceNotice.inArabic ? l10n.navVoiceInArabic : l10n.navVoiceUnavailable, tone: Tone.info);
    }

    if (before?.phase != now.phase && !now.trip.ongoing) {
      unawaited(closeTrip(context, now.trip, rider: now.rider));
    }
  }

  /// The driving camera, while the captain drives with guidance and has not moved the
  /// map: the car low in the open part of the map, the road ahead up.
  MapFollow? _follow(TripState state, double height, double bottom) {
    final car = state.car;
    final progress = state.progress;

    if (!_following || !state.guiding || car == null || progress == null) {
      return null;
    }

    final open = height - bottom;
    final top = MediaQuery.paddingOf(context).top + _cardBottom;
    final carY = top + (open - top) * 0.75;

    return MapFollow(at: car, bearing: progress.bearing, top: math.max(0, 2 * carY - open));
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
          builder: (context, box) {
            final bottom = box.maxHeight * TripScreen.sheetStart + Space.x6;
            final progress = state.progress;

            return Stack(
              children: [
                Positioned.fill(
                  child: AppMap(
                    center: state.position ?? state.trip.heading,
                    zoom: AppMap.streetZoom,
                    route: state.map,
                    vehicle: state.car,
                    frameBottom: bottom,
                    follow: _follow(state, box.maxHeight, bottom),
                    onDragged: state.guiding && _following ? () => setState(() => _following = false) : null,
                    onCreated: (map) => _map = map,
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(Space.gutter),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.guiding && progress != null) ...[
                          SizedBox(
                            width: double.infinity,
                            child: TurnCard(progress: progress, arrival: state.arrival, rerouting: state.rerouting),
                          ),
                          const SizedBox(height: Space.x3),
                        ],
                        TripMapButtons(
                          state: state,
                          map: () => _map,
                          trip: widget.trip,
                          following: _following,
                          onFollow: () => setState(() => _following = true),
                        ),
                      ],
                    ),
                  ),
                ),
                DraggableScrollableSheet(
                  initialChildSize: TripScreen.sheetStart,
                  minChildSize: TripScreen.sheetMin,
                  maxChildSize: TripScreen.sheetMax,
                  snap: true,
                  builder: (context, scroll) => TripPanel(state: state, trip: widget.trip, scroll: scroll),
                ),
              ],
            );
          },
        ),
    );
  }
}
