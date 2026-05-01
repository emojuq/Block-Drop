import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'storage_service.dart';

class AudioService {
  static ValueNotifier<bool> isSoundEnabled = ValueNotifier(true);
  static ValueNotifier<bool> isMusicEnabled = ValueNotifier(true);

  static final AudioPlayer _bgmPlayer = AudioPlayer();
  static final AudioPlayer _placeSoundPlayer = AudioPlayer();
  static final AudioPlayer _clearSoundPlayer = AudioPlayer();
  static final AudioPlayer _comboSoundPlayer = AudioPlayer();
  static final AudioPlayer _gameOverSoundPlayer = AudioPlayer();

  static Future<void> loadAudioSettings() async {
    final AudioContext audioContext = AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: const {
          AVAudioSessionOptions.mixWithOthers,
        },
      ),
      android: AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.game,
        audioFocus: AndroidAudioFocus.none,
      ),
    );
    AudioPlayer.global.setAudioContext(audioContext);

    isSoundEnabled.value = await StorageService.getSound();
    isMusicEnabled.value = await StorageService.getMusic();
    
    // Set sources for instant playback
    await _placeSoundPlayer.setSource(AssetSource('audio/place_block.mp3'));
    await _placeSoundPlayer.setReleaseMode(ReleaseMode.stop);

    await _clearSoundPlayer.setSource(AssetSource('audio/clear_line.mp3'));
    await _clearSoundPlayer.setReleaseMode(ReleaseMode.stop);

    await _comboSoundPlayer.setSource(AssetSource('audio/combo.mp3'));
    await _comboSoundPlayer.setReleaseMode(ReleaseMode.stop);

    await _gameOverSoundPlayer.setSource(AssetSource('audio/game_over.mp3'));
    await _gameOverSoundPlayer.setReleaseMode(ReleaseMode.stop);

    if (isMusicEnabled.value) {
      playBgm();
    }
  }

  static void toggleSound() {
    isSoundEnabled.value = !isSoundEnabled.value;
    StorageService.saveSound(isSoundEnabled.value);
  }

  static void toggleMusic() {
    isMusicEnabled.value = !isMusicEnabled.value;
    StorageService.saveMusic(isMusicEnabled.value);
    
    if (isMusicEnabled.value) {
      playBgm();
    } else {
      stopBgm();
    }
  }

  static Future<void> playBgm() async {
    if (!isMusicEnabled.value) return;
    try {
      _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.play(AssetSource('audio/bgm.mp3'), volume: 0.3);
    } catch (e) {
      debugPrint('BGM çalınamadı (dosya yok veya hata): $e');
    }
  }

  static Future<void> stopBgm() async {
    try {
      for (double v = 0.3; v >= 0; v -= 0.05) {
        await Future.delayed(const Duration(milliseconds: 50));
        await _bgmPlayer.setVolume(v);
      }
      await _bgmPlayer.stop();
    } catch (e) {
      debugPrint('BGM durdurulamadı: $e');
    }
  }

  static Future<void> playSound(String fileName) async {
    if (!isSoundEnabled.value) return;
    try {
      if (fileName == 'place_block') {
         _placeSoundPlayer.seek(Duration.zero).then((_) => _placeSoundPlayer.resume());
      } else if (fileName == 'clear_line') {
         _clearSoundPlayer.seek(Duration.zero).then((_) => _clearSoundPlayer.resume());
      } else if (fileName == 'combo') {
         Future.delayed(const Duration(milliseconds: 100), () {
            _comboSoundPlayer.seek(Duration.zero).then((_) => _comboSoundPlayer.resume());
         });
      } else if (fileName == 'game_over') {
         Future.delayed(const Duration(milliseconds: 300), () {
            _gameOverSoundPlayer.seek(Duration.zero).then((_) => _gameOverSoundPlayer.resume());
         });
      }
    } catch (e) {
      debugPrint('Ses çalınamadı ($fileName): $e');
    }
  }
}
