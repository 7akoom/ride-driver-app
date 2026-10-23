import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../design/design_context.dart';
import '../../../../design/tokens/car_colors.dart';
import '../../../../design/tokens/metrics.dart';
import 'registration_messages.dart';

/// A row of swatches of the usual car colours. Tapping one fills the colour field with
/// its name; the field stays editable for anything else.
class CarColorPicker extends StatelessWidget {
  const CarColorPicker({super.key, required this.selectedName, required this.onPicked});

  /// The colour as typed; the swatch with that name is marked.
  final String selectedName;
  final ValueChanged<String> onPicked;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;

    return Wrap(
      spacing: Space.x3,
      runSpacing: Space.x3,
      children: [
        for (final color in CarColor.values)
          Semantics(
            button: true,
            selected: l10n.carColorName(color) == selectedName.trim(),
            label: l10n.carColorName(color),
            child: InkResponse(
              onTap: () => onPicked(l10n.carColorName(color)),
              radius: Sizes.touchTarget / 2,
              child: Container(
                width: Sizes.touchTarget - Space.x2,
                height: Sizes.touchTarget - Space.x2,
                decoration: BoxDecoration(
                  color: color.swatch,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: l10n.carColorName(color) == selectedName.trim() ? p.brandStrong : p.border,
                    width: l10n.carColorName(color) == selectedName.trim() ? 3 : 1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
