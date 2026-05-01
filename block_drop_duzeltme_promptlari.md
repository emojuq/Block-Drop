# 🔧 Block Drop — Flutter Düzeltme Promptları

> Tespit edilen tüm sorunları gidermek için Gemini'ye
> sırayla verilecek promptlar. Her adımdan sonra
> `flutter run` ile test et.

---

## 📋 Sorun Özeti

| # | Sorun | Etki |
|---|---|---|
| 1 | 64 DragTarget aynı anda rebuild | Kasma, lag |
| 2 | setState tüm ekranı rebuild ediyor | FPS düşüşü |
| 3 | Sürükleme offset'i yanlış | Blok parmağa yapışmıyor |
| 4 | Temizleme animasyonu yarım | Görsel bug |
| 5 | Particle efekti yok | Cansız görünüm |
| 6 | Varsayılan font | Amatör görünüm |
| 7 | Ses senkronizasyonu zayıf | Gecikmeli ses |
| 8 | Combo animasyonu zayıf | Dopamin eksikliği |

---

## 🚀 PROMPT 1 — Performans: RepaintBoundary + CustomPainter

```
Flutter oyunumda ciddi performans sorunları var.
Aşağıdaki dosyaları tamamen yeniden yaz:

━━━━━━━━━━━━━━━━━━━━━━━━━━━
SORUN 1: 64 DragTarget widget'ı aynı anda rebuild oluyor
━━━━━━━━━━━━━━━━━━━━━━━━━━━

lib/widgets/game_board.dart dosyasını şöyle yeniden yaz:

1. Tahtayı CustomPainter ile çiz:
   - BoardPainter adında bir CustomPainter sınıfı oluştur
   - 64 Container yerine canvas.drawRRect() ile her hücreyi çiz
   - Dolu hücreler için renk, boş için AppTheme.socketBg kullan
   - Grid çizgileri için canvas.drawLine() kullan
   - Bu sayede 64 widget yerine tek bir paint() çağrısı olur

2. Sürükleme ve DragTarget mantığını dışarıda tut:
   - CustomPaint üzerine tek bir GestureDetector koy
   - onPanUpdate ile sürüklenen bloğun koordinatını hesapla:
       int row = (localPosition.dy / cellSize).floor()
       int col = (localPosition.dx / cellSize).floor()
   - onPanEnd ile bloğu o hücreye bırak
   - DragTarget yerine bu GestureDetector yaklaşımını kullan

3. RepaintBoundary ekle:
   - GameBoard widget'ını RepaintBoundary ile sar
   - BlockTray widget'ını RepaintBoundary ile sar
   - Böylece biri değişince diğeri rebuild olmaz

4. Ghost (önizleme) gösterimi:
   - Sürükleme sırasında hangi hücrelerin dolacağını
     BoardPainter'a Set<Point<int>> ghostCells olarak geçir
   - Painter bu hücreleri yarı saydam beyaz çizsin

pubspec.yaml'a ekle:
  flutter_animate: ^4.5.0

Mevcut dosyalar:
- lib/widgets/game_board.dart → tamamen yeniden yaz
- lib/main.dart → RepaintBoundary ekle

Kodu tam ve çalışır şekilde yaz.
```

---

## 🎯 PROMPT 2 — Sürükleme Hissi Düzeltmesi

```
Oyunda sürükleme deneyimi zayıf, blok parmağa
yapışmıyor ve yanlış hücreye düşüyor.

lib/widgets/block_tray.dart dosyasını yeniden yaz:

━━━━━━━━━━━━━━━━━━━━━━━━━━━
SORUN: Draggable feedback offset'i yanlış
━━━━━━━━━━━━━━━━━━━━━━━━━━━

Düzeltmeler:

1. Draggable widget'ında feedback boyutunu
   game_board'daki cellSize ile AYNI yap:
   - BlockTray, cellSize parametresini dışarıdan alsın
   - Tray'deki blok boyutu = cellSize * 0.75 (küçük göster)
   - Feedback boyutu = cellSize (tam board boyutu)

2. Draggable'a şu parametreleri ekle:
   dragAnchorStrategy: (draggable, context, position) {
     // Bloğun sol üst köşesini parmak pozisyonuna hizala
     return Offset(cellSize / 2, cellSize / 2);
   }

3. Sürükleme başlarken bloğu büyüt:
   - childWhenDragging: opacity 0.3 ile küçük göster
   - feedback: bloğu 1.1x scale ile göster
     (Transform.scale ile)

4. Tray'deki blokları ortala:
   - Her slot için SizedBox(width: cellSize * 4) kullan
   - Bloğu Center widget'ı içine koy
   - Kullanılmış bloklar Opacity(opacity: 0.2) olsun

Değişen dosya: lib/widgets/block_tray.dart
```

