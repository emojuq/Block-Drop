# 🎮 Block Drop — Kapsamlı Düzeltme & Geliştirme Rehberi

> Kod analizi ve Block Blast karşılaştırması sonucunda
> tespit edilen tüm sorunlar ve çözümleri.

---

## 📊 Genel Durum Özeti

| Kategori | Sorun Sayısı | Öncelik |
|---|---|---|
| Performans | 2 | 🔴 Kritik |
| Animasyon & Juice | 5 | 🔴 Kritik |
| Puanlama Mantığı | 3 | 🟡 Önemli |
| Ses Sistemi | 2 | 🟡 Önemli |
| Görsel Kalite | 3 | 🟢 İyileştirme |

---

## 🔴 KRİTİK SORUNLAR

---

### SORUN 1 — 64 DragTarget Kasma Yapıyor

**Nerede:** `lib/widgets/game_board.dart`

**Problem:**
Şu an tahtadaki her hücre için ayrı bir `DragTarget` widget'ı oluşturuluyor.
Her sürükleme hareketinde Flutter bu 64 widget'ı aynı anda rebuild ediyor.
Bu, oyunun kasmasının 1 numaralı sebebi.

**Düzeltme Promptu:**
```
lib/widgets/game_board.dart dosyasını tamamen yeniden yaz.

64 adet DragTarget yerine şu yaklaşımı kullan:

1. Tahtayı CustomPainter ile çiz:
   - BoardPainter adında CustomPainter sınıfı oluştur
   - canvas.drawRRect() ile her hücreyi çiz (64 Container yerine tek paint çağrısı)
   - Dolu hücreler renkli, boş hücreler AppTheme.socketBg rengi
   - Grid çizgileri için canvas.drawLine()

2. Tek bir GestureDetector kullan:
   - onPanUpdate: sürüklenen bloğun koordinatını hesapla
       int row = (localPosition.dy / cellSize).floor()
       int col = (localPosition.dx / cellSize).floor()
   - onPanEnd: bloğu o hücreye bırak
   - DragTarget kaldır

3. Ghost preview için:
   - BoardPainter'a Set<Point<int>> ghostCells parametresi ekle
   - Painter bu hücreleri yarı saydam renkle çizsin

4. RepaintBoundary ekle:
   RepaintBoundary(child: GameBoard(...))
   RepaintBoundary(child: BlockTray(...))
```

---

### SORUN 2 — setState Tüm Ekranı Rebuild Ediyor

**Nerede:** `lib/screens/game_screen.dart`

**Problem:**
Her blok bırakışında, her animasyonda `setState(() {})` çağrılıyor.
Bu, başlıktan reklam alanına kadar her şeyi yeniden çiziyor.
Özellikle `_onBlockPlaced` metodunda ciddi bir performans kaybı.

**Düzeltme Promptu:**
```
game_screen.dart içinde setState kullanımını optimize et:

1. GameState'i ValueNotifier'a dönüştür:
   final _gameStateNotifier = ValueNotifier<GameState>(GameState());

2. Sadece değişen widget'ları ValueListenableBuilder ile sar:
   - Skor alanı → ValueListenableBuilder
   - GameBoard → ValueListenableBuilder
   - BlockTray → ValueListenableBuilder

3. Combo yazısı, reklam alanı, başlık gibi
   statik alanlar rebuild olmamalı.

4. Her RepaintBoundary içindeki widget
   sadece kendi state'i değişince rebuild olsun.
```

---

### SORUN 3 — Blok Bırakma Animasyonu Yok (En Çok Hissedilen Eksik)

**Nerede:** `lib/widgets/block_cell.dart`, `lib/widgets/game_board.dart`

**Problem:**
Block Blast'ta blok bırakılınca her hücre elastik bir bounce ile yerine oturur.
Block Drop'ta blok aniden belirir — giriş animasyonu yok.
Bu, oyunun "cansız" hissettirmesinin en büyük sebebi.

