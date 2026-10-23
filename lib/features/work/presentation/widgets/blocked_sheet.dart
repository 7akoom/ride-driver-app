import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/format/money_format.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/location/location_access.dart';
import '../../../../core/location/location_providers.dart';
import '../../../../design/components/components.dart';
import '../../../../design/design_context.dart';
import '../../../../design/tokens/metrics.dart';
import '../../../documents/domain/entities/document_requirement.dart';
import '../../../documents/presentation/upload/upload_screen.dart';
import '../../domain/entities/online_block.dart';

/// 12: why the captain cannot go online, and the one thing that fixes it: the document
/// to upload again, the wallet to top up, or the location to allow.
Future<void> showBlockedSheet(BuildContext context, OnlineBlock block) => showAppSheet<void>(
      context: context,
      builder: (sheet) => _BlockedSheet(block: block),
    );

class _BlockedSheet extends ConsumerWidget {
  const _BlockedSheet({required this.block});

  final OnlineBlock block;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final block = this.block;
    final (icon, tone, title, body) = switch (block) {
      DocumentsBlock(:final requirement) => (
          Icons.badge_outlined,
          Tone.warning,
          l10n.blockedTitle,
          _documentText(context, requirement),
        ),
      WalletBlock(:final standing) => (
          Icons.account_balance_wallet_outlined,
          Tone.danger,
          l10n.blockedWalletTitle,
          l10n.blockedWalletBody(formatMoney(l10n, standing.balance), formatMoney(l10n, standing.amountDue)),
        ),
      LocationBlock(:final status) => (
          Icons.location_off_outlined,
          Tone.warning,
          status == LocationAccessStatus.serviceOff ? l10n.blockedLocationOffTitle : l10n.blockedLocationTitle,
          status == LocationAccessStatus.serviceOff ? l10n.blockedLocationOffBody : l10n.blockedLocationBody,
        ),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HeroIcon(icon: icon, tone: tone),
        const SizedBox(height: Space.x4),
        Text(title, textAlign: TextAlign.center, style: context.typo.h2),
        const SizedBox(height: Space.x2),
        Text(
          body,
          textAlign: TextAlign.center,
          style: context.typo.body.copyWith(color: context.palette.textSecondary),
        ),
        const SizedBox(height: Space.x5),
        ..._actions(context, ref),
      ],
    );
  }

  static String _documentText(BuildContext context, DocumentRequirement? requirement) {
    final l10n = context.l10n;
    if (requirement == null) {
      return l10n.blockedDocumentsBody;
    }

    final name = requirement.type.name.of(Localizations.localeOf(context).languageCode);

    return requirement.state == RequirementState.expired
        ? l10n.blockedDocumentExpired(name)
        : l10n.blockedDocumentMissing(name);
  }

  List<Widget> _actions(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final close = AppButton(
      label: l10n.actionClose,
      variant: AppButtonVariant.text,
      onPressed: () => Navigator.of(context).pop(),
    );

    return switch (block) {
      DocumentsBlock(requirement: final requirement?) => [
          AppButton(
            label: l10n.blockedDocumentUpdate,
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => UploadScreen(requirement: requirement)),
            ),
          ),
          close,
        ],
      LocationBlock(:final status) when status != LocationAccessStatus.denied => [
          AppButton(
            label: l10n.blockedOpenSettings,
            onPressed: () {
              final access = ref.read(locationAccessProvider);
              status == LocationAccessStatus.serviceOff ? access.openLocationSettings() : access.openSettings();
              Navigator.of(context).pop();
            },
          ),
          close,
        ],
      // Topping up comes with the wallet screens; until then the captain tops up at
      // the office.
      _ => [AppButton(label: l10n.actionClose, onPressed: () => Navigator.of(context).pop())],
    };
  }
}
