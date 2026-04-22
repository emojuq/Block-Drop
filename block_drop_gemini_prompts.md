# 🎮 Block Drop — Gemini Prompt Rehberi

> Block Blast benzeri Flutter oyunu geliştirmek için
> Google AI Studio / Gemini'ye sırayla verilecek promptlar.

---

## 📋 Kullanım Sırası

```
Prompt 1 → Prompt 2 → Prompt 3 → flutter run ile test et
                                          ↓
                                   Hata varsa → Prompt 4
                                          ↓
                                   Çalışıyorsa → Prompt 5
```

---

## 🚀 PROMPT 1 — Proje Başlangıcı & Temel Yapı

```
Sen deneyimli bir Flutter oyun geliştiricisisin.
Benimle birlikte Block Blast benzeri bir mobil
bulmaca oyunu geliştireceğiz. Oyunun adı
"Block Drop" olacak.

=== OYUN MEKANİĞİ ===
- 8x8'lik bir grid (tahta) üzerinde oynanır
- Her turda ekranın altında 3 adet rastgele blok şekli gösterilir
- Oyuncu bu blokları sürükleyip tahtaya bırakır
- Bir satır VEYA sütun tamamen dolduğunda o satır/sütun
  temizlenir ve puan kazanılır
- Bloklar DÖNDÜRÜLEMEZ
- Zaman sınırı YOKTUR
- Mevcut 3 bloktan herhangi biri tahtaya sığmıyorsa
  oyun biter (Game Over)
- Aynı anda birden fazla satır/sütun temizlenirse
  COMBO bonusu verilir

=== BLOK ŞEKİLLERİ ===
Şu blok şekillerini tanımla (her biri 2D array olarak):
1. 1x1 tek kare
2. 1x2 yatay
3. 2x1 dikey
4. 1x3 yatay
5. 3x1 dikey
6. 2x2 kare
7. L şekli (3x2, sol alt köşe dolu)
8. Ters L şekli
9. T şekli
10. 3x3 tam kare
11. 1x4 yatay
12. 4x1 dikey
13. Z şekli
14. S şekli

=== TEKNİK GEREKSİNİMLER ===
- Flutter (null safety, en güncel sözdizimi)
- Sadece şu paketler kullanılabilir:
  * flutter/material.dart (built-in)
  * dart:math (built-in)
- Harici paket KULLANMA
- State management: setState ile basit tutulsun
- Kod modüler olsun: her şeyi main.dart'a koyma

=== DOSYA YAPISI ===
Şu dosyaları oluştur:
lib/
  main.dart                   → Uygulama girişi
  models/block_shape.dart     → Blok şekillerinin tanımları
  models/game_state.dart      → Oyun durumu ve mantığı
  widgets/game_board.dart     → Tahta UI
  widgets/block_tray.dart     → Alttaki 3 blok alanı
  widgets/block_piece.dart    → Tek bir blok parçası widget'ı
  screens/game_screen.dart    → Ana oyun ekranı
  screens/game_over_screen.dart → Oyun bitti ekranı

=== PUANLAMA ===
- Tek satır/sütun temizleme: 10 × temizlenen kare sayısı puan
- 2 aynı anda: x2 çarpan
- 3+ aynı anda: x3 çarpan
- En yüksek skor SharedPreferences olmadan
  sadece o oturum için tutulsun (şimdilik)

=== GÖRSEL TASARIM ===
- Koyu tema (dark background: #1a1a2e)
- Grid hücreleri: koyu mavi (#16213e), ince kenarlıkla
- Her blok şekli için farklı renk:
  Kırmızı, Mavi, Yeşil, Sarı, Mor, Turuncu, Pembe, Cyan
- Tahta boyutu ekrana göre responsive olsun
- Grid çizgileri hafifçe görünsün

Şimdi sadece şu adımı yap:
1. block_shape.dart dosyasını yaz (tüm şekil tanımları)
2. game_state.dart dosyasını yaz (tahta matrisi,
   blok yerleştirme, satır temizleme, skor mantığı)

Kodu tam ve çalışır şekilde yaz. Placeholder veya
"// TODO" bırakma. Her dosyayı ayrı kod bloğunda göster.
```

---

## 🎮 PROMPT 2 — UI Widgetları

```
Harika. Şimdi UI widget dosyalarını yaz:

1. widgets/block_piece.dart
   - Tek bir blok şeklini çizen widget
   - Parametre olarak BlockShape ve double cellSize alsın
   - Her hücreyi renkli Container olarak çizsin
   - Hafif gölge (BoxShadow) ekle

2. widgets/game_board.dart
   - 8x8 grid'i çizen widget
   - Her hücre dolu/boş durumuna göre renk alsın
   - DragTarget ile sürükle-bırak kabul etsin
   - Oyuncu bir bloğu üzerine sürüklediğinde
     yerleşeceği hücreleri highlight et (önizleme)
   - Responsive: mevcut ekran genişliğine göre
     hücre boyutunu hesapla

3. widgets/block_tray.dart
   - Altta 3 blok şeklini gösteren alan
   - Her blok Draggable widget olsun
   - Kullanılmış bloklar soluk (opacity: 0.3) görünsün
   - Bloklar arasında eşit boşluk olsun

Bir önceki adımda yazdığın GameState ve
BlockShape modellerini kullan.
```

