import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure_messages.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/location/geo_point.dart';
import '../../../../core/location/location_providers.dart';
import '../../../../design/components/components.dart';
import '../../../../design/map/app_map.dart';
import '../../../../design/tokens/metrics.dart';
import '../../../inbox/inbox_providers.dart';
import '../../../inbox/presentation/inbox_screen.dart';
import '../../domain/repositories/position_reporter.dart';
import '../../work_providers.dart';
import '../legacy_trip.dart';
import '../widgets/blocked_sheet.dart';
import '../widgets/home_menu_sheet.dart';
import '../widgets/online_toggle.dart';
import '../widgets/status_strip.dart';
import '../widgets/today_stats.dart';
import 'home_controller.dart';
import 'home_state.dart';
import 'work_watcher.dart';

/// 10–11: the map around the captain's car, today's numbers, and the online switch.
/// Online, the position keeps going in the background and new work opens by itself.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WorkWatcher {
  AppMapController? _map;
  GeoPoint? _position;

  /// Today's numbers again whenever the captain comes back to the app.
  late final AppLifecycleListener _life;

  @override
  void initState() {
    super.initState();
    _life = AppLifecycleListener(
      onResume: () => unawaited(ref.read(homeControllerProvider.notifier).refreshToday()),
    );
    unawaited(Future.microtask(_start));
  }

  @override
  void dispose() {
    _life.dispose();
    super.dispose();
  }

  ReportingNotice _notice() =>
      ReportingNotice(title: context.l10n.onlineNoticeTitle, text: context.l10n.onlineNoticeText);

  Future<void> _start() async {
    // Offline nothing reports the position: the map still opens where the captain is.
    unawaited(ref.read(locationAccessProvider).currentPosition().then((position) {
      if (mounted && position != null && _position == null) {
        _follow(position);
      }
    }));

    final tripId = await ref.read(homeControllerProvider.notifier).start(_notice());
    if (mounted && tripId != null) {
      await openTrip();
    }
  }

  void _follow(GeoPoint position) {
    final first = _position == null;
    setState(() => _position = position);
    shareLegacyPosition(ref, position);

    if (first || ref.read(homeControllerProvider).online) {
      unawaited(_map?.moveTo(position));
    }
  }

  void _changed(HomeState? before, HomeState now) {
    final block = now.block;
    if (block != null && before?.block == null) {
      unawaited(showBlockedSheet(context, block).then((_) => ref.read(homeControllerProvider.notifier).dismissBlock()));
    }

    final failure = now.failure;
    if (failure != null && before?.failure == null) {
      showAppToast(context, failure.message(context.l10n), tone: Tone.danger);
      ref.read(homeControllerProvider.notifier).dismissFailure();
    }

    now.online ? watchForWork() : stopWatching();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);
    final controller = ref.read(homeControllerProvider.notifier);
    final unread = ref.watch(unreadCountProvider).valueOrNull?.fold((count) => count, (_) => 0) ?? 0;

    ref.listen(homeControllerProvider, _changed);
    ref.listen(captainPositionProvider, (_, next) {
      if (next.valueOrNull case final position?) {
        _follow(position);
      }
    });

    return AppScaffold(
      padded: false,
      body: MapLayout(
        panelShare: 0.45,
        map: (covered) => AppMap(
          center: _position,
          zoom: AppMap.streetZoom,
          vehicle: _position,
          frameBottom: covered,
          onCreated: (map) => _map = map,
        ),
        marker: state.online
            ? (covered) => Padding(
                  padding: EdgeInsetsDirectional.only(bottom: covered),
                  child: const Center(child: PulseRings(showMarker: false)),
                )
            : null,
        buttons: Stack(
          children: [
            PositionedDirectional(
              top: Space.x3,
              start: Space.gutter,
              end: Space.gutter,
              child: Row(
                children: [
                  AppIconButton(
                    icon: Icons.menu,
                    semanticLabel: context.l10n.homeMenu,
                    floating: true,
                    onPressed: () => showHomeMenu(context),
                  ),
                  const SizedBox(width: Space.x2),
                  Expanded(child: Center(child: StatusStrip(online: state.online))),
                  const SizedBox(width: Space.x2),
                  AppIconButton(
                    icon: Icons.notifications_none,
                    semanticLabel: context.l10n.inboxTitle,
                    floating: true,
                    badgeCount: unread,
                    onPressed: () => openInbox(context).then((_) => ref.invalidate(unreadCountProvider)),
                  ),
                ],
              ),
            ),
            PositionedDirectional(
              bottom: Space.x4,
              end: Space.gutter,
              child: AppIconButton(
                icon: Icons.my_location,
                semanticLabel: context.l10n.actionRecentre,
                floating: true,
                onPressed: _position == null ? null : () => _map?.moveTo(_position!),
              ),
            ),
          ],
        ),
        panel: MapPanel(
          children: [
            TodayStats(today: state.today),
            const SizedBox(height: Space.x4),
            OnlineToggle(
              online: state.online,
              busy: state.switching || state.starting,
              onPressed: controller.toggle,
            ),
          ],
        ),
      ),
    );
  }
}
