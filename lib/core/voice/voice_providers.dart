import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tts_voice_guide.dart';
import 'voice_guide.dart';
import 'voice_preference.dart';

/// The one voice. Tests override it.
final voiceGuideProvider = Provider<VoiceGuide>((ref) {
  final voice = TtsVoiceGuide();
  ref.onDispose(() => unawaited(voice.stop()));

  return voice;
});

/// Spoken directions on or off: on at first, then what the captain chose last time.
final voiceOnProvider = NotifierProvider<VoiceOn, bool>(VoiceOn.new);

class VoiceOn extends Notifier<bool> {
  bool _chosen = false;

  @override
  bool build() {
    unawaited(_load());

    return true;
  }

  Future<void> _load() async {
    final saved = await VoicePreference.read();

    // A choice made meanwhile wins over what was saved.
    if (!_chosen) {
      state = saved;
    }
  }

  void set(bool on) {
    _chosen = true;
    state = on;
    unawaited(VoicePreference.save(on));

    if (!on) {
      unawaited(ref.read(voiceGuideProvider).stop());
    }
  }
}
