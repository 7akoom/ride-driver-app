import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../design/components/components.dart';
import '../../../../design/design_context.dart';
import '../../../../design/tokens/metrics.dart';
import '../../../../state/api_providers.dart';
import '../you/you_step_screen.dart';

/// 04: what registering takes, before the form. "Use another number" signs out, for
/// someone who signed in with the wrong phone.
class JoinScreen extends ConsumerWidget {
  const JoinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return AppScaffold(
      bottomAction: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            label: l10n.joinStart,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const YouStepScreen()),
            ),
          ),
          const SizedBox(height: Space.x2),
          AppButton(
            label: l10n.joinOtherNumber,
            variant: AppButtonVariant.text,
            onPressed: () => signOut(ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.only(top: Space.x10),
        children: [
          const HeroIcon(icon: Icons.directions_car_filled_outlined),
          const SizedBox(height: Space.x6),
          Text(l10n.joinTitle, textAlign: TextAlign.center, style: context.typo.h1),
          const SizedBox(height: Space.x2),
          Text(
            l10n.joinSubtitle,
            textAlign: TextAlign.center,
            style: context.typo.body.copyWith(color: context.palette.textSecondary),
          ),
          const SizedBox(height: Space.x6),
          _Step(number: 1, text: l10n.joinStepDetails),
          _Step(number: 2, text: l10n.joinStepDocuments),
          _Step(number: 3, text: l10n.joinStepReview),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: Space.x2),
      child: Row(
        children: [
          Container(
            width: Sizes.avatar,
            height: Sizes.avatar,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: p.surface2, shape: BoxShape.circle),
            child: Text(number.toString(), style: context.typo.h3),
          ),
          const SizedBox(width: Space.x4),
          Expanded(child: Text(text, style: context.typo.body)),
        ],
      ),
    );
  }
}
