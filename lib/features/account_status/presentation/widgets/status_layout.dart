import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../design/components/components.dart';
import '../../../../design/design_context.dart';
import '../../../../design/tokens/metrics.dart';
import '../../../../state/api_providers.dart';

/// The shape of the account-status screens: a large picture, a title, a sentence, any
/// extra content, and the screen's actions at the bottom. Signing out is at the top.
class StatusLayout extends ConsumerWidget {
  const StatusLayout({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.tone,
    this.extra = const [],
    this.actions = const [],
  });

  final IconData icon;
  final Tone? tone;
  final String title;
  final String message;
  final List<Widget> extra;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return AppScaffold(
      topBar: AppTopBar(
        showBack: false,
        actions: [
          AppIconButton(icon: Icons.logout, semanticLabel: l10n.signOut, onPressed: () => signOut(ref)),
        ],
      ),
      bottomAction: actions.isEmpty
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(height: Space.x2),
                  actions[i],
                ],
              ],
            ),
      body: ListView(
        padding: const EdgeInsetsDirectional.only(top: Space.x8),
        children: [
          HeroIcon(icon: icon, tone: tone),
          const SizedBox(height: Space.x6),
          Semantics(
            header: true,
            child: Text(title, textAlign: TextAlign.center, style: context.typo.h2),
          ),
          const SizedBox(height: Space.x2),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.typo.body.copyWith(color: context.palette.textSecondary),
          ),
          if (extra.isNotEmpty) const SizedBox(height: Space.x6),
          ...extra,
        ],
      ),
    );
  }
}
