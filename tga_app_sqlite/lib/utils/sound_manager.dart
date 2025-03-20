import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSoundEnabled = true;

  bool get isSoundEnabled => _isSoundEnabled;
  set isSoundEnabled(bool value) => _isSoundEnabled = value;

  Future<void> playTickSound() async {
    if (!_isSoundEnabled) return;
    await _audioPlayer.play(AssetSource('sounds/tick.mp3'));
  }

  Future<void> playCorrectSound() async {
    if (!_isSoundEnabled) return;
    await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
  }

  Future<void> playWrongSound() async {
    if (!_isSoundEnabled) return;
    await _audioPlayer.play(AssetSource('sounds/wrong.mp3'));
  }

  Future<void> playTimeoutSound() async {
    if (!_isSoundEnabled) return;
    await _audioPlayer.play(AssetSource('sounds/timeout.mp3'));
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
