import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/result.dart';
import '../../domain/repositories/position_reporter.dart';
import '../../work_providers.dart';
import 'home_state.dart';

final homeControllerProvider = NotifierProvider.autoDispose<HomeController, HomeState>(HomeController.new);

/// The home screen's actions: picking up where the captain was when the app opens,
/// going online and offline, and today's numbers.
class HomeController extends AutoDisposeNotifier<HomeState> {
  ReportingNotice? _notice;

  @override
  HomeState build() => const HomeState();

  /// Finds out how the captain stands. Returns the trip under way, to open it again.
  Future<String?> start(ReportingNotice notice) async {
    _notice = notice;
    unawaited(refreshToday());

    final result = await ref.read(resumeWorkProvider).call(notice);

    return result.fold(
      (start) {
        state = state.copyWith(starting: false, online: start.online);

        return start.tripId;
      },
      (failure) {
        state = state.copyWith(starting: false, failure: failure);

        return null;
      },
    );
  }

  /// Today's earnings and trips (again after each trip). A failure leaves what was
  /// shown.
  Future<void> refreshToday() async {
    if (await ref.read(workRepositoryProvider).today() case Ok(:final value)) {
      state = state.copyWith(today: value);
    }
  }

  Future<void> toggle() async {
    final notice = _notice;
    if (state.switching || state.starting || notice == null) {
      return;
    }

    state = state.copyWith(switching: true, clearBlock: true, clearFailure: true);

    if (state.online) {
      final result = await ref.read(goOfflineProvider).call();
      state = result.fold(
        (_) => state.copyWith(switching: false, online: false),
        (failure) => state.copyWith(switching: false, failure: failure),
      );

      return;
    }

    final result = await ref.read(goOnlineProvider).call(notice);
    state = result.fold(
      (block) => state.copyWith(switching: false, online: block == null, block: block),
      (failure) => state.copyWith(switching: false, failure: failure),
    );
  }

  void dismissBlock() => state = state.copyWith(clearBlock: true);

  void dismissFailure() => state = state.copyWith(clearFailure: true);
}
