import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../design/components/components.dart';
import '../../../../design/design_context.dart';
import '../../../../design/tokens/metrics.dart';

/// The big pill at the bottom of home: ink "go online", or gold "online" with "tap to
/// go offline" under it. Hopping dots while it switches.
class OnlineToggle extends StatelessWidget {
  const OnlineToggle({super.key, required this.online, required this.busy, required this.onPressed});

  final bool online;
  final bool busy;
  final VoidCallback? onPressed;

  static const double height = 64;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;
    final fill = online ? p.brand : p.ink;
    final text = online ? p.onBrand : p.onInk;
    const shape = StadiumBorder();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          toggled: online,
          child: Material(
            color: fill,
            shape: shape,
            child: InkWell(
              customBorder: shape,
              onTap: busy ? null : onPressed,
              child: SizedBox(
                height: height,
                child: Center(
                  child: busy
                      ? LoadingDots(color: text)
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (online) ...[
                              Container(
                                width: Space.x2,
                                height: Space.x2,
                                decoration: BoxDecoration(color: p.success, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: Space.x2),
                            ],
                            Text(online ? l10n.homeOnline : l10n.homeGoOnline,
                                style: context.typo.button.copyWith(color: text)),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
        if (online) ...[
          const SizedBox(height: Space.x2),
          Text(
            l10n.homeTapToGoOffline,
            textAlign: TextAlign.center,
            style: context.typo.caption.copyWith(color: p.textSecondary),
          ),
        ],
      ],
    );
  }
}
