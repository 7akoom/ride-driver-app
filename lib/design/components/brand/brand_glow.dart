import 'package:flutter/material.dart';

import '../../design_context.dart';

/// A soft light in the brand colour behind [child] (the mark on the start screen, the
/// hero card of earnings and the wallet). The only gradient the design allows.
class BrandGlow extends StatelessWidget {
  const BrandGlow({super.key, required this.child, this.radius = 160});

  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final brand = context.palette.brand;

    return Stack(
      alignment: Alignment.center,
      children: [
        IgnorePointer(
          child: Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [brand.withValues(alpha: 0.28), brand.withValues(alpha: 0)],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
