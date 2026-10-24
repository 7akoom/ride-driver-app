import 'package:flutter/widgets.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../core/error/error_reporter.dart';
import '../../core/location/geo_point.dart';
import 'map_follow.dart';

/// Moves the map. Screens use this, never the plugin's controller.
class AppMapController {
  AppMapController(this._map);

  final MapLibreMapController _map;

  /// The street level the map opens on and returns to.
  static const double streetZoom = 16;

  /// One camera step of the following camera: as long as the GPS takes between two
  /// readings, so the map glides instead of jumping.
  static const Duration followStep = Duration(milliseconds: 950);

  /// The point in the middle of the map, when it is known.
  GeoPoint? get center {
    final target = _map.cameraPosition?.target;

    return target == null ? null : GeoPoint(target.latitude, target.longitude);
  }

  Future<void> moveTo(GeoPoint point, {double zoom = streetZoom}) =>
      _safely(() => _map.animateCamera(CameraUpdate.newLatLngZoom(LatLng(point.latitude, point.longitude), zoom)));

  /// The driving camera: on the car, the road ahead up.
  Future<void> follow(MapFollow follow) => _safely(() => _map.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(follow.at.latitude, follow.at.longitude),
          zoom: MapFollow.zoom,
          bearing: follow.bearing,
          tilt: MapFollow.tilt,
        )),
        duration: followStep,
      ));

  /// The part of the map the camera centres in: [insets] are covered by what is over
  /// the map (the turn card, the sheet).
  Future<void> inset(EdgeInsets insets) => _safely(() => _map.updateContentInsets(insets));

  /// Back to north up and flat, for showing a whole route.
  Future<void> level() => _safely(() => _map.animateCamera(CameraUpdate.bearingTo(0)).then((_) => _map.animateCamera(CameraUpdate.tiltTo(0))));

  Future<void> _safely(Future<Object?> Function() move) async {
    try {
      await move();
    } catch (error, stack) {
      // The map was closed or is not ready: moving it can wait for the next time.
      ErrorReporter.report(error, stack);
    }
  }
}
