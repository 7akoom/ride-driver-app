import '../../../../core/media/picked_image.dart';
import '../../../../core/time/calendar_date.dart';
import 'document_requirement.dart';

/// A document about to be handed in: the photo and, when its type asks, its number and
/// last valid day.
final class DocumentUpload {
  const DocumentUpload({
    required this.requirement,
    required this.photo,
    this.number = '',
    this.expiresOn,
  });

  final DocumentRequirement requirement;
  final PickedImage photo;
  final String number;
  final CalendarDate? expiresOn;
}