**Düzeltme Promptu:**
```
pubspec.yaml'a ekle:
  flutter_animate: ^4.5.0

Blok yerleşince her hücreye bounce animasyonu ekle:

game_board.dart içinde, yeni yerleşen hücreler için:
- _newlyPlacedCells adında Set<Point<int>> tut
- placeBlock() sonrası bu set'i güncelle
- 300ms sonra set'i temizle

BlockCell widget'ını flutter_animate ile animasyonlu hale getir:
BlockCell(color: color, size: cellSize)
  .animate(key: ValueKey('${r}_${c}_placed'))
  .scale(
    begin: const Offset(0.3, 0.3),
    end: const Offset(1.0, 1.0),
    duration: 250.ms,
    curve: Curves.elasticOut,
  )
  .fadeIn(duration: 100.ms)

Değişen dosyalar:
- lib/widgets/game_board.dart
- lib/widgets/block_cell.dart
- pubspec.yaml
```

---

### SORUN 4 — Temizleme Animasyonu Bug'ı

**Nerede:** `lib/models/game_state.dart`, `lib/screens/game_screen.dart`

**Problem:**
`lastClearedCells` seti animasyon bittikten sonra hiç temizlenmiyor.
Bu yüzden bazı hücreler yanlış zamanlarda parlıyor veya tekrar parlıyor.
Ayrıca animasyon 3 aşamalı değil, tek tip beyaz flash.

**Düzeltme Promptu:**
```
game_screen.dart içinde:

placeBlock() çağrısından sonra şunu ekle:
  if (clearedCount > 0) {
    // Animasyon süresi kadar bekle, sonra temizle
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) {
        setState(() {
          _gameState.lastClearedCells.clear();
        });
      }
    });
  }

game_board.dart içinde temizlenen hücreler için
3 aşamalı animasyon:

AnimationController ile (vsync: this, duration: 600ms):
  - 0-200ms: beyaza dön + scale 1.4x (Curves.easeOut)
  - 200-400ms: scale 0.8x'e in (Curves.easeIn)
  - 400-600ms: opacity 0'a düş, kaybol (Curves.easeIn)

Değişen dosyalar:
- lib/screens/game_screen.dart
- lib/widgets/game_board.dart
```

---

### SORUN 5 — Particle Efekti Yok

**Nerede:** `lib/screens/game_screen.dart`

**Problem:**
Block Blast'ta satır temizlenince parçacıklar saçılıyor — bu dopamin tepkisi
yaratan en önemli görsel efekt. Block Drop'ta sadece beyaz flash var.

**Düzeltme Promptu:**
```
pubspec.yaml'a ekle:
  confetti: ^0.7.0

game_screen.dart içinde:

1. ConfettiController ekle:
   late ConfettiController _confettiController;
   
   initState'te başlat:
   _confettiController = ConfettiController(
     duration: const Duration(milliseconds: 1000)
   );
   
   dispose'ta temizle:
   _confettiController.dispose();

2. Satır temizlenince çalıştır:
   if (clearedCount > 0) {
     _confettiController.play();
     HapticFeedback.mediumImpact();
   }
   if (clearedCount >= 3) {
     HapticFeedback.heavyImpact();
   }

3. Stack içine ConfettiWidget koy:
   ConfettiWidget(
     confettiController: _confettiController,
     blastDirectionality: BlastDirectionality.explosive,
     shouldLoop: false,
     numberOfParticles: clearedCount >= 3 ? 40 : 20,
     gravity: 0.3,
     colors: const [
       Colors.yellow, Colors.cyan, Colors.pink,
       Colors.green, Colors.orange, Colors.purple,
       Colors.white,
     ],
     minimumSize: const Size(4, 4),
     maximumSize: const Size(10, 10),
   )

Değişen dosyalar:
- lib/screens/game_screen.dart
- pubspec.yaml
```

---

## 🟡 ÖNEMLİ SORUNLAR

---

### SORUN 6 — Puanlama Formülü Block Blast ile Uyumsuz

**Nerede:** `lib/models/game_state.dart`

**Problem:**
Şu anki formül: `clearedCount * 100 * clearedCount`
Block Blast formülü: `10 puan × temizlenen kare sayısı + streak çarpanı`

