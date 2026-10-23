import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client_provider.dart';
import 'media_uploader.dart';

/// The one uploader (documents, the profile photo, ticket attachments).
final mediaUploaderProvider = Provider<MediaUploader>((ref) => MediaUploader(ref.watch(apiClientProvider)));
