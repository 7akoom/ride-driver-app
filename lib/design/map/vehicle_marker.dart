import 'package:maplibre_gl/maplibre_gl.dart';

import '../../core/location/geo_point.dart';
import '../tokens/palette.dart';
import 'car_icon.dart';
import 'path_trim.dart';

/// The captain's car on a map: a car picture turned the way it drives.
final class VehicleMarker {
  VehicleMarker(this._map, this._palette, this._pixelRatio);

  final MapLibreMapController _map;
  final Palette _palette;
  final double _pixelRatio;
  Symbol? _symbol;
  GeoPoint? _at;
  double _bearing = 0;
  bool _prepared = false;

  static const String _image = 'ride-car';

  /// How big the car is on screen, in logical pixels.
  static const double size = 40;

  /// Where the car is drawn now, if it is.
  GeoPoint? get at => _at;

  /// Gives the map the car's picture; once per map style.
  Future<void> prepare() async {
    if (_prepared) {
      return;
    }

    await _map.addImage(_image, await carIconPng(_palette, size * _pixelRatio));
    _prepared = true;
  }

  /// Puts the car at [point], turned towards where it came from, or takes it off.
  /// [mapBearing] is how the map itself is turned (the driving camera turns it): the
  /// picture turns by the difference, as it is drawn upright on the screen.
  /// [upright]: the map is turned with the road ahead up (the driving camera), so the
  /// car is drawn pointing up, steady whatever the GPS does.
  Future<void> place(GeoPoint? point, {double mapBearing = 0, bool upright = false}) async {
    final symbol = _symbol;
    final before = _at;

    if (point == null) {
      _symbol = null;
      _at = null;
      if (symbol != null) {
        await _map.removeSymbol(symbol);
      }
      return;
    }

    // A car that barely moved keeps its heading: GPS noise would spin it.
    if (before != null && metresBetween(before, point) > 3) {
      _bearing = bearingBetween(before, point);
    }

    _at = point;
    final options = SymbolOptions(
      geometry: LatLng(point.latitude, point.longitude),
      iconImage: _image,
      iconRotate: upright ? 0 : (_bearing - mapBearing + 360) % 360,
      iconSize: 1,
    );

    if (symbol == null) {
      _symbol = await _map.addSymbol(options);
    } else {
      await _map.updateSymbol(symbol, options);
    }
  }
}
