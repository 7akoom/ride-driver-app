import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client_provider.dart';
import 'road_repository.dart';
import 'road_repository_impl.dart';

/// Roads for the offer card and the trip screens. Tests override it.
final roadRepositoryProvider = Provider<RoadRepository>((ref) => RoadRepositoryImpl(ref.watch(apiClientProvider)));
