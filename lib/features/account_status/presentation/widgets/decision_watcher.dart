import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../onboarding/domain/entities/next_step.dart';
import '../../../onboarding/presentation/onboarding_navigation.dart';
import '../../../onboarding/presentation/splash/start_step_provider.dart';

/// Asks again where the account stands while a waiting screen is open (every minute,
/// and each time the app comes back to the front), and moves on by itself when the
/// reviewer has decided. A failed check changes nothing: the next one tries again.
class DecisionWatcher extends ConsumerStatefulWidget {
  const DecisionWatcher({super.key, required this.waitingFor, required this.child});

  /// The step this screen shows; any other answer opens its screen.
  final NextStep waitingFor;
  final Widget child;

  static const Duration interval = Duration(minutes: 1);

  @override
  ConsumerState<DecisionWatcher> createState() => _DecisionWatcherState();
}

class _DecisionWatcherState extends ConsumerState<DecisionWatcher> with WidgetsBindingObserver {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(DecisionWatcher.interval, (_) => _check());
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _check();
    }
  }

  void _check() => ref.invalidate(currentStepProvider);

  @override
  Widget build(BuildContext context) {
    ref.listen(currentStepProvider, (_, next) {
      final step = next.valueOrNull?.fold((step) => step, (_) => null);

      if (step != null && step != widget.waitingFor && step != NextStep.checkAgain) {
        openStep(context, step);
      }
    });

    return widget.child;
  }
}
