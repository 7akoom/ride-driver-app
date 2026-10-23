import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/captain/captain_providers.dart';
import '../../../core/l10n/l10n.dart';
import '../../../design/components/components.dart';
import '../../onboarding/onboarding_providers.dart';
import '../../onboarding/presentation/onboarding_navigation.dart';
import 'widgets/status_layout.dart';

/// 09c: shown once, the first time the app opens after approval.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _starting = false;

  Future<void> _start() async {
    setState(() => _starting = true);

    final account = await ref.read(myCaptainAccountProvider.future).catchError((Object _) => null);
    final next = await ref.read(finishWelcomeProvider).call(account?.id ?? '');

    if (mounted) {
      openStep(context, next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Loaded while the captain reads, for the button (and kept alive until then).
    ref.watch(myCaptainAccountProvider);

    return StatusLayout(
      icon: Icons.check_circle_outline,
      tone: Tone.success,
      title: l10n.welcomeTitle,
      message: l10n.welcomeMessage,
      actions: [AppButton(label: l10n.welcomeStart, loading: _starting, onPressed: _start)],
    );
  }
}
