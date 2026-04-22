import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/game_state.dart';
import '../services/storage_service.dart';
import '../services/mission_service.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/game_board.dart';
import '../widgets/block_tray.dart';
import '../widgets/block_piece.dart';
import 'game_over_screen.dart';
import 'main_menu_screen.dart';
import 'settings_screen.dart';

int _globalHighScore = 0;

class GameScreen extends StatefulWidget {
  final GameState? gameState;

  const GameScreen({super.key, this.gameState});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState _gameState;
  bool _showCombo = false;
  int _comboCount = 0;
  int _comboKey = 0;

  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;

  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _gameState = widget.gameState ?? GameState();
    _loadHighScore();
    _loadBannerAd();
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-1754889019315119/4088743847',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdLoaded = false;
        },
      ),
    );
  }

  Future<void> _loadHighScore() async {
    int saved = await StorageService.getHighScore();
    if (saved > _globalHighScore) {
      setState(() {
        _globalHighScore = saved;
      });
    }
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-1754889019315119/2391377150',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-1754889019315119/3635964033',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdLoaded = false;
        },
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }

  void _onBlockPlaced(int blockIndex, int row, int col) {
    int clearedCount = _gameState.placeBlock(blockIndex, row, col);
    
    if (clearedCount != -1) {
      setState(() {
        HapticFeedback.selectionClick();

        if (_gameState.score > _globalHighScore) {
          _globalHighScore = _gameState.score;
          StorageService.saveHighScore(_globalHighScore);
        }

        if (clearedCount >= 2) {
          HapticFeedback.mediumImpact();
          AudioService.playSound('combo');
          _triggerCombo(clearedCount);
        } else if (clearedCount == 1) {
          HapticFeedback.mediumImpact();
          AudioService.playSound('clear_line');
        } else {
          AudioService.playSound('place_block');
        }

        if (_gameState.isGameOver) {
          HapticFeedback.heavyImpact();
          AudioService.playSound('game_over');
          _showGameOver();
        }
      });
    }
  }

  void _triggerCombo(int count) {
    setState(() {
      _comboCount = count;
      _showCombo = true;
      _comboKey = DateTime.now().millisecondsSinceEpoch;
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showCombo = false;
        });
      }
    });
  }

  void _showGameOver() {
    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      _interstitialAd!.show();
    }
    
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (pContext, animation, secondaryAnimation) => GameOverScreen(
          gameState: _gameState,
          onRestart: () {
            Navigator.of(pContext).pop();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (c) => const GameScreen())
            );
          },
          onContinue: () {
            Navigator.of(pContext).pop();
            setState(() {
              _gameState.continueGame(); // clear board for reward, keep score
            });
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Top texts & spacing: ~50, Score Panel/Hold spacing: ~30, Tray padding: ~30, Ad: ~50
            // Dynamic elements that scale with boardCellSize:
            // 1) GameBoard vertically: 8 * C
            // 2) BlockTray vertically: 4.5 * 0.55 * C ≈ 2.475 * C
            // 3) Hold Box vertically: 4.5 * 0.55 * C ≈ 2.475 * C
            // Total scalable vertical space required = ~12.95 * boardCellSize. Thus we divide by 13.0
            double fixedVerticalSpace = 320.0; 
            if (_isBannerAdLoaded && _bannerAd != null) {
              fixedVerticalSpace += _bannerAd!.size.height.toDouble() - 50.0;
            }

            double availableH = constraints.maxHeight - fixedVerticalSpace;
            if (availableH < 0) availableH = 100; 

            // Safely allocate height divided by 13.0 to leave room for paddings
            double maxCellByHeight = availableH / 13.0;
            double maxCellByWidth = (constraints.maxWidth - 32.0) / 8.0;

            double boardCellSize = min(maxCellByWidth, maxCellByHeight);
            if (boardCellSize < 0) boardCellSize = 10;

            return Column(
              children: [
                const SizedBox(height: 10),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const SizedBox(width: double.infinity, height: 40),
                    Text(
                      "BLOCK DROP",
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                    Positioned(
                      right: 15,
                      child: IconButton(
                        icon: Icon(Icons.pause_circle_filled, color: AppTheme.textSecondary, size: 36),
                        onPressed: _showPauseMenu,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildHoldBox(boardCellSize),
                    _buildScorePanel("SKOR", _gameState.score),
                    _buildScorePanel("EN YÜKSEK", _globalHighScore),
                  ],
                ),
                const SizedBox(height: 15),
                _buildPowerups(),
                const SizedBox(height: 15),
                Expanded(
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey('combo_$_comboKey'),
                    tween: Tween<double>(begin: 0.0, end: _showCombo ? 1.0 : 0.0),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOut,
                    child: GameBoard(
                      gameState: _gameState,
                      onBlockPlaced: _onBlockPlaced,
                      onHammerTapped: (r, c) {
                         setState(() {
                            if (_gameState.useHammer(r, c)) {
                               HapticFeedback.heavyImpact();
                            }
                         });
                      },
                      cellSize: boardCellSize,
                    ),
                    builder: (context, value, child) {
                      // Massive Screen Shake
                      double shakeX = _showCombo ? sin(value * pi * 40) * 10 * (1 - value) : 0;
                      double shakeY = _showCombo ? cos(value * pi * 40) * 10 * (1 - value) : 0;

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.translate(
                            offset: Offset(shakeX, shakeY),
                            child: child!, // GameBoard
                          ),
                          if (_showCombo)
                            Transform.scale(
                              scale: 1.0 + sin(value * pi) * 0.5,
                              child: Transform.translate(
                                offset: Offset(0, -100 * value),
                                child: Opacity(
                                  opacity: (1.0 - value).clamp(0.0, 1.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                    decoration: BoxDecoration(
                                      color: Colors.amberAccent,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: Colors.white, width: 3),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.deepOrangeAccent.withAlpha(200),
                                          blurRadius: 30 * (1 - value),
                                          spreadRadius: 10 * (1 - value),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      "COMBO x$_comboCount!",
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 40,
                                        fontWeight: FontWeight.w900,
                                        fontStyle: FontStyle.italic,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                BlockTray(
                  gameState: _gameState,
                  boardCellSize: boardCellSize,
                ),
                
                if (_isBannerAdLoaded && _bannerAd != null)
                  Container(
                    color: Colors.black,
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    alignment: Alignment.center,
                    child: AdWidget(ad: _bannerAd!),
                  )
                else
                  const SizedBox(height: 50),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildHoldBox(double boardCellSize) {
    double trayCellSize = boardCellSize * 0.55;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "BEKLET",
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        DragTarget<int>(
          onWillAcceptWithDetails: (details) {
            return details.data >= 0; // Only accept pieces from the tray
          },
          onAcceptWithDetails: (details) {
            setState(() {
              _gameState.swapHoldBlock(details.data);
              HapticFeedback.lightImpact();
              if (_gameState.isGameOver) {
                 _showGameOver();
              }
            });
          },
          builder: (context, candidateData, rejectedData) {
            Widget content;
            if (_gameState.holdBlock == null) {
              content = SizedBox(width: trayCellSize * 3.5, height: trayCellSize * 3.5);
            } else {
              content = Draggable<int>(
                data: -1, // Distinguishes hold block from tray blocks
                feedback: Material(
                  color: Colors.transparent,
                  child: BlockPiece(shape: _gameState.holdBlock!, cellSize: boardCellSize),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: BlockPiece(shape: _gameState.holdBlock!, cellSize: trayCellSize),
                ),
                dragAnchorStrategy: pointerDragAnchorStrategy,
                child: BlockPiece(shape: _gameState.holdBlock!, cellSize: trayCellSize),
              );
            }

            return Container(
              width: trayCellSize * 4.5,
              height: trayCellSize * 4.5,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: candidateData.isNotEmpty ? AppTheme.borderHighlight : AppTheme.socketBg, // Brightens on hover
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border, width: 2),
                boxShadow: [BoxShadow(color: AppTheme.borderShadow, blurRadius: 5)],
              ),
              child: Center(child: content),
            );
          },
        ),
      ],
    );
  }

  Widget _buildScorePanel(String title, int value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.5),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: Text(
            value.toString(),
            key: ValueKey<int>(value),
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _showPauseMenu() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AlertDialog(
            backgroundColor: AppTheme.dialogBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: AppTheme.border, width: 2)),
            contentPadding: const EdgeInsets.all(30),
            title: Center(
              child: Text(
                "DURAKLATILDI",
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                _buildPauseButton("DEVAM ET", Colors.blueAccent, () => Navigator.pop(context)),
                const SizedBox(height: 15),
                _buildPauseButton("GÜNLÜK GÖREVLER", Colors.green, () {
                  Navigator.pop(context);
                  _showMissionsDialog();
                }),
                const SizedBox(height: 15),
                _buildPauseButton("AYARLAR", Colors.purpleAccent, () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(builder: (c) => const SettingsScreen()));
                }),
                const SizedBox(height: 15),
                _buildPauseButton("YENİDEN BAŞLA", Colors.orangeAccent, () {
                  Navigator.pop(context); // Close dialog
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (c) => const GameScreen())); // Restart game
                }),
                const SizedBox(height: 15),
                _buildPauseButton("ANA MENÜYE DÖN", Colors.redAccent, () {
                  Navigator.pop(context); // Close dialog
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (c) => const MainMenuScreen())); // To main menu
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPauseButton(String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showMissionsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.dialogBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: AppTheme.border)),
          title: Center(child: Text("GÜNLÜK GÖREVLER", style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold))),
          content: SizedBox(
            width: double.maxFinite,
            child: ValueListenableBuilder<List<Mission>>(
              valueListenable: MissionService.missions,
              builder: (context, missionsList, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: missionsList.map((m) {
                    double progressPct = (m.progress / m.target).clamp(0.0, 1.0);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(m.title, style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          LinearProgressIndicator(
                            value: progressPct,
                            backgroundColor: AppTheme.boardBg,
                            color: m.isCompleted ? Colors.green : Colors.blueAccent,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 5),
                          Text("${m.progress} / ${m.target}", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        ],
                      ),
                      trailing: Icon(m.isCompleted ? Icons.check_circle : Icons.circle_outlined, color: m.isCompleted ? Colors.green : AppTheme.textSecondary),
                    );
                  }).toList(),
                );
              }
            )
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("KAPAT", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))
            )
          ],
        );
      }
    );
  }

  void _handlePowerup(String type, VoidCallback action) {
    int uses = 0;
    if (type == 'shuffle') uses = _gameState.shuffleUses;
    if (type == 'undo') uses = _gameState.undoUses;
    if (type == 'hammer') uses = _gameState.hammerUses;

    if (uses < 3) {
      action();
      setState(() {
        if (type == 'shuffle') _gameState.shuffleUses++;
        if (type == 'undo') _gameState.undoUses++;
        if (type == 'hammer') _gameState.hammerUses++;
      });
    } else {
      if (_isRewardedAdLoaded && _rewardedAd != null) {
        _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
           action();
        });
        _isRewardedAdLoaded = false;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reklam yükleniyor, lütfen bekleyin.')));
      }
    }
  }

  Widget _buildPowerups() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPowerupBtn(Icons.shuffle_rounded, Colors.blue, "KARIŞTIR", () {
          _handlePowerup('shuffle', () {
            setState(() {
              _gameState.shuffleBlocks();
              HapticFeedback.lightImpact();
            });
          });
        }),
        const SizedBox(width: 25),
        _buildPowerupBtn(Icons.undo_rounded, Colors.purpleAccent, "GERİ AL", () {
          _handlePowerup('undo', () {
            setState(() {
               if (_gameState.undoLastMove()) {
                  HapticFeedback.mediumImpact();
               }
            });
          });
        }),
        const SizedBox(width: 25),
        _buildPowerupBtn(Icons.gavel_rounded, _gameState.isHammerActive ? Colors.redAccent : Colors.orangeAccent, "KIR", () {
          _handlePowerup('hammer', () {
            setState(() {
               _gameState.isHammerActive = !_gameState.isHammerActive;
               HapticFeedback.lightImpact();
            });
          });
        }),
      ],
    );
  }

  Widget _buildPowerupBtn(IconData icon, Color color, String label, VoidCallback onTap) {
     return Column(
      children: [
         InkWell(
           onTap: onTap,
           borderRadius: BorderRadius.circular(20),
           child: Container(
             padding: const EdgeInsets.all(12),
             decoration: BoxDecoration(
               color: color.withOpacity(0.15),
               shape: BoxShape.circle,
               border: Border.all(color: color.withOpacity(0.5), width: 2),
             ),
             child: Icon(icon, color: color, size: 28),
           ),
         ),
         const SizedBox(height: 6),
         Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
      ]
     );
  }
}