Ayrıca blok yerleştirince satır temizlenmese de +10 puan veriliyor —
bu Block Blast'ta yok ve yanlış bir davranış.

**Düzeltme Promptu:**
```
game_state.dart içinde puanlama sistemini yeniden yaz:

1. Baz puan:
   Tek satır/sütun = 8 kare × 10 = 80 puan
   (her temizlenen kare için 10 puan)

2. Aynı anda birden fazla temizleme bonusu:
   2 satır/sütun: baz × 1.5 + 30 bonus
   3 satır/sütun: baz × 2.0 + 80 bonus
   4+ satır/sütun: baz × 3.0 + 200 bonus

3. STREAK sistemi ekle:
   int _streakCount = 0;
   
   - Her tur en az 1 satır/sütun temizlenirse _streakCount++
   - Hiç temizlenmezse _streakCount = 0
   - 3+ streak: %25 bonus
   - 5+ streak: %50 bonus
   - 8+ streak: %100 bonus (2x)
   
   Streak kırılınca game_screen'de
   küçük "Streak bitti!" animasyonu göster.

4. Blok yerleştirme puanını kaldır:
   score += 10 satırını SİL
   (sadece satır/sütun temizleyince puan verilmeli)

5. Yeni alan ekle:
   int streakCount = 0;
   int streakBonus = 0;

Değişen dosya: lib/models/game_state.dart
```

---

### SORUN 7 — Ses Gecikmeli Çalıyor

**Nerede:** `lib/services/audio_service.dart`

**Problem:**
`AudioPlayer.play()` her çağrıda ses dosyasını yüklüyor.
Bu 150-200ms gecikmeye neden oluyor.
Block Blast'ta sesler frame-perfect — sıfır gecikme.

**Düzeltme Promptu:**
```
lib/services/audio_service.dart dosyasını yeniden yaz:

1. Ses önbelleğe al (uygulama başlarken yükle):
   static final Map<String, AudioPlayer> _players = {};
   
   static Future<void> init() async {
     final sounds = [
       'audio/place_block.mp3',
       'audio/clear_line.mp3',
       'audio/combo.mp3',
       'audio/game_over.mp3',
     ];
     for (final s in sounds) {
       final player = AudioPlayer();
       await player.setSource(AssetSource(s));
       await player.setReleaseMode(ReleaseMode.stop);
       _players[s] = player;
     }
   }

2. Her ses için ayrı AudioPlayer instance:
   static final _placePlayer = AudioPlayer();
   static final _clearPlayer = AudioPlayer();
   static final _comboPlayer = AudioPlayer();
   static final _gameOverPlayer = AudioPlayer();

3. Oynatma metodları:
   static void playPlace() =>
     _placePlayer.seek(Duration.zero).then((_) => _placePlayer.resume());
   
   static void playClear() =>
     _clearPlayer.seek(Duration.zero).then((_) => _clearPlayer.resume());

4. Ses zamanlaması:
   - place_block: blok bırakılınca ANINDA
   - clear_line: temizleme animasyonu başlarken
   - combo: clear_line'dan 80ms SONRA
   - game_over: 300ms bekle sonra çal (kararma animasyonuyla eş)

5. BGM için fade out:
   static Future<void> fadeBgm() async {
     for (double v = 0.4; v >= 0; v -= 0.04) {
       await Future.delayed(const Duration(milliseconds: 50));
       await _bgmPlayer.setVolume(v);
     }
     await _bgmPlayer.stop();
   }

Değişen dosya: lib/services/audio_service.dart
```

---

### SORUN 8 — Sürükleme Offset'i Yanlış

**Nerede:** `lib/widgets/block_tray.dart`

**Problem:**
Sürüklenen bloğun feedback boyutu ile ızgaradaki hücre boyutu farklı
hesaplandığı için blok parmağa tam oturmuyor.

