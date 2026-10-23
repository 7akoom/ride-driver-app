import '../../../../core/location/location_access.dart';
import '../../../documents/domain/entities/document_requirement.dart';
import 'standing.dart';

/// Why the captain cannot go online, each with what fixes it.
sealed class OnlineBlock {
  const OnlineBlock();
}

/// A required document is missing, turned down or out of date: upload it again.
final class DocumentsBlock extends OnlineBlock {
  const DocumentsBlock(this.requirement);

  /// The first document to deal with; null when the backend did not say which.
  final DocumentRequirement? requirement;
}

/// The wallet is below the suspension line: top up.
final class WalletBlock extends OnlineBlock {
  const WalletBlock(this.standing);

  final Standing standing;
}

/// The app may not read the position (or location is off on the phone).
final class LocationBlock extends OnlineBlock {
  const LocationBlock(this.status);

  final LocationAccessStatus status;
}
