import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/format/bidi.dart';
import '../../../../core/instance/instance_info.dart';
import '../../../../core/instance/instance_info_provider.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../design/components/components.dart';
import '../../../../design/design_context.dart';
import '../../../../design/tokens/metrics.dart';

/// The country's emergency numbers from the copy's settings, each a tap away from
/// the phone's dialler; nothing when none are set.
class EmergencyNumbers extends ConsumerWidget {
  const EmergencyNumbers({super.key});

  static String label(AppLocalizations l10n, EmergencyKind kind) => switch (kind) {
        EmergencyKind.general => l10n.emergencyGeneral,
        EmergencyKind.police => l10n.emergencyPolice,
        EmergencyKind.ambulance => l10n.emergencyAmbulance,
        EmergencyKind.fire => l10n.emergencyFire,
      };

  static IconData _icon(EmergencyKind kind) => switch (kind) {
        EmergencyKind.general => Icons.sos_outlined,
        EmergencyKind.police => Icons.local_police_outlined,
        EmergencyKind.ambulance => Icons.emergency_outlined,
        EmergencyKind.fire => Icons.local_fire_department_outlined,
      };

  static void _call(String number) => unawaited(launchUrl(Uri(scheme: 'tel', path: number)));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final numbers = ref.watch(instanceInfoProvider).valueOrNull?.emergency ?? const <EmergencyNumber>[];

    if (numbers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: Space.x6),
        Text(l10n.emergencyNumbersTitle, style: context.typo.h3),
        const SizedBox(height: Space.x1),
        Text(l10n.emergencyNumbersHint, style: context.typo.caption.copyWith(color: context.palette.textSecondary)),
        const SizedBox(height: Space.x2),
        for (final n in numbers)
          AppListRow(
            icon: _icon(n.kind),
            title: label(l10n, n.kind),
            subtitle: isolateLtr(n.number),
            showChevron: false,
            trailing: Icon(Icons.call_outlined, color: context.palette.brandStrong),
            onTap: () => _call(n.number),
          ),
      ],
    );
  }
}
