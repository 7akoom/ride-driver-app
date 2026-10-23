import 'package:flutter/material.dart';

import '../../tokens/metrics.dart';

/// A row of pills any number of which can be on (tags). Wraps to a new line when
/// they don't fit; looks like [AppChoiceChips].
class AppMultiChips<T> extends StatelessWidget {
  const AppMultiChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onToggled,
  });

  /// Each option's value and its (translated) label.
  final List<(T, String)> options;
  final Set<T> selected;
  final ValueChanged<T> onToggled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Space.x2,
      runSpacing: Space.x2,
      children: [
        for (final (value, label) in options)
          FilterChip(
            label: Text(label),
            selected: selected.contains(value),
            showCheckmark: false,
            onSelected: (_) => onToggled(value),
          ),
      ],
    );
  }
}
