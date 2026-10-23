import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client_provider.dart';
import '../core/security/session_storage.dart';
import '../features/push/push_providers.dart';

/// The signed-in captain's verified phone number, in international form; null when the
/// identity has none.
final FutureProvider<String?> myPhoneProvider = FutureProvider<String?>((ref) async {
  final me = await ref.watch(apiClientProvider).get('/v1/me');

  if (me['identifiers'] case final List<dynamic> identifiers) {
    for (final item in identifiers) {
      if (item is Map && item['type'] == 'IDENTIFIER_TYPE_PHONE' && item['value'] is String) {
        return item['value'] as String;
      }
    }
  }

  return null;
});

/// Signs out: stops this phone getting the captain's notifications and tells the
/// backend (both best effort), forgets the session on the phone, and returns to the
/// phone number screen.
Future<void> signOut(WidgetRef ref) async {
  // First, while the session still works: whoever uses this phone next must not get
  // this captain's trip offers. A failure is a Result, never a throw.
  await ref.read(unregisterThisDeviceProvider).call();

  final refreshToken = await SessionStorage.readRefreshToken();

  if (refreshToken != null) {
    try {
      await ref.read(apiClientProvider).post(
        '/v1/auth/logout',
        auth: false,
        body: <String, dynamic>{'refreshToken': refreshToken},
      );
    } on Object {
      // Signing out must work with no connection too.
    }
  }

  await SessionStorage.clear();

  // The app listens to this: it opens the phone screen.
  ref.read(sessionEndedProvider.notifier).state++;
}
