import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String keyHighScore = 'high_score';
  static const String keyTheme = 'app_theme_dark';
  static const String keySound = 'app_sound_enabled';
  static const String keyMusic = 'app_music_enabled';
  static const String keyMissions = 'daily_missions_data';
  static const String keyMissionDate = 'mission_date_stamp';

  static Future<int> getHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(keyHighScore) ?? 0;
    } catch (e) {
      return 0; 
    }
  }

  static Future<void> saveHighScore(int score) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(keyHighScore, score);
    } catch (e) {
      // Ignore
    }
  }

  static Future<bool> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyTheme) ?? true; // Default dark
  }

  static Future<void> saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyTheme, isDark);
  }

  static Future<bool> getSound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keySound) ?? true;
  }

  static Future<void> saveSound(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keySound, enabled);
  }

  static Future<bool> getMusic() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyMusic) ?? true;
  }

  static Future<void> saveMusic(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyMusic, enabled);
  }

  static Future<String> getMissionDateKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyMissionDate) ?? "";
  }

  static Future<String> getMissionsData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyMissions) ?? "";
  }

  static Future<void> saveMissions(List<dynamic> missions, String dateKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyMissionDate, dateKey);
    // Missions will be json encoded strings
    await prefs.setString(keyMissions, jsonEncode(missions.map((e) => e.toJson()).toList()));
  }
}
