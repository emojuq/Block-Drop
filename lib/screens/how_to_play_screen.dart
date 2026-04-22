import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class HowToPlayScreen extends StatefulWidget {
  const HowToPlayScreen({super.key});

  @override
  State<HowToPlayScreen> createState() => _HowToPlayScreenState();
}

class _HowToPlayScreenState extends State<HowToPlayScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final List<Widget> pages = [
      _buildInstructionPage(
        theme,
        icon: Icons.touch_app_rounded,
        iconColor: const Color(0xFF00D2FE),
        title: 'SÜRÜKLE VE BIRAK',
        description: 'Alt paneldeki blokları alın ve tahtadaki uygun boşluklara yerleştirin.',
      ),
      _buildInstructionPage(
        theme,
        icon: Icons.grid_on_rounded,
        iconColor: const Color(0xFFFFD500),
        title: 'SATIRLARI DOLDUR',
        description: 'Blokları temizlemek ve puan kazanmak için tam satırları veya sütunları tamamlayın.',
      ),
      _buildInstructionPage(
        theme,
        icon: Icons.stars_rounded,
        iconColor: const Color(0xFF00E676),
        title: 'KOMBO YAP',
        description: 'Büyük kombo puanları kazanmak için tek hamlede birden fazla satır veya sütun temizleyin.',
      ),
      _buildInstructionPage(
        theme,
        icon: Icons.offline_bolt_rounded,
        iconColor: const Color(0xFFB145FF),
        title: 'GÜÇLENDİRİCİLER',
        description: 'KARIŞTIR: Blokları yeniler.\nGERİ AL: Son hamleni geri alır.\nKIR: İstenmeyen bir bloğu kırar.\n\nNot: Her güçlendirici tek oyunda en fazla 3 kez ücretsiz kullanılabilir, sonrasında reklam izlemeniz gerekir.',
      ),
      _buildInstructionPage(
        theme,
        icon: Icons.warning_rounded,
        iconColor: const Color(0xFFFF3B3B),
        title: 'OYUN BİTTİ',
        description: 'Ekranda kalan bloklardan hiçbirini yerleştirecek yer kalmadığında oyun sona erer.',
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'NASIL OYNANIR',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textTheme.bodyLarge?.color),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              scrollBehavior: const MaterialScrollBehavior().copyWith(
                dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.stylus, PointerDeviceKind.trackpad},
              ),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: pages,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => GestureDetector(
                  onTap: () {
                    _controller.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    height: 10.0,
                    width: _currentPage == index ? 24.0 : 10.0,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? theme.textTheme.bodyLarge?.color
                          : theme.textTheme.bodyLarge?.color?.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionPage(ThemeData theme, {required IconData icon, required Color iconColor, required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withOpacity(0.1),
              border: Border.all(color: iconColor.withOpacity(0.5), width: 4),
            ),
            child: Icon(icon, size: 80, color: iconColor),
          ),
          const SizedBox(height: 48),
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: theme.textTheme.bodyLarge?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontSize: 18,
              height: 1.5,
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 64),
        ],
      ),
    );
  }
}
