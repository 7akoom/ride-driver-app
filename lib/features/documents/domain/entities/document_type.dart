import '../../../../core/l10n/localized_text.dart';

/// What a document's file is uploaded as; the media service checks it by this.
enum DocumentMedia { document, profilePhoto }

/// Whose document it is: the captain's own (ID, licence, photo) or a car's.
enum DocumentScope { captain, vehicle }

/// A kind of document the operator asks for (the copy's settings, not the app's).
final class DocumentType {
  const DocumentType({
    required this.code,
    required this.name,
    this.media = DocumentMedia.document,
    this.scope = DocumentScope.captain,
    this.required = true,
    this.requiresNumber = false,
    this.requiresExpiry = false,
  });

  /// Stable key, for example driving_licence_front.
  final String code;
  final LocalizedText name;
  final DocumentMedia media;
  final DocumentScope scope;

  /// Needed before approval and to go online.
  final bool required;

  /// The captain types the document's number.
  final bool requiresNumber;

  /// The captain gives the last day it is valid.
  final bool requiresExpiry;
}
