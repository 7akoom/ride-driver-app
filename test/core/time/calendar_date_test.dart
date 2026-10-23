import 'package:driver_app/core/time/calendar_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalendarDate', () {
    test('refuses days that do not exist', () {
      expect(CalendarDate.of(2026, 2, 29), isNull);
      expect(CalendarDate.of(2026, 4, 31), isNull);
      expect(CalendarDate.of(2026, 13, 1), isNull);
      expect(CalendarDate.of(2024, 2, 29), isNotNull);
    });

    test('reads and writes the backend form', () {
      expect(CalendarDate.of(1990, 3, 7)!.iso, '1990-03-07');
      expect(CalendarDate.tryParseIso('2027-10-01'), CalendarDate.of(2027, 10, 1));
      expect(CalendarDate.tryParseIso(''), isNull);
      expect(CalendarDate.tryParseIso('2027-02-30'), isNull);
      expect(CalendarDate.tryParseIso(null), isNull);
    });

    test('counts full years up to a day', () {
      final birth = CalendarDate.of(2008, 10, 24)!;

      expect(birth.yearsUntil(CalendarDate.of(2026, 10, 23)!), 17);
      expect(birth.yearsUntil(CalendarDate.of(2026, 10, 24)!), 18);
    });

    test('orders days', () {
      final today = CalendarDate.of(2026, 10, 23)!;

      expect(CalendarDate.of(2026, 10, 24)!.isAfter(today), isTrue);
      expect(today.isAfter(today), isFalse);
    });
  });
}
