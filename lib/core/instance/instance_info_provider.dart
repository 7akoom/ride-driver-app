import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_env.dart';
import '../error/guard.dart';
import '../error/result.dart';
import '../network/api_client_provider.dart';
import 'instance_info.dart';

/// The copy's pages and emergency numbers. When the server cannot be reached, the
/// build's pages and no numbers: nothing here is worth an error on screen.
final instanceInfoProvider = FutureProvider.autoDispose<InstanceInfo>((ref) async {
  final result = await guard(() => ref.watch(apiClientProvider).get('/v1/support/instance-info'));

  return switch (result) {
    Ok(:final value) =>
      InstanceInfo.fromJson(value, fallbackTerms: AppEnv.termsUrl, fallbackPrivacy: AppEnv.privacyUrl),
    Err() => const InstanceInfo(termsUrl: AppEnv.termsUrl, privacyUrl: AppEnv.privacyUrl),
  };
});
