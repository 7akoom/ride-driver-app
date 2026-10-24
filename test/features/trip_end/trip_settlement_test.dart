import 'package:driver_app/features/trip_end/data/trip_end_repository_impl.dart';
import 'package:driver_app/features/trip_end/domain/entities/trip_settlement.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a settlement answer is read in whole units', () {
    final s = settlementIn({
      'fareAmount': '6000.00',
      'walletAmount': '2000',
      'cashAmount': '4000',
      'changeAmount': '0',
      'tipAmount': '500',
      'maxChangeCredit': '2000',
    });

    expect((s.fare, s.walletAmount, s.cashAmount, s.tip, s.maxChange), (6000, 2000, 4000, 500, 2000));
    expect(s.collectsCash, isTrue);
    expect(s.changeAllowed, isTrue);
  });

  test('the change is what was handed over above the cash due, up to the limit', () {
    const s = TripSettlement(fare: 6000, walletAmount: 0, cashAmount: 6000, maxChange: 2000);

    expect(s.changeFor(10000), 4000);
    expect(s.tooMuchChange(10000), isTrue);
    expect(s.tooMuchChange(8000), isFalse);
    expect(s.changeFor(5000), -1000);
  });

  test('no change is offered without cash, without a limit, or once recorded', () {
    expect(const TripSettlement(fare: 6000, walletAmount: 6000, cashAmount: 0, maxChange: 2000).changeAllowed, isFalse);
    expect(const TripSettlement(fare: 6000, walletAmount: 0, cashAmount: 6000).changeAllowed, isFalse);
    expect(const TripSettlement(fare: 6000, walletAmount: 0, cashAmount: 6000, maxChange: 2000, changeAmount: 1000).changeAllowed, isFalse);
  });
}
