import 'package:flutter/material.dart';

import '../../design_context.dart';
import '../../tokens/metrics.dart';
import '../../tokens/shadows.dart';

/// A 44×44 rounded square with an icon: back, close, call, chat, map controls.
///
/// [semanticLabel] is required (and shown as a tooltip): an icon alone tells a screen
/// reader nothing.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.showBadge = false,
    this.badgeCount = 0,
    this.floating = false,
    this.filled = false,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;

  /// A small dot in the corner (unread messages, new notifications).
  final bool showBadge;

  /// A number in the corner instead of the dot (unread notifications); none at 0.
  final int badgeCount;

  /// Casts the floating shadow (buttons over the map).
  final bool floating;

  /// Brand-filled instead of surface (the main call button).
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final background = filled ? p.brand : p.surface;
    final foreground = filled ? p.onBrand : p.textPrimary;
    const radius = BorderRadius.all(Radius.circular(Radii.iconButton));

    return Tooltip(
      message: semanticLabel,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: background,
              borderRadius: radius,
              border: filled ? null : Border.all(color: p.border),
              boxShadow: floating ? Shadows.floating : Shadows.none,
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: radius,
                onTap: onPressed,
                child: SizedBox.square(
                  dimension: Sizes.iconButton,
                  child: Icon(icon, size: Sizes.iconSmall, color: foreground),
                ),
              ),
            ),
          ),
          if (badgeCount > 0)
            PositionedDirectional(
              top: -Space.x1,
              end: -Space.x1,
              child: _Count(count: badgeCount, border: background),
            )
          else if (showBadge)
            PositionedDirectional(
              top: Space.x1,
              end: Space.x1,
              child: _Dot(color: p.danger, border: background),
            ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.border});

  final Color color;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 2),
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.count, required this.border});

  final int count;
  final Color border;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Container(
      constraints: const BoxConstraints(minWidth: Space.x5),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: Space.x1),
      decoration: BoxDecoration(
        color: p.danger,
        borderRadius: const BorderRadius.all(Radius.circular(Radii.pill)),
        border: Border.all(color: border, width: 2),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        textAlign: TextAlign.center,
        style: context.typo.micro.copyWith(color: p.onInk),
      ),
    );
  }
}
