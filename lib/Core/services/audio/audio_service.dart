import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

abstract class AudioService {
  Future<void> playAudioFromUrl(String url);
  Future<void> playAudioFromAsset(String path);
  Future<void> pauseAudio();
  Future<void> stopAudio();
  Stream<PlayerState> get audioStateStream;
  AudioPlayer get player;
}

class JustAudioServiceImpl implements AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  AudioPlayer get player => _audioPlayer;

  @override
  Future<void> playAudioFromUrl(String url) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint("Audio load error: $e");
    }
  }

  @override
  Future<void> playAudioFromAsset(String path) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setAsset(path);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint("Audio asset error: $e");
    }
  }

  @override
  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
  }

  @override
  Future<void> stopAudio() async {
    await _audioPlayer.stop();
  }

  @override
  Stream<PlayerState> get audioStateStream => _audioPlayer.playerStateStream;
}