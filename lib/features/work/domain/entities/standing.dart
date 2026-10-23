/// Whether the wallet lets the captain take trips. Below the suspension line the
/// platform gives them none until they top up.
final class Standing {
  const Standing({
    required this.canTakeTrips,
    this.balance = 0,
    this.suspensionThreshold = 0,
    this.amountDue = 0,
  });

  final bool canTakeTrips;

  /// Whole currency units; negative when the captain owes commission.
  final int balance;

  /// The balance at or below which no trips come (zero or negative).
  final int suspensionThreshold;

  /// What has to be topped up to take trips again; zero in good standing.
  final int amountDue;
}