**Düzeltme Promptu:**
```
lib/widgets/block_tray.dart dosyasını düzelt:

1. BlockTray, cellSize parametresini dışarıdan alsın:
   const BlockTray({
     required this.tray,
     required this.cellSize,  // ← ekle
     required this.onDragStarted,
     required this.onDragEnd,
   });

2. Tray'deki blok gösterimi küçük (0.7x):
   Transform.scale(scale: 0.7, child: BlockPiece(..., cellSize: cellSize))

3. Feedback tam boyutta (1.0x) ve parmağın altında:
   Draggable(
     feedback: Material(
       color: Colors.transparent,
       child: Opacity(
         opacity: 0.85,
         child: BlockPiece(..., cellSize: cellSize),
       ),
     ),
     dragAnchorStrategy: (draggable, context, position) {
       // Bloğun merkezi parmağın altına gelsin
       final RenderBox renderObject =
         context.findRenderObject()! as RenderBox;
       return renderObject.globalToLocal(position);
     },
     childWhenDragging: Opacity(
       opacity: 0.2,
       child: BlockPiece(...),
     ),
   )

4. game_screen.dart'ta cellSize'ı tray'e geçir:
   BlockTray(
     tray: _gameState.availableBlocks,
     cellSize: _cellSize,  // game_board ile aynı değer
     ...
   )

Değişen dosyalar:
- lib/widgets/block_tray.dart
- lib/screens/game_screen.dart
```

---

## 🟢 İYİLEŞTİRMELER

---

### İYİLEŞTİRME 1 — Özel Font Eksik

**Nerede:** `lib/theme/app_theme.dart`, tüm ekranlar

**Problem:**
Varsayılan Flutter fontu kullanılıyor. Block Blast'ta kalın, oyunsu bir font var.
Bu görsel kaliteyi büyük ölçüde etkiliyor.

**Düzeltme Promptu:**
```
pubspec.yaml'a ekle:
  google_fonts: ^6.2.1

lib/theme/app_theme.dart içinde font stillerini tanımla:

import 'package:google_fonts/google_fonts.dart';

static TextStyle get titleStyle => GoogleFonts.bungee(
  fontSize: 28,
  color: Colors.white,
  letterSpacing: 2,
);

static TextStyle get scoreStyle => GoogleFonts.nunito(
  fontSize: 32,
  fontWeight: FontWeight.w800,
  color: Colors.white,
);

static TextStyle get labelStyle => GoogleFonts.nunito(
  fontSize: 13,
  fontWeight: FontWeight.w600,
  color: Colors.white70,
  letterSpacing: 1.5,
);

Tüm ekranlarda ilgili Text widget'larını bu stillerle güncelle.

Değişen dosyalar:
- lib/theme/app_theme.dart
- lib/screens/game_screen.dart
- lib/screens/game_over_screen.dart
- lib/screens/main_menu_screen.dart
```

---

### İYİLEŞTİRME 2 — Skor Animasyonu Sönük

**Nerede:** `lib/screens/game_screen.dart`

**Problem:**
Skor değişince direkt güncelleniyor. Block Blast'ta skor sayacı
yukarı doğru "koşarak" yeni değere ulaşır.

**Düzeltme Promptu:**
```
game_screen.dart içinde skor widget'ını değiştir:

AnimatedSwitcher(
  duration: const Duration(milliseconds: 400),
  transitionBuilder: (child, animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -0.8),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  },
  child: Text(
    _gameState.score.toString(),
    key: ValueKey(_gameState.score),
    style: AppTheme.scoreStyle,
  ),
)

Ayrıca skor artışı büyükse (100+) kısa bir
altın rengi pulse ekle:
Text('+$gained', style: TextStyle(color: Colors.amber))
  .animate().fadeIn(100.ms).moveY(begin: 0, end: -30, duration: 600.ms)
  .fadeOut(duration: 300.ms, delay: 300.ms)
```

---

### İYİLEŞTİRME 3 — Combo Ekranı Zayıf

**Nerede:** `lib/screens/game_screen.dart`

**Problem:**
Combo yazısı var ama ekran flash'ı ve dopamin etkisi yetersiz.
Block Blast'ta combo anında arka plan kısaca parlıyor, yazı elatik giriş yapıyor.

