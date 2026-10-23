import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/captain/captain_providers.dart';
import '../../core/network/api_client_provider.dart';
import 'data/push_api.dart';
import 'data/push_repository_impl.dart';
import 'data/push_token_source.dart';
import 'domain/repositories/push_repository.dart';
import 'domain/use_cases/device_registration.dart';

// The push feature's wiring. Tests override pushRepositoryProvider.

final pushRepositoryProvider = Provider<PushRepository>(
  (ref) => PushRepositoryImpl(
    PushApi(ref.watch(apiClientProvider)),
    ref.watch(captainAccountRepositoryProvider),
    const PushTokenSource(),
  ),
);

final registerThisDeviceProvider = Provider<RegisterThisDevice>(
  (ref) => RegisterThisDevice(ref.watch(pushRepositoryProvider)),
);

final unregisterThisDeviceProvider = Provider<UnregisterThisDevice>(
  (ref) => UnregisterThisDevice(ref.watch(pushRepositoryProvider)),
);

final incomingPushesProvider = Provider<IncomingPushes>(
  (ref) => IncomingPushes(ref.watch(pushRepositoryProvider)),
);
