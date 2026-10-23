import 'package:flutter/material.dart';

import '../../../legacy/features/home/driver_home_screen.dart';
import '../../account_status/presentation/rejected_screen.dart';
import '../../account_status/presentation/suspended_screen.dart';
import '../../account_status/presentation/under_review_screen.dart';
import '../../account_status/presentation/welcome_screen.dart';
import '../../documents/presentation/checklist/documents_screen.dart';
import '../../registration/presentation/join/join_screen.dart';
import '../../registration/presentation/you/you_step_screen.dart';
import '../domain/entities/next_step.dart';
import 'phone/phone_screen.dart';
import 'splash/splash_screen.dart';

/// Opens the screen for [step] as the only screen: the captain cannot go back into
/// sign-in once past it, nor back to the start screen.
void openStep(BuildContext context, NextStep step) {
  final Widget screen = switch (step) {
    NextStep.enterPhone => const PhoneScreen(),
    NextStep.join => const JoinScreen(),
    NextStep.finishRegistration => const YouStepScreen(),
    NextStep.documents => const DocumentsScreen(),
    NextStep.underReview => const UnderReviewScreen(),
    NextStep.rejected => const RejectedScreen(),
    NextStep.suspended => const SuspendedScreen(),
    NextStep.welcome => const WelcomeScreen(),
    // The old home and trip screens, until the redesigned ones replace them.
    NextStep.home => const DriverHomeScreen(),
    NextStep.checkAgain => const SplashScreen(),
  };

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(builder: (_) => screen),
    (_) => false,
  );
}
