import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'storage_service.dart';

class AudioService {
  static ValueNotifier<bool> isSoundEnabled = ValueNotifier(true);
  static ValueNotifier<bool> isMusicEnabled = ValueNotifier(true);

  static final AudioPlayer _bgmPlayer = AudioPlayer();

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
      await _bgmPlayer.stop();
    } catch (e) {
      debugPrint('BGM durdurulamadı: $e');
    }
  }

  static Future<void> playSound(String fileName) async {
    if (!isSoundEnabled.value) return;
    try {
      final player = AudioPlayer();
      await player.play(AssetSource('audio/$fileName.mp3'), mode: PlayerMode.lowLatency);
      
      // Auto dispose after playing to free memory
      player.onPlayerComplete.listen((_) {
        player.dispose();
      });
    } catch (e) {
      debugPrint('Ses çalınamadı ($fileName): $e');
    }
  }
}
