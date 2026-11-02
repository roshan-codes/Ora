import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundPreviewService {
  static final SoundPreviewService instance = SoundPreviewService._();
  SoundPreviewService._();

  final AudioPlayer _player = AudioPlayer();
  String? _currentlyPlayingPath;

  String? get currentlyPlayingPath => _currentlyPlayingPath;

  Future<void> playPreview(String assetPath) async {
    try {
      if (_currentlyPlayingPath == assetPath) {
        await stopPreview();
        return;
      }

      await _player.stop();
      _currentlyPlayingPath = assetPath;
      
      // AssetSource expects path relative to assets/ folder
      // e.g. "audio/classic_alarm.wav" if asset is "assets/audio/classic_alarm.wav"
      final cleanPath = assetPath.startsWith('assets/')
          ? assetPath.substring(7)
          : assetPath;

      await _player.play(AssetSource(cleanPath));
    } catch (e) {
      debugPrint('[SoundPreviewService] Error playing preview: $e');
      _currentlyPlayingPath = null;
    }
  }

  Future<void> stopPreview() async {
    try {
      await _player.stop();
    } catch (_) {}
    _currentlyPlayingPath = null;
  }

  void dispose() {
    _player.dispose();
  }
}

