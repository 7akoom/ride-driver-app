import 'package:flutter/material.dart';

import '../../../../core/format/bidi.dart';
import '../../../../core/format/duration_format.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../design/design_context.dart';
import '../../../../design/tokens/metrics.dart';

/// The big round clock at the pickup: the free waiting left as a ring emptying in the
/// brand colour, then, once it is over, how long the captain has waited in all.
class WaitTimer extends StatelessWidget {
  const WaitTimer({super.key, required this.waited, required this.free});

  /// Since the captain arrived.
  final Duration waited;

  /// The free waiting of the trip's rate card (zero: none).
  final Duration free;

  static const double size = 168;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;
    final left = free - waited;
    final inFree = free > Duration.zero && left > Duration.zero;
    final share = inFree ? left.inMilliseconds / free.inMilliseconds : 1.0;

    return Center(
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.square(
              dimension: size,
              child: CircularProgressIndicator(
                value: share.clamp(0, 1).toDouble(),
                strokeWidth: Space.x2,
                color: inFree ? p.brandStrong : p.textTertiary,
                backgroundColor: p.surface2,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isolateLtr(formatCountdown(inFree ? left : waited)), style: context.typo.display),
                Text(
                  inFree ? l10n.tripFreeWaiting : l10n.tripWaited,
                  style: context.typo.caption.copyWith(color: p.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
