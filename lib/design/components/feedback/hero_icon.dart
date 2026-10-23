import 'package:flutter/material.dart';

import '../../design_context.dart';
import '../../tokens/metrics.dart';
import 'tone.dart';

/// The large round picture at the top of an explaining screen (under review, approved,
/// rejected). A null [tone] uses the brand colours.
class HeroIcon extends StatelessWidget {
  const HeroIcon({super.key, required this.icon, this.tone});

  final IconData icon;
  final Tone? tone;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final tone = this.tone;

    return ExcludeSemantics(
      child: Center(
        child: Container(
          width: Sizes.hero,
          height: Sizes.hero,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: tone == null ? p.brandSoft : tone.background(p),
          ),
          child: Icon(
            icon,
            size: Sizes.heroIcon,
            color: tone == null ? p.brandStrong : tone.foreground(p),
          ),
        ),
      ),
    );
  }
}
