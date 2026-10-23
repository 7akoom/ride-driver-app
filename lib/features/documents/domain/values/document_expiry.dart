import '../../../../core/time/calendar_date.dart';

enum DocumentExpiryProblem { missing, notInFuture }

/// The last day a document is valid: the backend takes only a day after today.
DocumentExpiryProblem? checkDocumentExpiry(CalendarDate? lastDay, CalendarDate today) {
  if (lastDay == null) {
    return DocumentExpiryProblem.missing;
  }

  return lastDay.isAfter(today) ? null : DocumentExpiryProblem.notInFuture;
}
