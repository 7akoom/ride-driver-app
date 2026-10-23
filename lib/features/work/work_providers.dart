import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/captain/captain_providers.dart';
import '../../core/location/geo_point.dart';
import '../../core/location/location_providers.dart';
import '../../core/network/api_client_provider.dart';
import '../documents/documents_providers.dart';
import '../offers/offers_providers.dart';
import 'data/geolocator_position_reporter.dart';
import 'data/work_api.dart';
import 'data/work_repository_impl.dart';
import 'domain/repositories/position_reporter.dart';
import 'domain/repositories/work_repository.dart';
import 'domain/use_cases/check_for_work.dart';
import 'domain/use_cases/go_offline.dart';
import 'domain/use_cases/go_online.dart';
import 'domain/use_cases/resume_work.dart';

// The feature's wiring. Tests override the repository and the reporter.

final workRepositoryProvider = Provider<WorkRepository>(
  (ref) => WorkRepositoryImpl(WorkApi(ref.watch(apiClientProvider)), ref.watch(captainAccountRepositoryProvider)),
);

/// The one reporter: it outlives every screen, as the position does.
final positionReporterProvider = Provider<PositionReporter>((ref) {
  final reporter = GeolocatorPositionReporter();
  ref.onDispose(reporter.stop);

  return reporter;
});

final goOnlineProvider = Provider<GoOnline>(
  (ref) => GoOnline(
    work: ref.watch(workRepositoryProvider),
    documents: ref.watch(documentsRepositoryProvider),
    location: ref.watch(locationAccessProvider),
    reporter: ref.watch(positionReporterProvider),
  ),
);

final goOfflineProvider = Provider<GoOffline>(
  (ref) => GoOffline(work: ref.watch(workRepositoryProvider), reporter: ref.watch(positionReporterProvider)),
);

final resumeWorkProvider = Provider<ResumeWork>(
  (ref) => ResumeWork(
    work: ref.watch(workRepositoryProvider),
    location: ref.watch(locationAccessProvider),
    reporter: ref.watch(positionReporterProvider),
  ),
);

final checkForWorkProvider = Provider<CheckForWork>(
  (ref) => CheckForWork(work: ref.watch(workRepositoryProvider), offers: ref.watch(offersRepositoryProvider)),
);

/// Where the phone is while the captain is online (the reporter's positions).
final captainPositionProvider = StreamProvider<GeoPoint>((ref) => ref.watch(positionReporterProvider).positions);
