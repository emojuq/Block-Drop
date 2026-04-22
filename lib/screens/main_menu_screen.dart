import 'package:flutter/material.dart';
import 'dart:math';
import 'game_screen.dart';
import 'how_to_play_screen.dart';
import 'settings_screen.dart';
import 'missions_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background floating shapes
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Stack(
                children: List.generate(10, (index) {
                  final random = Random(index); // deterministic random based on index
                  final speed = 0.5 + random.nextDouble();
                  final offsetY = (_animController.value * speed * MediaQuery.of(context).size.height) % MediaQuery.of(context).size.height;
                  final startX = random.nextDouble() * MediaQuery.of(context).size.width;
                  final size = 20.0 + random.nextDouble() * 40.0;
                  final color = (isDark ? Colors.white : Colors.black).withOpacity(0.05);
                  final rotation = _animController.value * 2 * pi * (random.nextBool() ? 1 : -1);

                  return Positioned(
                    top: offsetY - size, // Fall from top to bottom
                    left: startX,
                    child: Transform.rotate(
                      angle: rotation,
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(size * 0.2),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title with some style
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF00D2FE), Color(0xFFB145FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: const Text(
                        'BLOCK DROP',
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    _buildMenuButton(
                      context,
                      title: 'OYNA',
                      icon: Icons.play_arrow_rounded,
                      color: const Color(0xFF00E676),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GameScreen()),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildMenuButton(
                      context,
                      title: 'GÖREVLER',
                      icon: Icons.star_rounded,
                      color: const Color(0xFFFFD500),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MissionsScreen()),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildMenuButton(
                      context,
                      title: 'NASIL OYNANIR',
                      icon: Icons.help_outline_rounded,
                      color: const Color(0xFF00D2FE),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HowToPlayScreen()),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildMenuButton(
                      context,
                      title: 'AYARLAR',
                      icon: Icons.settings_rounded,
                      color: const Color(0xFFB145FF),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: color.withOpacity(0.3),
        highlightColor: color.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.6), width: 2.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(isDark ? 0.15 : 0.25),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.5), size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