---

## ✨ PROMPT 3 — Animasyon Sistemi Yeniden Yazımı

```
Oyundaki animasyonlar yarım ve bug'lı.
Aşağıdaki sorunları düzelt:

━━━━━━━━━━━━━━━━━━━━━━━━━━━
SORUN 1: lastClearedCells hiç temizlenmiyor
━━━━━━━━━━━━━━━━━━━━━━━━━━━

lib/screens/game_screen.dart içinde:
- placeBlock() çağrısından sonra 600ms bekle
- Sonra setState ile lastClearedCells'i temizle:
  Future.delayed(const Duration(milliseconds: 600), () {
    if (mounted) setState(() {
      _gameState.lastClearedCells.clear();
    });
  });

━━━━━━━━━━━━━━━━━━━━━━━━━━━
SORUN 2: Temizleme animasyonu tek tip ve cansız
━━━━━━━━━━━━━━━━━━━━━━━━━━━

lib/widgets/game_board.dart içinde temizlenen
hücreler için şu animasyonu uygula:

Adım 1 (0-200ms): Hücre beyaza döner + scale 1.3x
Adım 2 (200-400ms): Scale 0.8x'e iner
Adım 3 (400-600ms): Opacity 0'a düşer, kaybolur

AnimationController ile yap:
- _clearAnimController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600)
  )
- CurvedAnimation ile Curves.easeOutBack kullan

━━━━━━━━━━━━━━━━━━━━━━━━━━━
SORUN 3: Blok yerleşince animasyon yok
━━━━━━━━━━━━━━━━━━━━━━━━━━━

Blok tahtaya bırakıldığında:
- Yerleşen hücreler 150ms içinde 0.7x'ten 1.0x'e büyür
  (scale bounce efekti)
- flutter_animate paketi ile:
  BlockCell(...).animate().scale(
    begin: const Offset(0.7, 0.7),
    end: const Offset(1.0, 1.0),
    duration: 150.ms,
    curve: Curves.elasticOut,
  )

━━━━━━━━━━━━━━━━━━━━━━━━━━━
SORUN 4: Skor artışı animasyonu yok
━━━━━━━━━━━━━━━━━━━━━━━━━━━

game_screen.dart içinde skor widget'ı:
- AnimatedSwitcher ile her skor değişiminde
  yeni sayı yukarıdan gelsin, eski kaybolsun:
  AnimatedSwitcher(
    duration: const Duration(milliseconds: 300),
    transitionBuilder: (child, animation) =>
      SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.5),
          end: Offset.zero,
        ).animate(animation),
        child: FadeTransition(opacity: animation, child: child),
      ),
    child: Text(
      '$score',
      key: ValueKey(score),
    ),
  )

Değişen dosyalar:
- lib/screens/game_screen.dart
- lib/widgets/game_board.dart
- lib/widgets/block_cell.dart
```

---

## 💥 PROMPT 4 — Particle Efekti

