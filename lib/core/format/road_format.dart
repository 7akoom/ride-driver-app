import 'dart:math' as math;

import '../l10n/l10n.dart';
import '../routing/road_leg.dart';
import 'distance_format.dart';

/// Whole minutes for a time on the road, one at least.
int roadMinutes(Duration duration) => math.max(1, (duration.inSeconds / 60).ceil());

extension RoadTexts on AppLocalizations {
  /// "4 min · 1.2 km".
  String roadSpan(RoadLeg leg) => roadMinutesAndDistance(minutesCount(roadMinutes(leg.duration)), formatDistance(this, leg.distanceMeters));
}
