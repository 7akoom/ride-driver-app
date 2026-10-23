import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../design/components/components.dart';
import '../../../../design/design_context.dart';
import '../../../../design/tokens/metrics.dart';
import '../../domain/values/nationalities.dart';
import 'registration_messages.dart';

/// The nationality, picked from a sheet of the offered countries.
class NationalityField extends StatelessWidget {
  const NationalityField({super.key, required this.code, required this.onChanged, this.error});

  final String code;
  final String? error;
  final ValueChanged<String> onChanged;

  Future<void> _pick(BuildContext context) async {
    final l10n = context.l10n;
    final picked = await showAppSheet<String>(
      context: context,
      builder: (sheet) => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetTitle(title: l10n.registerNationality, onClose: () => Navigator.of(sheet).pop()),
            for (final option in offeredNationalities) ...[
              AppRadioTile(
                title: l10n.nationalityName(option),
                selected: option == code,
                onTap: () => Navigator.of(sheet).pop(option),
              ),
              const SizedBox(height: Space.x2),
            ],
          ],
        ),
      ),
    );

    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.registerNationality, style: context.typo.caption.copyWith(color: context.palette.textSecondary)),
        const SizedBox(height: Space.x2),
        Semantics(
          button: true,
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(Radii.input)),
            onTap: () => _pick(context),
            child: InputDecorator(
              decoration: InputDecoration(errorText: error, suffixIcon: const Icon(Icons.expand_more)),
              child: Text(code.isEmpty ? '' : l10n.nationalityName(code), style: context.typo.body),
            ),
          ),
        ),
      ],
    );
  }
}
