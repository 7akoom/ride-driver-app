import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/captain/captain_providers.dart';
import '../../core/network/api_client_provider.dart';
import '../documents/documents_providers.dart';
import '../registration/registration_providers.dart';
import 'data/onboarding_preferences_impl.dart';
import 'data/sign_in_api.dart';
import 'data/sign_in_repository_impl.dart';
import 'domain/repositories/onboarding_preferences.dart';
import 'domain/repositories/sign_in_repository.dart';
import 'domain/use_cases/account_step.dart';
import 'domain/use_cases/confirm_code.dart';
import 'domain/use_cases/decide_start.dart';
import 'domain/use_cases/finish_welcome.dart';
import 'domain/use_cases/send_code.dart';

// The feature's wiring: the one file that knows both the data classes and the domain
// interfaces. Screens and controllers read the use cases; tests override the
// repositories.

final signInRepositoryProvider = Provider<SignInRepository>(
  (ref) => SignInRepositoryImpl(SignInApi(ref.watch(apiClientProvider))),
);

final onboardingPreferencesProvider = Provider<OnboardingPreferences>(
  (ref) => const OnboardingPreferencesImpl(),
);

final accountStepProvider = Provider<AccountStep>(
  (ref) => AccountStep(
    preferences: ref.watch(onboardingPreferencesProvider),
    registration: ref.watch(registrationRepositoryProvider),
    documents: ref.watch(documentsRepositoryProvider),
  ),
);

final decideStartProvider = Provider<DecideStart>(
  (ref) => DecideStart(
    signIn: ref.watch(signInRepositoryProvider),
    accounts: ref.watch(captainAccountRepositoryProvider),
    accountStep: ref.watch(accountStepProvider),
  ),
);

final sendCodeProvider = Provider<SendCode>(
  (ref) => SendCode(ref.watch(signInRepositoryProvider)),
);

final confirmCodeProvider = Provider<ConfirmCode>(
  (ref) => ConfirmCode(
    signIn: ref.watch(signInRepositoryProvider),
    accounts: ref.watch(captainAccountRepositoryProvider),
    accountStep: ref.watch(accountStepProvider),
  ),
);

final finishWelcomeProvider = Provider<FinishWelcome>(
  (ref) => FinishWelcome(ref.watch(onboardingPreferencesProvider)),
);
