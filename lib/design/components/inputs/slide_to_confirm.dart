import 'package:flutter/material.dart';

import '../../design_context.dart';
import '../../tokens/metrics.dart';
import '../buttons/loading_dots.dart';

/// A step that must not happen by accident (starting or ending a trip, "the rider did
/// not come"): the knob is dragged from the start of the track to its end. Let go
/// before the end and it slides back. While [busy] the knob waits at the end with
/// hopping dots. [danger] paints it in the danger colour.
class SlideToConfirm extends StatefulWidget {
  const SlideToConfirm({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.busy = false,
    this.danger = false,
  });

  final String label;

  /// Null turns the slider off (greyed, the knob does not move).
  final VoidCallback? onConfirmed;
  final bool busy;
  final bool danger;

  static const double height = 64;

  /// How far the knob must go, as a share of its way, to count.
  static const double threshold = 0.9;

  @override
  State<SlideToConfirm> createState() => _SlideToConfirmState();
}

class _SlideToConfirmState extends State<SlideToConfirm> {
  double _progress = 0;
  bool _dragging = false;

  bool get _enabled => widget.onConfirmed != null && !widget.busy;

  void _drag(DragUpdateDetails details, double way) {
    if (!_enabled || way <= 0) {
      return;
    }

    final rtl = Directionality.of(context) == TextDirection.rtl;
    final delta = (rtl ? -details.delta.dx : details.delta.dx) / way;
    setState(() {
      _dragging = true;
      _progress = (_progress + delta).clamp(0, 1);
    });
  }

  void _release() {
    final confirmed = _enabled && _progress >= SlideToConfirm.threshold;
    setState(() {
      _dragging = false;
      _progress = 0;
    });

    if (confirmed) {
      widget.onConfirmed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fill = widget.danger ? p.dangerSoft : p.brandSoft;
    final knob = widget.danger ? p.danger : p.ink;
    final onKnob = p.onInk;
    const size = SlideToConfirm.height - Space.x2;

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      onTap: _enabled ? widget.onConfirmed : null,
      child: Opacity(
        opacity: widget.onConfirmed == null ? 0.5 : 1,
        child: LayoutBuilder(
          builder: (context, box) {
            final way = box.maxWidth - size - Space.x2;
            final at = widget.busy ? 1.0 : _progress;

            return Container(
              height: SlideToConfirm.height,
              decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(Radii.pill)),
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: size),
                      child: Opacity(
                        opacity: 1 - at,
                        child: Text(widget.label, style: context.typo.bodyStrong, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ),
                  AnimatedPositionedDirectional(
                    duration: _dragging ? Duration.zero : const Duration(milliseconds: 200),
                    top: Space.x1,
                    start: Space.x1 + way * at,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (d) => _drag(d, way),
                      onHorizontalDragEnd: (_) => _release(),
                      onHorizontalDragCancel: _release,
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(color: knob, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: widget.busy
                            ? LoadingDots(color: onKnob)
                            : Icon(Icons.arrow_forward, color: onKnob),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
