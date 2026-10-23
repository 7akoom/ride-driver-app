import 'package:flutter/material.dart';

import '../../../../core/format/vehicle_label.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../design/components/components.dart';
import '../../../../design/design_context.dart';
import '../../../../design/tokens/metrics.dart';
import '../../domain/entities/registration_draft.dart';

/// The class the captain registers the car in. The reviewer may change it.
class VehicleClassOptions extends StatelessWidget {
  const VehicleClassOptions({super.key, required this.selected, required this.onSelected});

  final VehicleClass selected;
  final ValueChanged<VehicleClass> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.registerVehicleClass, style: context.typo.caption.copyWith(color: context.palette.textSecondary)),
        const SizedBox(height: Space.x2),
        for (final option in VehicleClass.values) ...[
          AppRadioTile(
            title: vehicleLabel(l10n, option.code),
            selected: option == selected,
            onTap: () => onSelected(option),
          ),
          const SizedBox(height: Space.x2),
        ],
        Text(
          l10n.registerVehicleClassHint,
          style: context.typo.caption.copyWith(color: context.palette.textTertiary),
        ),
      ],
    );
  }
}
