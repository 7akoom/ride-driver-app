import 'package:driver_app/core/notifications/notification_target.dart';
import 'package:driver_app/features/push/domain/entities/push_message.dart';
import 'package:flutter_test/flutter_test.dart';

PushMessage _message(String eventKey) => PushMessage(eventKey: eventKey, title: 'T', body: 'B', data: const {});

void main() {
  test('a trip offer and trip news go to the home map, which opens them by itself', () {
    for (final key in ['trip.offer_received', 'trip.cancelled', 'trip.started']) {
      expect(_message(key).target, NotificationTarget.work, reason: key);
    }
  });

  test('a review decision works out where the account stands again', () {
    for (final key in ['driver.account_approved', 'driver.account_rejected', 'driver.suspended', 'driver.reinstated']) {
      expect(_message(key).target, NotificationTarget.accountStatus, reason: key);
    }
  });

  test('everything else opens the notifications list', () {
    for (final key in ['driver.document_expiring', 'wallet.transfer_received', 'driver.incentive_earned', '']) {
      expect(_message(key).target, NotificationTarget.inbox, reason: key);
    }
  });

  test('only a trip offer is kept off the in-app message', () {
    expect(isTripOffer('trip.offer_received'), isTrue);
    expect(isTripOffer('trip.cancelled'), isFalse);
  });

  test('the text joins the title and the body that exist', () {
    expect(_message('x').text, 'T\nB');
    expect(const PushMessage(eventKey: 'x', title: '', body: 'B', data: {}).text, 'B');
  });
}
