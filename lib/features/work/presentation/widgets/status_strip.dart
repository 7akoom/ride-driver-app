import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../design/design_context.dart';
import '../../../../design/tokens/metrics.dart';
import '../../../../design/tokens/shadows.dart';

/// The slim bar at the top of the home map: ink "offline" with a grey dot, or gold
/// "online, looking for trips" with a dot.
class StatusStrip extends StatelessWidget {
  const StatusStrip({super.key, required this.online});

  final bool online;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;
    final fill = online ? p.brand : p.ink;
    final text = online ? p.onBrand : p.onInk;

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: Space.x4, vertical: Space.x2),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: const BorderRadius.all(Radius.circular(Radii.pill)),
          boxShadow: Shadows.floating,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: Space.x2,
              height: Space.x2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: online ? p.success : text.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: Space.x2),
            Flexible(
              child: Text(
                online ? l10n.homeOnlineSearching : l10n.homeOffline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.typo.caption.copyWith(color: text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
