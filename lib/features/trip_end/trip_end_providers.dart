import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/captain/captain_providers.dart';
import '../../core/network/api_client_provider.dart';
import 'data/trip_end_api.dart';
import 'data/trip_end_repository_impl.dart';
import 'domain/repositories/trip_end_repository.dart';

// The feature's wiring. Tests override the repository.

final tripEndRepositoryProvider = Provider<TripEndRepository>(
  (ref) => TripEndRepositoryImpl(TripEndApi(ref.watch(apiClientProvider)), ref.watch(captainAccountRepositoryProvider)),
);

/// How long to wait between asks while the trip is being settled. Tests shorten it.
final settlementRetryProvider = Provider<Duration>((ref) => const Duration(seconds: 2));