```
Satır temizlenince cansız görünüyor.
Particle efekti ekle.

pubspec.yaml'a ekle:
  confetti: ^0.7.0

lib/screens/game_screen.dart içinde:

1. ConfettiController ekle:
   late ConfettiController _confettiController;
   
   initState'te:
   _confettiController = ConfettiController(
     duration: const Duration(milliseconds: 800)
   );
   
   dispose'ta:
   _confettiController.dispose();

2. Satır temizlenince confetti patla:
   if (clearedCount > 0) {
     _confettiController.play();
   }

3. ConfettiWidget'ı Stack içine koy:
   ConfettiWidget(
     confettiController: _confettiController,
     blastDirectionality: BlastDirectionality.explosive,
     shouldLoop: false,
     numberOfParticles: clearedCount >= 3 ? 30 : 15,
     colors: const [
       Colors.yellow, Colors.cyan, Colors.pink,
       Colors.green, Colors.orange, Colors.purple
     ],
     minimumSize: const Size(5, 5),
     maximumSize: const Size(12, 12),
   )

4. Combo olunca (2+ satır) ekstra efekt:
   - numberOfParticles: 40
   - blastDirectionality: BlastDirectionality.explosive
   - Ekranın ortasından patlasın

Değişen dosya: lib/screens/game_screen.dart
```

---

## 🎨 PROMPT 5 — Görsel Kalite: Font + UI

```
Oyunun varsayılan font kullanıyor ve UI amatörce
görünüyor. Şunları düzelt:

━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. ÖZEL FONT EKLE
━━━━━━━━━━━━━━━━━━━━━━━━━━━

pubspec.yaml'a ekle:
  google_fonts: ^6.2.1

lib/theme/app_theme.dart içinde:
- GoogleFonts.bungee() → başlıklar için (BLOCK DROP yazısı)
- GoogleFonts.nunito(fontWeight: FontWeight.w800) → skorlar
- GoogleFonts.nunito() → genel metin

Tüm Text widget'larında bu fontları kullan.

━━━━━━━━━━━━━━━━━━━━━━━━━━━
2. SKOR KARTI TASARIMI
━━━━━━━━━━━━━━━━━━━━━━━━━━━

game_screen.dart üst barını yeniden tasarla:
- "SKOR" ve "EN YÜKSEK" kartlarını şöyle göster:
  Container(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.white.withOpacity(0.15),
        width: 1,
      ),
    ),
    child: Column(...)
  )

━━━━━━━━━━━━━━━━━━━━━━━━━━━
3. BAŞLIK ANİMASYONU
━━━━━━━━━━━━━━━━━━━━━━━━━━━

"BLOCK DROP" başlığına ekle:
- flutter_animate ile:
  Text('BLOCK DROP')
    .animate(onPlay: (c) => c.repeat(reverse: true))
    .shimmer(
      duration: 3000.ms,
      color: Colors.white.withOpacity(0.6),
    )

━━━━━━━━━━━━━━━━━━━━━━━━━━━
4. BLOK TRAY ARKAPLAN
━━━━━━━━━━━━━━━━━━━━━━━━━━━

BlockTray'in arkasına cam efekti:
- BackdropFilter ile blur: 10
- Container rengi: Colors.white.withOpacity(0.05)
- Üst kenar: 1px beyaz border

Değişen dosyalar:
- lib/theme/app_theme.dart
- lib/screens/game_screen.dart
- lib/widgets/block_tray.dart
```

---

## 🔊 PROMPT 6 — Ses Senkronizasyonu

```
Seslerin animasyonlarla senkronize olması gerekiyor.

lib/services/audio_service.dart dosyasını yeniden yaz:

1. Ses önbelleğe al (AudioCache):
   - Tüm sesleri initState'te önceden yükle:
     await AudioCache.instance.loadAll([
       'audio/place_block.mp3',
       'audio/clear_line.mp3',
       'audio/combo.mp3',
       'audio/game_over.mp3',
     ]);
   - play() yerine AudioPlayer ile cached oynat:
     bu gecikmeyi 200ms'den 20ms'nin altına indirir

2. Ses katmanlaması:
   - Aynı anda birden fazla ses çalabilmek için
     her ses tipi için ayrı AudioPlayer instance'ı tut:
     final _placeSoundPlayer = AudioPlayer();
     final _clearSoundPlayer = AudioPlayer();
     final _comboSoundPlayer = AudioPlayer();

3. Ses zamanlaması:
   - place_block sesi: blok bırakılınca ANINDA
   - clear_line sesi: temizleme animasyonu BAŞLARKEN
   - combo sesi: clear_line'dan 100ms SONRA
     Future.delayed(100.ms, () => playCombo())

4. Arkaplan müziği:
   - BGM için AudioPlayer'da setReleaseMode(ReleaseMode.loop)
   - Volume: 0.4 (çok baskın olmasın)
   - Oyun bitince fadeOut:
     for (double v = 0.4; v >= 0; v -= 0.05) {
       await Future.delayed(50.ms);
       bgmPlayer.setVolume(v);
     }

Değişen dosya: lib/services/audio_service.dart
```

