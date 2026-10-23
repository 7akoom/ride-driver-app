/// What the app remembers about getting started, on this phone.
abstract interface class OnboardingPreferences {
  /// Whether the welcome screen was shown to the captain with [driverId] (it shows once,
  /// after approval).
  Future<bool> welcomed(String driverId);

  Future<void> markWelcomed(String driverId);
}
