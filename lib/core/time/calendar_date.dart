/// A day on the calendar, with no time and no time zone: a date of birth, the last day
/// a document is valid. The backend writes these as YYYY-MM-DD.
final class CalendarDate implements Comparable<CalendarDate> {
  const CalendarDate._(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;

  /// The date, or null when there is no such day (31 April, 29 February 2026).
  static CalendarDate? of(int year, int month, int day) {
    if (year < 1 || month < 1 || month > 12 || day < 1) {
      return null;
    }

    final probe = DateTime.utc(year, month, day);

    return probe.month == month && probe.day == day ? CalendarDate._(year, month, day) : null;
  }

  /// Today on the phone's calendar.
  static CalendarDate today([DateTime? now]) {
    final local = (now ?? DateTime.now()).toLocal();

    return CalendarDate._(local.year, local.month, local.day);
  }

  /// "2026-10-23" as the backend writes it; null for anything else (an empty value).
  static CalendarDate? tryParseIso(String? text) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(text?.trim() ?? '');

    if (match == null) {
      return null;
    }

    return of(int.parse(match[1]!), int.parse(match[2]!), int.parse(match[3]!));
  }

  /// "2026-10-23", as the backend wants it.
  String get iso =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  /// Full years from this date to [on] (a date of birth gives the age).
  int yearsUntil(CalendarDate on) {
    final hadBirthday = on.month > month || (on.month == month && on.day >= day);

    return on.year - year - (hadBirthday ? 0 : 1);
  }

  bool isAfter(CalendarDate other) => compareTo(other) > 0;

  @override
  int compareTo(CalendarDate other) =>
      year != other.year ? year - other.year : (month != other.month ? month - other.month : day - other.day);

  @override
  bool operator ==(Object other) =>
      other is CalendarDate && other.year == year && other.month == month && other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => iso;
}
