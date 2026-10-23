import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/captain/captain_providers.dart';
import '../../core/network/api_client_provider.dart';
import 'data/registration_api.dart';
import 'data/registration_repository_impl.dart';
import 'domain/repositories/registration_repository.dart';
import 'domain/use_cases/load_draft.dart';
import 'domain/use_cases/submit_registration.dart';

// The feature's wiring. Screens and controllers read the use cases; tests override the
// repository.

final registrationRepositoryProvider = Provider<RegistrationRepository>(
  (ref) => RegistrationRepositoryImpl(
    RegistrationApi(ref.watch(apiClientProvider)),
    ref.watch(captainAccountRepositoryProvider),
  ),
);

final loadDraftProvider = Provider<LoadDraft>(
  (ref) => LoadDraft(ref.watch(registrationRepositoryProvider)),
);

final submitRegistrationProvider = Provider<SubmitRegistration>(
  (ref) => SubmitRegistration(ref.watch(registrationRepositoryProvider)),
);
