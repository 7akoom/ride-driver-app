import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client_provider.dart' as current;
import '../../state/api_providers.dart' as current_state;
import '../core/api/api_client.dart';
import '../core/api/api_exception.dart';
import '../core/api/driver_api.dart';
import '../core/api/maps_api.dart';
import '../core/api/money_api.dart';
import '../core/api/trip_api.dart';
import '../core/models/driver_profile.dart';
import 'session_storage.dart';

// The providers the old home and trip screens use. They all go through the app's one
// API client (lib/core/network); signing out and an ended session are handled by the
// app shell, which opens the new phone screen.

final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(current.apiClientProvider));
});

final Provider<DriverApi> driverApiProvider = Provider<DriverApi>((ref) {
  return DriverApi(ref.watch(apiClientProvider));
});

final Provider<TripApi> tripApiProvider = Provider<TripApi>((ref) {
  return TripApi(ref.watch(apiClientProvider));
});

final Provider<MapsApi> mapsApiProvider = Provider<MapsApi>((ref) {
  return MapsApi(ref.watch(apiClientProvider));
});

final Provider<MoneyApi> moneyApiProvider = Provider<MoneyApi>((ref) {
  return MoneyApi(ref.watch(apiClientProvider));
});

/// The signed-in driver's profile (null if there is none yet).
final FutureProvider<DriverProfile?> driverProfileProvider = FutureProvider<DriverProfile?>((ref) async {
  final identityId = await SessionStorage.readIdentityId();
  if (identityId == null) {
    return null;
  }

  return ref.watch(driverApiProvider).getByIdentity(identityId);
});

/// Whether the driver may take trips right now (null if the backend cannot say).
final FutureProvider<DriverStanding?> standingProvider = FutureProvider<DriverStanding?>((ref) async {
  final driverId = await SessionStorage.readDriverId();
  if (driverId == null) {
    return null;
  }

  try {
    return await ref.watch(driverApiProvider).standing(driverId);
  } on ApiException {
    return null;
  }
});

/// Signs out through the app's own sign-out, after forgetting the old screens' data.
Future<void> signOut(WidgetRef ref) async {
  ref.invalidate(driverProfileProvider);
  ref.invalidate(standingProvider);

  await current_state.signOut(ref);
}
