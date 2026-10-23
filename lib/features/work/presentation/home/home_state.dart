import '../../../../core/error/failure.dart';
import '../../domain/entities/online_block.dart';
import '../../domain/entities/today_summary.dart';

/// What the home screen shows.
final class HomeState {
  const HomeState({
    this.starting = true,
    this.online = false,
    this.switching = false,
    this.today,
    this.block,
    this.failure,
  });

  /// Finding out how the captain stands when the screen opens.
  final bool starting;
  final bool online;

  /// Going online or offline right now.
  final bool switching;

  /// Null until known (a failed read shows nothing, not zeros).
  final TodaySummary? today;

  /// Why the last try to go online did not work; null once dealt with.
  final OnlineBlock? block;

  /// A failure to show once (going online or offline failed).
  final Failure? failure;

  HomeState copyWith({
    bool? starting,
    bool? online,
    bool? switching,
    TodaySummary? today,
    OnlineBlock? block,
    Failure? failure,
    bool clearBlock = false,
    bool clearFailure = false,
  }) =>
      HomeState(
        starting: starting ?? this.starting,
        online: online ?? this.online,
        switching: switching ?? this.switching,
        today: today ?? this.today,
        block: clearBlock ? null : block ?? this.block,
        failure: clearFailure ? null : failure ?? this.failure,
      );
}
