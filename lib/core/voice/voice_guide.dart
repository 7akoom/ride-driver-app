/// Spoken directions through the phone's own text-to-speech (no service to pay for).
abstract interface class VoiceGuide {
  /// Gets the voice ready for the app's language ([languageCode]: ar, ku or en) and
  /// says which language it will speak: the same, or Arabic for Kurdish on a phone with
  /// no Kurdish voice; null when it cannot speak at all.
  Future<String?> prepare(String languageCode);

  /// Says [text] at once, cutting off what was being said (the latest instruction is
  /// the one that matters). Lowers music meanwhile.
  Future<void> say(String text);

  Future<void> stop();
}
