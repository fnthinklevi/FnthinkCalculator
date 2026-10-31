import 'package:audioplayers/audioplayers.dart';

class VoiceService {
  AudioPlayer? _player;
  int _generation = 0;

  Future<void> speak(List<String> clips) async {
    if (clips.isEmpty) return;
    final player = _player ??= AudioPlayer();
    final generation = ++_generation;
    try {
      await player.stop();
      for (final clip in clips) {
        if (generation != _generation) return;
        final completed = player.onPlayerComplete.first;
        await player.play(AssetSource('voice/$clip.wav'));
        await Future.any<void>([
          completed,
          Future<void>.delayed(const Duration(seconds: 2)),
        ]);
      }
    } on Object {
      // Voice is an optional enhancement; never break calculation on audio errors.
    }
  }

  Future<void> stop() async {
    _generation++;
    try {
      await _player?.stop();
    } on Object {
      // Ignore platform audio failures.
    }
  }

  Future<void> dispose() async {
    _generation++;
    try {
      await _player?.dispose();
    } on Object {
      // Ignore platform audio failures.
    }
    _player = null;
  }
}
