import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';

import '../error/error_reporter.dart';
import 'voice_guide.dart';

/// [VoiceGuide] through the flutter_tts plugin (Android's and iOS's own speech engines).
final class TtsVoiceGuide implements VoiceGuide {
  TtsVoiceGuide([FlutterTts? tts]) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  bool _audioReady = false;
  String? _spoken;
  String? _askedFor;

  /// The engines' names for each language, most fitting first: Iraqi Arabic, Sorani
  /// Kurdish.
  static const Map<String, List<String>> _voices = {
    'ar': ['ar-IQ', 'ar-SA', 'ar-AE', 'ar-EG', 'ar'],
    'ku': ['ckb-IQ', 'ckb', 'ku-IQ', 'ku'],
    'en': ['en-US', 'en-GB', 'en'],
  };

  /// A Kurdish captain with no Kurdish voice on the phone hears Arabic.
  static const Map<String, String> _fallback = {'ku': 'ar'};

  @override
  Future<String?> prepare(String languageCode) async {
    if (_askedFor == languageCode) {
      return _spoken;
    }

    _askedFor = languageCode;
    _spoken = null;

    try {
      await _prepareAudio();

      for (final language in [languageCode, if (_fallback[languageCode] case final other?) other]) {
        for (final voice in _voices[language] ?? const <String>[]) {
          if (await _tts.isLanguageAvailable(voice) == true) {
            await _tts.setLanguage(voice);
            await _tts.setSpeechRate(Platform.isIOS ? 0.5 : 0.48);

            return _spoken = language;
          }
        }
      }
    } catch (error, stack) {
      ErrorReporter.report(error, stack);
    }

    return null;
  }

  Future<void> _prepareAudio() async {
    if (_audioReady) {
      return;
    }

    if (Platform.isAndroid) {
      // Heard as directions: music is lowered, not stopped, and it plays on the car's
      // speakers like a navigation app's.
      await _tts.setAudioAttributesForNavigation();
    } else if (Platform.isIOS) {
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [IosTextToSpeechAudioCategoryOptions.duckOthers, IosTextToSpeechAudioCategoryOptions.interruptSpokenAudioAndMixWithOthers],
        IosTextToSpeechAudioMode.voicePrompt,
      );
    }

    _audioReady = true;
  }

  @override
  Future<void> say(String text) async {
    if (_spoken == null || text.isEmpty) {
      return;
    }

    try {
      await _tts.stop();
      await _tts.speak(text, focus: true);
    } catch (error, stack) {
      ErrorReporter.report(error, stack);
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (error, stack) {
      ErrorReporter.report(error, stack);
    }
  }
}
