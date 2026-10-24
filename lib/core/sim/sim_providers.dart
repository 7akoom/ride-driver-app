import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_env.dart';
import '../location/geo_point.dart';
import 'sim_drive.dart';

/// The self-driving car of a development build with SIM_DRIVE; null otherwise (always
/// in release builds).
final simDriveProvider = Provider<SimDrive?>((ref) {
  if (!AppEnv.simDrive) {
    return null;
  }

  final sim = SimDrive(GeoPoint.tryParse(AppEnv.mapCenter) ?? const GeoPoint(36.1911, 44.0092));
  ref.onDispose(sim.stop);

  return sim;
});
