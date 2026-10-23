import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../design_context.dart';
import '../../tokens/metrics.dart';

/// Where a multi-step form is: one bar per step, the done and current ones in the
/// brand colour. Read aloud as "step 2 of 3".
class StepDots extends StatelessWidget {
  const StepDots({super.key, required this.current, required this.count});

  /// 1-based.
  final int current;
  final int count;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Semantics(
      label: context.l10n.stepOf('$current', '$count'),
      child: ExcludeSemantics(
        child: Row(
          children: [
            for (var step = 1; step <= count; step++) ...[
              if (step > 1) const SizedBox(width: Space.x2),
              Expanded(
                child: Container(
                  height: Space.x1,
                  decoration: BoxDecoration(
                    color: step <= current ? p.brand : p.surface2,
                    borderRadius: const BorderRadius.all(Radius.circular(Radii.pill)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
