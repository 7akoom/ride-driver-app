import '../entities/next_step.dart';
import '../repositories/onboarding_preferences.dart';

/// The welcome screen's button: it is not shown again for this captain.
final class FinishWelcome {
  const FinishWelcome(this.preferences);

  final OnboardingPreferences preferences;

  Future<NextStep> call(String driverId) async {
    await preferences.markWelcomed(driverId);

    return NextStep.home;
  }
}