---

## 🎮 PROMPT 7 — Combo Sistemi Güçlendirme

```
Combo ekranı zayıf ve motivasyon vermiyor.
Tamamen yeniden yaz:

lib/screens/game_screen.dart içinde combo widget'ı:

━━━━━━━━━━━━━━━━━━━━━━━━━━━
COMBO EKRANI TASARIMI
━━━━━━━━━━━━━━━━━━━━━━━━━━━

Combo olduğunda ekranın ortasında şunu göster:

Stack(children: [
  // Arka ışıma efekti
  if (_showCombo)
    Center(
      child: Container(
        width: 200, height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          boxShadow: [BoxShadow(
            color: comboColor.withOpacity(0.6),
            blurRadius: 40,
            spreadRadius: 20,
          )],
        ),
      ).animate().fadeIn(200.ms).fadeOut(duration: 800.ms, delay: 700.ms),
    ),
  
  // Combo yazısı
  if (_showCombo)
    Center(
      child: Column(children: [
        Text('COMBO', style: GoogleFonts.bungee(
          fontSize: 16, color: Colors.white70,
          letterSpacing: 8,
        )),
        Text('×$_comboCount', style: GoogleFonts.bungee(
          fontSize: 56,
          color: _comboCount >= 3 ? Colors.orange : Colors.yellow,
          shadows: [Shadow(color: Colors.orange, blurRadius: 20)],
        )),
      ])
      .animate(key: ValueKey(_comboKey))
      .scale(begin: Offset(0.5, 0.5), curve: Curves.elasticOut, duration: 400.ms)
      .then()
      .moveY(end: -60, duration: 600.ms, delay: 800.ms, curve: Curves.easeIn)
      .fadeOut(duration: 300.ms, delay: 1000.ms),
    ),
])

━━━━━━━━━━━━━━━━━━━━━━━━━━━
STREAK SİSTEMİ EKLE
━━━━━━━━━━━━━━━━━━━━━━━━━━━

game_state.dart'a ekle:
- int _streakCount = 0; // arka arkaya temizleme sayısı
- Her tur temizleme yapılırsa _streakCount++
- Yapılmazsa _streakCount = 0
- 3+ streak'te %25 bonus puan
- 5+ streak'te %50 bonus puan
- Streak kırılınca game_screen'de küçük "Streak Bitti!" yazısı

Değişen dosyalar:
- lib/screens/game_screen.dart
- lib/models/game_state.dart
```

---

## 📋 Uygulama Sırası

```
Prompt 1 → test et (kasma düzeldi mi?)
    ↓
Prompt 2 → test et (sürükleme düzeldi mi?)
    ↓
Prompt 3 → test et (animasyonlar çalışıyor mu?)
    ↓
Prompt 4 → test et (particle görünüyor mu?)
    ↓
Prompt 5 → test et (font ve UI düzeldi mi?)
    ↓
Prompt 6 → test et (sesler senkronize mi?)
    ↓
Prompt 7 → test et (combo heyecan verici mi?)
```

---

## 📦 Son pubspec.yaml dependencies

Tüm promptlar tamamlandıktan sonra
pubspec.yaml dependencies şöyle olmalı:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  google_mobile_ads: ^8.0.0
  shared_preferences: ^2.5.5
  audioplayers: ^6.6.0
  flutter_animate: ^4.5.0
  confetti: ^0.7.0
  google_fonts: ^6.2.1
```

---

## 💡 Hata Alırsan

```
Şu hatayı alıyorum:
[HATA MESAJINI BURAYA YAPISTIR]

Dosya: [DOSYA ADI]

Sadece bu dosyayı düzelt, diğerlerine dokunma.
```
