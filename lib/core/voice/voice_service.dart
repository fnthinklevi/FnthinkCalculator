import 'package:flutter/services.dart';

class VoiceService {
  static const _channel = MethodChannel('com.fnthink.FnthinkCalculator/tts');
  bool? _available;

  Future<bool> isAvailable() async {
    try {
      _available = await _channel.invokeMethod<bool>('isAvailable') ?? false;
    } on Object {
      _available = false;
    }
    return _available!;
  }

  Future<void> speakText(String text) async {
    if (text.isEmpty) return;
    if (_available == null && !await isAvailable()) return;
    if (_available != true) return;
    try {
      await _channel.invokeMethod<bool>('speak', {'text': text});
    } on Object {
      // System TTS is an optional enhancement; never break calculation.
    }
  }

  Future<void> stop() async {
    try {
      await _channel.invokeMethod<bool>('stop');
    } on Object {
      // Ignore platform TTS failures.
    }
  }

  Future<void> dispose() async {
    await stop();
  }
}