---

## 🖥️ PROMPT 3 — Ekranlar ve Ana Uygulama

```
Son adım olarak ekranları ve main.dart'ı yaz:

1. screens/game_screen.dart
   - GameState'i yönetir
   - Üstte: "BLOCK DROP" başlığı, skor ve en yüksek skor
   - Ortada: GameBoard widget'ı
   - Altta: BlockTray widget'ı
   - Blok yerleştirildiğinde:
     * Eğer satır/sütun temizlendiyse kısa bir
       titreşim efekti (HapticFeedback.lightImpact)
     * Combo varsa ekranda "COMBO x2!" yazısı
       1.5 saniye göster (AnimatedOpacity ile)
   - Game Over olduğunda GameOverScreen'e geç

2. screens/game_over_screen.dart
   - Ortada büyük "GAME OVER" yazısı
   - Skor göster
   - "TEKRAR OYNA" butonu → yeni oyun başlatır
   - Arka plan yarı saydam, animasyonla açılır

3. main.dart
   - Uygulama adı: "Block Drop"
   - Sadece dikey yönlendirme (portrait only)
   - Koyu tema
   - GameScreen ile başla

Tüm dosyaları eksiksiz yaz.
```

---

## 🔧 PROMPT 4 — Hata Düzeltme

> Kodu çalıştırdığında hata alırsan bu promptu kullan.
> Hata mesajını ve dosya adını ekleyerek Gemini'ye gönder.

```
Şu hatayı alıyorum:

[HATA MESAJINI BURAYA YAPISTIR]

İlgili dosya: [DOSYA ADINI YAZ]

Hatanın sebebini açıkla ve sadece o dosyanın
düzeltilmiş halini yaz. Diğer dosyalara dokunma.
```

---

## ✨ PROMPT 5 — Oyun Hissi (Game Feel)

> Temel oyun çalıştıktan sonra bu promptu kullan.

```
Temel oyun çalışıyor. Şimdi "game feel" ekleyelim:

1. Satır temizlendiğinde:
   - Temizlenen hücreler 300ms içinde parlayıp
     kaybolsun (AnimationController ile)
   - HapticFeedback.mediumImpact

2. Blok yerleştiğinde:
   - HapticFeedback.selectionClick

3. Game Over olduğunda:
   - HapticFeedback.heavyImpact
   - Tahta siyaha dönsün (300ms geçiş)

4. Skor artışı:
   - Skor değiştiğinde sayı yukarı "uçsun"
     (AnimatedSwitcher ile)

5. Combo mesajı:
   - "COMBO x2!" sarı renkte
   - Yukarı çıkarak solar (TweenAnimationBuilder)

Sadece değişen kısımları göster, tüm dosyayı
tekrar yazma. Hangi satırın nereye geleceğini
açıkça belirt.
```

---

## 🎯 PROMPT 6 — Bonus: Reklam Entegrasyonu (Yayın Öncesi)

> Oyunu Play Store'a yüklemeden önce bu promptu kullan.

```
Oyuna Google AdMob reklam entegrasyonu ekle.

pubspec.yaml'a şu paketi ekle:
  google_mobile_ads: ^5.1.0

Reklam türleri:
1. Banner reklam → game_screen.dart altında sabit
2. Interstitial reklam → her Game Over sonrası
3. Rewarded reklam → Game Over ekranında
   "Reklamı İzle, Devam Et" butonu

Test ID'lerini kullan (gerçek ID'leri ben vereceğim):
- Banner:        ca-app-pub-3940256099942544/6300978111
- Interstitial:  ca-app-pub-3940256099942544/1033173712
- Rewarded:      ca-app-pub-3940256099942544/5224354917

Mevcut dosyaların yapısını bozmadan ekle.
Hangi dosyada ne değiştiğini başlıkla belirt.
```

---

## 💡 İpuçları

| Durum | Ne Yapmalısın |
|---|---|
| Gemini kodu yarıda kesiyor | "Kaldığın yerden devam et" de |
| Kod çalışmıyor | Prompt 4'ü kullan, hata mesajını yapıştır |
| Bir özellik yanlış çalışıyor | Sadece o dosyayı açıkla, yeniden yaz |
| Tasarımı değiştirmek istiyorsun | "Şu rengi / boyutu değiştir" diye sor |
| Yeni özellik eklemek istiyorsun | Önce temel oyunu bitir, sonra sor |

---

> 🚀 **Başarılar!** Her prompt sonrası `flutter run` ile test etmeyi unutma.
