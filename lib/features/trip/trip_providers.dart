import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/captain/captain_providers.dart';
import '../../core/network/api_client_provider.dart';
import 'data/trip_api.dart';
import 'data/trip_repository_impl.dart';
import 'domain/repositories/trip_repository.dart';
import 'domain/use_cases/trip_actions.dart';

// The feature's wiring. Tests override the repository.

final tripRepositoryProvider = Provider<TripRepository>(
  (ref) => TripRepositoryImpl(TripApi(ref.watch(apiClientProvider)), ref.watch(captainAccountRepositoryProvider)),
);

final tripActionsProvider = Provider<TripActions>((ref) => TripActions(ref.watch(tripRepositoryProvider)));

/// How often the trip is read again while it is open. Tests shorten it.
final tripCheckIntervalProvider = Provider<Duration>((ref) => const Duration(seconds: 4));
