import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/captain/captain_providers.dart';
import '../../core/media/media_providers.dart';
import '../../core/network/api_client_provider.dart';
import 'data/documents_api.dart';
import 'data/documents_repository_impl.dart';
import 'domain/repositories/documents_repository.dart';
import 'domain/use_cases/submit_document.dart';

// The feature's wiring. Screens and controllers read the use cases; tests override the
// repository.

final documentsRepositoryProvider = Provider<DocumentsRepository>(
  (ref) => DocumentsRepositoryImpl(
    DocumentsApi(ref.watch(apiClientProvider)),
    ref.watch(mediaUploaderProvider),
    ref.watch(captainAccountRepositoryProvider),
  ),
);

final submitDocumentProvider = Provider<SubmitDocument>(
  (ref) => SubmitDocument(ref.watch(documentsRepositoryProvider)),
);
