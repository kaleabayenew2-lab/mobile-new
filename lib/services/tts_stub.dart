/// Stub TTS implementation for platforms where flutter_tts is not supported.
class FlutterTtsStub {
  Future<dynamic> setLanguage(String language) async => null;
  Future<dynamic> setSpeechRate(double rate) async => null;
  Future<dynamic> setVolume(double volume) async => null;
  Future<dynamic> setPitch(double pitch) async => null;
  Future<dynamic> speak(String text) async => null;
  Future<dynamic> stop() async => null;
}
