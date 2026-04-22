import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/audio_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'SETTINGS',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textTheme.bodyLarge?.color),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildSectionHeader('DISPLAY', theme),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: AppTheme.isDarkMode,
              builder: (context, isDarkMode, child) {
                return _buildListTile(
                  title: 'Dark Mode',
                  icon: isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  iconColor: const Color(0xFFB145FF),
                  value: isDarkMode,
                  onChanged: (val) => AppTheme.toggleTheme(),
                  theme: theme,
                );
              },
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('AUDIO', theme),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: AudioService.isSoundEnabled,
              builder: (context, hasSound, child) {
                return _buildListTile(
                  title: 'Sound Effects',
                  icon: hasSound ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                  iconColor: const Color(0xFF00E676),
                  value: hasSound,
                  onChanged: (val) => AudioService.toggleSound(),
                  theme: theme,
                );
              },
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: AudioService.isMusicEnabled,
              builder: (context, hasMusic, child) {
                return _buildListTile(
                  title: 'Background Music',
                  icon: hasMusic ? Icons.music_note_rounded : Icons.music_off_rounded,
                  iconColor: const Color(0xFFFFD500),
                  value: hasMusic,
                  onChanged: (val) => AudioService.toggleMusic(),
                  theme: theme,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          color: theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeData theme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.dialogBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
             color: Colors.black.withOpacity(0.05),
             blurRadius: 10,
             offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: iconColor,
      ),
    );
  }
}