**Düzeltme Promptu:**
```
game_screen.dart içinde combo widget'ını yeniden yaz:

Stack içine ekle:
if (_showCombo)
  Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'COMBO',
          style: GoogleFonts.bungee(
            fontSize: 14,
            color: Colors.white70,
            letterSpacing: 10,
          ),
        ),
        Text(
          '×$_comboCount',
          style: GoogleFonts.bungee(
            fontSize: 64,
            color: _comboCount >= 3 ? Colors.deepOrange : Colors.amber,
            shadows: [
              Shadow(
                color: (_comboCount >= 3 ? Colors.orange : Colors.yellow)
                    .withOpacity(0.8),
                blurRadius: 30,
              ),
            ],
          ),
        ),
      ],
    )
    .animate(key: ValueKey(_comboKey))
    .scale(
      begin: const Offset(0.3, 0.3),
      curve: Curves.elasticOut,
      duration: 500.ms,
    )
    .then(delay: 800.ms)
    .moveY(end: -80, duration: 500.ms, curve: Curves.easeIn)
    .fadeOut(duration: 300.ms),
  ),

Ekran flash efekti:
if (_showCombo)
  Positioned.fill(
    child: IgnorePointer(
      child: Container(color: Colors.white)
        .animate(key: ValueKey('flash_$_comboKey'))
        .fadeIn(duration: 60.ms)
        .then()
        .fadeOut(duration: 200.ms),
    ),
  ),
```

---

## 📋 Uygulama Sırası

```
AŞAMA 1 — Performans (Önce bunlar, kasma biter)
  └── Sorun 1: CustomPainter + GestureDetector
  └── Sorun 2: setState optimizasyonu

AŞAMA 2 — Game Feel (Oyun canlılanır)
  └── Sorun 3: Blok bırakma bounce animasyonu
  └── Sorun 4: Temizleme animasyonu bug düzeltmesi
  └── Sorun 5: Particle efekti (confetti)

AŞAMA 3 — Oynanış Kalitesi
  └── Sorun 6: Puanlama formülü + streak sistemi
  └── Sorun 7: Ses önbellekleme
  └── Sorun 8: Sürükleme offset düzeltmesi

AŞAMA 4 — Görsel Cilalama
  └── İyileştirme 1: Google Fonts entegrasyonu
  └── İyileştirme 2: Skor koşu animasyonu
  └── İyileştirme 3: Güçlü combo ekranı
```

---

## 📦 Son pubspec.yaml Dependencies

Tüm düzeltmeler tamamlandığında:

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

## 🔧 Hata Alırsan

Her prompt sonrası `flutter run` ile test et.
Hata alırsan Gemini'ye şunu ver:

```
Şu hatayı alıyorum:
[HATA MESAJINI BURAYA YAPISTIR]

İlgili dosya: [DOSYA ADI]

Sadece bu dosyayı düzelt, diğerlerine dokunma.
Hatanın sebebini önce kısaca açıkla.
```

---

## 🎯 Öncelik Özeti

| # | Sorun | Etki | Süre |
|---|---|---|---|
| 1 | 64 DragTarget → CustomPainter | Kasma biter | ~2 saat |
| 2 | setState optimizasyonu | FPS artar | ~1 saat |
| 3 | Blok bırakma bounce | Oyun canlılanır | ~30 dk |
| 4 | Temizleme animasyon bug | Görsel temizlenir | ~20 dk |
| 5 | Particle efekti | Dopamin artar | ~30 dk |
| 6 | Streak + puanlama | Strateji derinleşir | ~1 saat |
| 7 | Ses önbellekleme | Sıfır gecikme | ~30 dk |
| 8 | Sürükleme offset | Kontrol iyileşir | ~20 dk |
| 9 | Google Fonts | Görsel kalite | ~20 dk |
| 10 | Skor animasyonu | Tatmin artar | ~20 dk |
| 11 | Combo ekranı | Heyecan artar | ~30 dk |
