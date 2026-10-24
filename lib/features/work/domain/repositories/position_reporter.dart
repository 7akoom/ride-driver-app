import '../../../../core/location/geo_fix.dart';
import '../../../../core/location/geo_point.dart';

/// The words of the notification that keeps the position going while the app is in the
/// background (Android shows one for as long as it runs).
final class ReportingNotice {
  const ReportingNotice({required this.title, required this.text});

  final String title;
  final String text;
}

/// Follows the phone's position and keeps sending it while the captain is online, in
/// the background too.
abstract interface class PositionReporter {
  bool get running;

  /// Every position the phone reports, while running.
  Stream<GeoPoint> get positions;

  /// The same readings with the direction, speed and accuracy, for navigation.
  Stream<GeoFix> get fixes;

  /// The last position seen, or null before the first one.
  GeoPoint? get last;

  /// Starts following the GPS and sending the position through [send] every few
  /// seconds, whether the captain moved or not.
  Future<void> start({
    required ReportingNotice notice,
    required Future<void> Function(GeoPoint position) send,
  });

  void stop();

  /// While on: a reading every second, however little the car moved, for turn-by-turn
  /// navigation. Off: the usual pace, which spares the battery between trips. Screens
  /// ask in pairs (on when opened, off when closed); it stays on while any asked.
  void detailed(bool on);
}
