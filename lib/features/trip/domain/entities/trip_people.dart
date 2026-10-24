/// What the captain may know about the rider (B30): no phone number.
final class TripRider {
  const TripRider({this.firstName = '', this.rating = 0, this.ratingCount = 0});

  final String firstName;
  final double rating;
  final int ratingCount;
}

/// The trip's waiting rules, from its rate card (B31).
final class WaitTerms {
  const WaitTerms({
    required this.freeWaitingMinutes,
    required this.noShowWaitMinutes,
    required this.noShowFee,
    required this.arrivalRadiusMeters,
    this.freeUntil,
    this.noShowFrom,
    this.paidWaiting = false,
  });

  final int freeWaitingMinutes;
  final int noShowWaitMinutes;

  /// Whole currency units the rider pays for not coming.
  final int noShowFee;

  /// How near the pickup or a stop the captain must be to say they have arrived.
  final int arrivalRadiusMeters;

  /// Both null before the captain arrived.
  final DateTime? freeUntil;
  final DateTime? noShowFrom;

  /// Each minute after the free ones has a price.
  final bool paidWaiting;
}

/// Why the captain cancels; the backend keeps it as text.
enum CancelReason { riderAsked, wrongAddress, carProblem, emergency, other }
