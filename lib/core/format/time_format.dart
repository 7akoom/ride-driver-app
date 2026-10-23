import '../l10n/l10n.dart';
import 'bidi.dart';

/// "08:30 AM" in the captain's language (its own AM and PM), Western digits, 12-hour.
String formatClock(AppLocalizations l10n, DateTime time) {
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final digits = '${_two(hour)}:${_two(time.minute)}';

  return '${isolateLtr(digits)} ${time.hour < 12 ? l10n.timeAm : l10n.timePm}';
}

/// The day's name in the captain's language, Monday to Sunday.
String weekdayName(AppLocalizations l10n, DateTime day) => switch (day.weekday) {
      DateTime.monday => l10n.weekdayMonday,
      DateTime.tuesday => l10n.weekdayTuesday,
      DateTime.wednesday => l10n.weekdayWednesday,
      DateTime.thursday => l10n.weekdayThursday,
      DateTime.friday => l10n.weekdayFriday,
      DateTime.saturday => l10n.weekdaySaturday,
      _ => l10n.weekdaySunday,
    };

/// "Yesterday", "Today", "Tomorrow", else "Saturday 12/10".
String formatDay(AppLocalizations l10n, DateTime day, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(day.year, day.month, day.day);

  // Whole days between the two dates, right across a daylight saving change too.
  final days = (date.difference(today).inHours / 24).round();

  return switch (days) {
    -1 => l10n.yesterday,
    0 => l10n.today,
    1 => l10n.tomorrow,
    _ => formatDate(l10n, date),
  };
}

/// "Saturday 12/10": the day's name and its date, Western digits.
String formatDate(AppLocalizations l10n, DateTime day) =>
    '${weekdayName(l10n, day)} ${isolateLtr('${day.day}/${day.month}')}';

String _two(int value) => value.toString().padLeft(2, '0');

/// How long ago, for a list of messages: "just now", "5 min ago", "3 hours ago", then
/// "Yesterday" and the date.
String formatAgo(AppLocalizations l10n, DateTime at, DateTime now) {
  final passed = now.difference(at);

  if (passed.inMinutes < 1) {
    return l10n.timeJustNow;
  }

  if (passed.inMinutes < 60) {
    return l10n.timeMinutesAgo(passed.inMinutes);
  }

  if (passed.inHours < 24) {
    return l10n.timeHoursAgo(passed.inHours);
  }

  return formatDay(l10n, at, now);
}
