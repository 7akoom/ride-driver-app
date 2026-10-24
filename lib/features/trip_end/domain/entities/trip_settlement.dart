/// How a finished trip's fare was paid, for the captain (wallet-service). Whole
/// currency units.
final class TripSettlement {
  const TripSettlement({
    required this.fare,
    required this.walletAmount,
    required this.cashAmount,
    this.changeAmount = 0,
    this.tip = 0,
    this.maxChange = 0,
  });

  final int fare;

  /// What left the rider's wallet, and what the captain collects in cash.
  final int walletAmount;
  final int cashAmount;

  /// Change already credited to the rider's wallet because the captain had none.
  final int changeAmount;
  final int tip;

  /// The most change that may go to the rider's wallet (0: none may).
  final int maxChange;

  bool get collectsCash => cashAmount > 0;

  /// "The rider gave me more and I have no change" is offered: cash to collect, a
  /// limit above zero, and no change recorded yet.
  bool get changeAllowed => collectsCash && maxChange > 0 && changeAmount == 0;

  /// The change for [received] in cash: what goes to the rider's wallet (zero or less
  /// means nothing to credit).
  int changeFor(int received) => received - cashAmount;

  bool tooMuchChange(int received) => changeFor(received) > maxChange;
}

/// What the captain may say about the rider (the backend's driver-side tags).
enum RiderTag { onTime, polite }
