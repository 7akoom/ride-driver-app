import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/time/calendar_date.dart';
import '../../design_context.dart';
import '../../tokens/metrics.dart';
import 'western_digits_formatter.dart';

/// A date typed as day, month and year in three small boxes, written left to right
/// with Western digits in every language (21 / 10 / 1990). The cursor moves on by
/// itself. [onChanged] gets the date once it is a real day, else null.
class DateFields extends StatefulWidget {
  const DateFields({super.key, required this.label, required this.onChanged, this.initial, this.error});

  final String label;
  final CalendarDate? initial;
  final String? error;
  final ValueChanged<CalendarDate?> onChanged;

  @override
  State<DateFields> createState() => _DateFieldsState();
}

class _DateFieldsState extends State<DateFields> {
  late final List<TextEditingController> _parts;
  final List<FocusNode> _focus = List.generate(3, (_) => FocusNode());

  static const List<int> _lengths = [2, 2, 4];

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _parts = [
      TextEditingController(text: initial == null ? '' : initial.day.toString().padLeft(2, '0')),
      TextEditingController(text: initial == null ? '' : initial.month.toString().padLeft(2, '0')),
      TextEditingController(text: initial == null ? '' : '${initial.year}'),
    ];
  }

  @override
  void dispose() {
    for (final controller in _parts) {
      controller.dispose();
    }
    for (final node in _focus) {
      node.dispose();
    }
    super.dispose();
  }

  void _changed(int index) {
    if (_parts[index].text.length == _lengths[index] && index < 2) {
      _focus[index + 1].requestFocus();
    }

    final values = _parts.map((part) => int.tryParse(part.text)).toList();
    final complete = _parts[2].text.length == 4 && values.every((value) => value != null);

    widget.onChanged(complete ? CalendarDate.of(values[2]!, values[1]!, values[0]!) : null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hints = [l10n.dateDay, l10n.dateMonth, l10n.dateYear];
    final error = widget.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.label, style: context.typo.caption.copyWith(color: context.palette.textSecondary)),
        const SizedBox(height: Space.x2),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: Space.x2),
                Expanded(
                  flex: _lengths[i],
                  child: TextField(
                    controller: _parts[i],
                    focusNode: _focus[i],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    textInputAction: i < 2 ? TextInputAction.next : TextInputAction.done,
                    inputFormatters: [WesternDigitsFormatter(maxLength: _lengths[i])],
                    style: context.typo.body,
                    decoration: InputDecoration(hintText: hints[i], errorText: error == null ? null : ''),
                    onChanged: (_) => _changed(i),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: Space.x1),
          Text(error, style: context.typo.caption.copyWith(color: context.palette.danger)),
        ],
      ],
    );
  }
}
