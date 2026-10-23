import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_locales.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/language_names.dart';
import '../../../design/components/components.dart';
import '../../../design/design_context.dart';
import '../../../design/tokens/metrics.dart';
import '../../../state/locale_provider.dart';
import '../../../state/theme_provider.dart';
import 'appearance_controller.dart';

/// 17: the language (each written in itself) and the appearance (light, dark, or the
/// phone's own setting). A choice applies at once; there is nothing to save.
Future<void> showAppearanceSheet(BuildContext context) => showAppSheet<void>(
      context: context,
      builder: (sheet) => const _AppearanceSheet(),
    );

class _AppearanceSheet extends ConsumerWidget {
  const _AppearanceSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final controller = ref.read(appearanceControllerProvider);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetTitle(title: l10n.languageTitle, onClose: () => Navigator.of(context).pop()),
          for (final option in AppLocales.all) ...[
            AppRadioTile(
              title: languageNameOf(l10n, option),
              selected: option.languageCode == locale.languageCode,
              onTap: () => controller.pickLanguage(option),
            ),
            const SizedBox(height: Space.x2),
          ],
          const SizedBox(height: Space.x4),
          SectionHeader(title: l10n.appearanceTitle),
          AppChoiceChips<ThemeMode>(
            options: [
              (ThemeMode.light, l10n.appearanceLight),
              (ThemeMode.dark, l10n.appearanceDark),
              (ThemeMode.system, l10n.appearanceSystem),
            ],
            selected: themeMode,
            onSelected: controller.pickThemeMode,
          ),
          const SizedBox(height: Space.x2),
          Text(
            l10n.appearanceSystemHint,
            style: context.typo.caption.copyWith(color: context.palette.textTertiary),
          ),
        ],
      ),
    );
  }
}
