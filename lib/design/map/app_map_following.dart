part of 'app_map.dart';

/// The driving camera of [AppMap]: following the car, the room kept over and under it,
/// and letting go when the captain moves the map with a finger.
mixin _Following on State<AppMap> {
  AppMapController? get _controller;
  bool get _styleReady;

  EdgeInsets _insets = EdgeInsets.zero;
  Offset? _down;

  /// A finger moving this far is the captain moving the map, not a tap.
  static const double _dragSlop = 16;

  Future<void> _drawRoute(MapLayers layers, MapRoute route) async {
    final following = widget.follow != null;

    // Framing a whole route needs the whole map, north up and flat: the driving
    // camera's insets, turn and tilt go.
    if (!following && _insets != EdgeInsets.zero) {
      await _controller?.level();
      await _inset(EdgeInsets.zero);
    }

    await layers.draw(route, car: widget.vehicle, bottom: widget.frameBottom, frame: !following, mapBearing: widget.follow?.bearing ?? 0);
  }

  void _followCar() {
    final controller = _controller;
    final follow = widget.follow;

    if (controller == null || follow == null || !_styleReady) {
      return;
    }

    unawaited(() async {
      await _inset(EdgeInsets.only(top: follow.top, bottom: widget.frameBottom));
      await controller.follow(follow);
    }());
  }

  Future<void> _inset(EdgeInsets insets) async {
    final controller = _controller;

    if (controller == null || insets == _insets) {
      return;
    }

    _insets = insets;
    await controller.inset(insets);
  }

  void _pointerMoved(PointerMoveEvent event) {
    final down = _down;

    if (down != null && (event.position - down).distance > _dragSlop) {
      _down = null;
      widget.onDragged?.call();
    }
  }
}
