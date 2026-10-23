import 'package:flutter/material.dart';

import '../../design_context.dart';
import '../../tokens/metrics.dart';
import 'tone.dart';

/// A short status in a tinted pill: "under review", "approved", "missing". A null
/// [tone] is the neutral grey (nothing done yet).
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, this.tone});

  final String label;
  final Tone? tone;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final tone = this.tone;

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: Space.x2, vertical: Space.x1),
      decoration: BoxDecoration(
        color: tone == null ? p.surface2 : tone.background(p),
        borderRadius: const BorderRadius.all(Radius.circular(Radii.pill)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.typo.micro.copyWith(color: tone == null ? p.textSecondary : tone.foreground(p)),
      ),
    );
  }
}
