/// The captain's day so far, from their earnings: what they made and how many trips.
final class TodaySummary {
  const TodaySummary({required this.netEarnings, required this.trips});

  /// Whole currency units; trip earnings, fees, tips and bonuses less commission.
  final int netEarnings;
  final int trips;
}
