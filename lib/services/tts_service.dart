import 'package:flutter/foundation.dart';

/// Desktop/Web TTS stub — flutter_tts not available on Windows/Linux/macOS/Web.
class TtsService {
  static TtsService? _instance;
  static TtsService get instance => _instance ??= TtsService._();
  TtsService._();

  Future<void> init() async {
    debugPrint('[TTS] Voice navigation not available on this platform.');
  }

  Future<void> speak(String text) async {
    debugPrint('[TTS] speak (stub): $text');
  }

  Future<void> stop() async {}

  bool get isAvailable => false;
}
