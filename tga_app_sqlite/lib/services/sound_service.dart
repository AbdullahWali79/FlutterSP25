// import 'package:just_audio/just_audio.dart';
//
// class SoundService {
//   static final SoundService _instance = SoundService._internal();
//   factory SoundService() => _instance;
//   SoundService._internal();
//
//   final AudioPlayer _tapPlayer = AudioPlayer();
//   final AudioPlayer _selectPlayer = AudioPlayer();
//   final AudioPlayer _successPlayer = AudioPlayer();
//
//   bool _isMuted = false;
//
//   Future<void> init() async {
//     await _tapPlayer.setAsset('assets/sounds/tap.mp3');
//     await _selectPlayer.setAsset('assets/sounds/select.mp3');
//     await _successPlayer.setAsset('assets/sounds/success.mp3');
//   }
//
//   void toggleMute() {
//     _isMuted = !_isMuted;
//   }
//
//   Future<void> playTap() async {
//     if (!_isMuted) {
//       await _tapPlayer.seek(Duration.zero);
//       await _tapPlayer.play();
//     }
//   }
//
//   Future<void> playSelect() async {
//     if (!_isMuted) {
//       await _selectPlayer.seek(Duration.zero);
//       await _selectPlayer.play();
//     }
//   }
//
//   Future<void> playSuccess() async {
//     if (!_isMuted) {
//       await _successPlayer.seek(Duration.zero);
//       await _successPlayer.play();
//     }
//   }
//
//   void dispose() {
//     _tapPlayer.dispose();
//     _selectPlayer.dispose();
//     _successPlayer.dispose();
//   }
// }
