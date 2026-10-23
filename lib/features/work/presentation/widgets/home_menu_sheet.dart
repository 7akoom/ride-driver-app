import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../design/components/components.dart';
import '../../../../state/api_providers.dart';
import '../../../settings/presentation/appearance_sheet.dart';
import '../../work_providers.dart';

/// The few account actions home needs until the account tab is built (batch 6): the
/// language and appearance, and signing out (offline first, so the platform stops
/// counting on this phone).
Future<void> showHomeMenu(BuildContext context) => showAppSheet<void>(
      context: context,
      builder: (sheet) => const _HomeMenu(),
    );

class _HomeMenu extends ConsumerWidget {
  const _HomeMenu();

  Future<void> _signOut(WidgetRef ref) async {
    if (ref.read(positionReporterProvider).running) {
      await ref.read(goOfflineProvider).call();
    }

    await signOut(ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppListRow(
          icon: Icons.language,
          title: l10n.languageTitle,
          onTap: () {
            Navigator.of(context).pop();
            showAppearanceSheet(context);
          },
        ),
        AppListRow(
          icon: Icons.logout,
          title: l10n.signOut,
          destructive: true,
          showChevron: false,
          onTap: () => _signOut(ref),
        ),
      ],
    );
  }
}
