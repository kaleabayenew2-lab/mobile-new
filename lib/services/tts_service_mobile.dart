import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
export 'package:flutter_tts/flutter_tts.dart';

/// Mobile TTS implementation using flutter_tts.
class TtsService {
  static TtsService? _instance;
  static TtsService get instance => _instance ??= TtsService._();
  TtsService._();

  FlutterTts? _tts;
  bool _isAvailable = false;

  Future<void> init() async {
    try {
      _tts = FlutterTts();
      await _tts!.setLanguage('en-US');
      await _tts!.setSpeechRate(0.5);
      await _tts!.setVolume(1.0);
      await _tts!.setPitch(1.0);
      _isAvailable = true;
    } catch (e) {
      debugPrint('[TTS] init failed: $e');
      _isAvailable = false;
    }
  }

  Future<void> speak(String text) async {
    if (!_isAvailable || _tts == null) {
      debugPrint('[TTS] speak: $text');
      return;
    }
    await _tts!.speak(text);
  }

  Future<void> stop() async {
    if (!_isAvailable || _tts == null) return;
    await _tts!.stop();
  }

  bool get isAvailable => _isAvailable;
}
