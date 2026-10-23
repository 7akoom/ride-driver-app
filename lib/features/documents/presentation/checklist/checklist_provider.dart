import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/result.dart';
import '../../documents_providers.dart';
import '../../domain/entities/document_checklist.dart';

/// The captain's documents and where each stands. Fails with the Failure itself as the
/// error; invalidated after every upload and by pulling down.
final documentChecklistProvider = FutureProvider.autoDispose<DocumentChecklist>((ref) async {
  return switch (await ref.read(documentsRepositoryProvider).checklist()) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
});
