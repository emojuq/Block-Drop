import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class AppTheme {
  static ValueNotifier<bool> isDarkMode = ValueNotifier(true);

  static Future<void> loadTheme() async {
    isDarkMode.value = await StorageService.getTheme();
  }

  static void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    StorageService.saveTheme(isDarkMode.value);
  }

  static Color get background => isDarkMode.value ? const Color(0xFF1a1a2e) : const Color(0xFFF1F5F9);
  static Color get boardBg => isDarkMode.value ? const Color(0xFF16213e) : const Color(0xFFE2E8F0);
  static Color get socketBg => isDarkMode.value ? const Color(0xFF131A29) : const Color(0xFFCBD5E1);
  
  static Color get textPrimary => isDarkMode.value ? Colors.white : const Color(0xFF1E293B);
  static Color get textSecondary => isDarkMode.value ? Colors.white54 : const Color(0xFF64748B);
  
  static Color get border => isDarkMode.value ? Colors.white24 : const Color(0xFF94A3B8);
  static Color get borderHighlight => isDarkMode.value ? Colors.white.withAlpha(20) : Colors.white.withAlpha(200);
  static Color get borderShadow => isDarkMode.value ? Colors.black.withAlpha(150) : Colors.black.withAlpha(30);
  
  static Color get panelBg => isDarkMode.value ? const Color(0xFF131A29) : const Color(0xFFE2E8F0);
  static Color get dialogBg => isDarkMode.value ? const Color(0xFF131A29) : Colors.white;
}
