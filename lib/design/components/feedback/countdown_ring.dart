import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../design_context.dart';
import '../../tokens/metrics.dart';
import 'countdown_builder.dart';

/// Seconds left to answer, as a ring that empties in the brand colour with the number
/// inside (a trip offer). Read aloud as "12 seconds left".
class CountdownRing extends StatelessWidget {
  const CountdownRing({super.key, required this.until, required this.window, this.size = 56});

  final DateTime until;

  /// The whole time given, for the full circle.
  final Duration window;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return CountdownBuilder(
      until: until,
      builder: (context, remaining) {
        final seconds = remaining.inSeconds;
        final whole = window.inMilliseconds <= 0 ? 1 : window.inMilliseconds;

        return Semantics(
          label: context.l10n.secondsLeft('$seconds'),
          child: ExcludeSemantics(
            child: SizedBox.square(
              dimension: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.square(
                    dimension: size,
                    child: CircularProgressIndicator(
                      value: (remaining.inMilliseconds / whole).clamp(0, 1).toDouble(),
                      strokeWidth: Space.x1,
                      color: p.brand,
                      backgroundColor: p.onInk.withValues(alpha: 0.15),
                    ),
                  ),
                  Text(seconds.toString(), style: context.typo.h2.copyWith(color: p.onInk)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
