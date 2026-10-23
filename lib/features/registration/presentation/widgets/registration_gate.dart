import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../design/components/components.dart';
import '../registration_controller.dart';

/// Shows a registration step once the form is loaded (a form being corrected loads
/// what was given): a form-shaped placeholder until then, or the failure with "try
/// again".
class RegistrationGate extends ConsumerWidget {
  const RegistrationGate({super.key, required this.builder});

  final Widget Function(RegistrationForm form) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(registrationFormProvider);
    final loaded = form.valueOrNull;

    if (loaded != null) {
      return builder(loaded);
    }

    final error = form.error;

    return AppScaffold(
      topBar: AppTopBar(title: context.l10n.registerTitle),
      body: error == null
          ? const SkeletonForm()
          : FailureView(
              failure: error is Failure ? error : const UnexpectedFailure(),
              onRetry: () => ref.invalidate(registrationFormProvider),
            ),
    );
  }
}
