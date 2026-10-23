import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../state/locale_provider.dart';
import '../push_providers.dart';

/// Keeps this phone registered for the signed-in captain's notifications while the
/// signed-in app is open: once when it opens, again when the push token changes, and
/// again when the captain changes the language (notifications are written in it).
///
/// Silent: a failure shows nothing and is tried again the next time the app opens.
class PushRegistrar extends ConsumerStatefulWidget {
  const PushRegistrar({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PushRegistrar> createState() => _PushRegistrarState();
}

class _PushRegistrarState extends ConsumerState<PushRegistrar> {
  StreamSubscription<void>? _tokenChanges;

  @override
  void initState() {
    super.initState();
    _tokenChanges = ref.read(registerThisDeviceProvider).tokenChanged.listen((_) => _register());
    unawaited(_register());
  }

  @override
  void dispose() {
    _tokenChanges?.cancel();
    super.dispose();
  }

  Future<void> _register() async {
    if (!mounted) {
      return;
    }

    // The result is not shown: guard() already reported anything unexpected.
    await ref.read(registerThisDeviceProvider).call(ref.read(localeProvider).languageCode);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(localeProvider, (previous, next) {
      if (previous?.languageCode != next.languageCode) {
        unawaited(_register());
      }
    });

    return widget.child;
  }
}
