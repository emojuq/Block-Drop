import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/block_shape.dart';
import '../theme/app_theme.dart';

class GameBoard extends StatefulWidget {
  final GameState gameState;
  final Function(int blockIndex, int row, int col) onBlockPlaced;
  final Function(int row, int col)? onHammerTapped;
  final double cellSize;

  const GameBoard({
    super.key,
    required this.gameState,
    required this.onBlockPlaced,
    this.onHammerTapped,
    required this.cellSize,
  });

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> with TickerProviderStateMixin {
  int? hoverRow;
  int? hoverCol;
  int? hoverBlockIndex;
  late AnimationController _clearAnimController;
  late AnimationController _placeAnimController;

  @override
  void initState() {
    super.initState();
    _clearAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _placeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _placeAnimController.value = 1.0;
  }

  @override
  void didUpdateWidget(GameBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.gameState.lastClearedCells.isNotEmpty && 
        oldWidget.gameState.lastClearedCells.isEmpty) {
      _clearAnimController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _clearAnimController.dispose();
    _placeAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: TweenAnimationBuilder<Color?>(
        tween: ColorTween(
          begin: AppTheme.boardBg,
          end: widget.gameState.isGameOver ? Colors.black : AppTheme.boardBg,
        ),
        duration: const Duration(milliseconds: 300),
        builder: (context, boardColor, child) {
          return Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: boardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.border, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.borderShadow,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: GestureDetector(
              onTapUp: (details) {
                if (widget.gameState.isHammerActive && widget.onHammerTapped != null) {
                  int r = (details.localPosition.dy / widget.cellSize).floor();
                  int c = (details.localPosition.dx / widget.cellSize).floor();
                  widget.onHammerTapped!(r, c);
                }
              },
              child: DragTarget<int>(
                onWillAcceptWithDetails: (details) {
                   return true;
                },
                onMove: (details) {
                  RenderBox box = context.findRenderObject() as RenderBox;
                  Offset localOffset = box.globalToLocal(details.offset);
                  
                  int r = ((localOffset.dy + widget.cellSize / 2) / widget.cellSize).floor();
                  int c = ((localOffset.dx + widget.cellSize / 2) / widget.cellSize).floor();

                  int blockIndex = details.data;
                  BlockShape? shape = blockIndex == -1 ? widget.gameState.holdBlock : widget.gameState.availableBlocks[blockIndex];
                  
                  if (shape != null) {
                     if (widget.gameState.canPlace(shape, r, c)) {
                        if (hoverRow != r || hoverCol != c || hoverBlockIndex != blockIndex) {
                           setState(() {
                             hoverRow = r;
                             hoverCol = c;
                             hoverBlockIndex = blockIndex;
                           });
                        }
                     } else {
                        if (hoverRow != null) {
                           setState(() {
                              hoverRow = null;
                              hoverCol = null;
                              hoverBlockIndex = null;
                           });
                        }
                     }
                  }
                },
                onAcceptWithDetails: (details) {
                  int blockIndex = details.data;
                  if (hoverRow != null && hoverCol != null) {
                    widget.onBlockPlaced(blockIndex, hoverRow!, hoverCol!);
                    _placeAnimController.forward(from: 0.0);
                  }
                  setState(() {
                    hoverRow = null;
                    hoverCol = null;
                    hoverBlockIndex = null;
                  });
                },
                onLeave: (data) {
                  setState(() {
                    hoverRow = null;
                    hoverCol = null;
                    hoverBlockIndex = null;
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  return AnimatedBuilder(
                    animation: Listenable.merge([_clearAnimController, _placeAnimController]),
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size(GameState.cols * widget.cellSize, GameState.rows * widget.cellSize),
                        painter: BoardPainter(
                          gameState: widget.gameState,
                          cellSize: widget.cellSize,
                          hoverRow: hoverRow,
                          hoverCol: hoverCol,
                          hoverShape: hoverBlockIndex == null ? null : (hoverBlockIndex == -1 ? widget.gameState.holdBlock : widget.gameState.availableBlocks[hoverBlockIndex!]),
                          isDarkMode: AppTheme.isDarkMode.value,
                          clearAnimValue: _clearAnimController.value,
                          placeAnimValue: _placeAnimController.value,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class BoardPainter extends CustomPainter {
  final GameState gameState;
  final double cellSize;
  final int? hoverRow;
  final int? hoverCol;
  final BlockShape? hoverShape;
  final bool isDarkMode;
  final double clearAnimValue;
  final double placeAnimValue;

  BoardPainter({
    required this.gameState,
    required this.cellSize,
    this.hoverRow,
    this.hoverCol,
    this.hoverShape,
    required this.isDarkMode,
    required this.clearAnimValue,
    required this.placeAnimValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int r = 0; r < GameState.rows; r++) {
      for (int c = 0; c < GameState.cols; c++) {
        Color? cellColor = gameState.board[r][c];
        Rect rect = Rect.fromLTWH(c * cellSize, r * cellSize, cellSize, cellSize);
        
        paint.color = AppTheme.socketBg;
        canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(1.5), const Radius.circular(6)), paint);
        canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(1.5), const Radius.circular(6)), borderPaint);

        if (cellColor != null) {
          paint.color = cellColor;
          bool isPlaced = gameState.lastPlacedCells.contains(Point(r, c));
          if (isPlaced && placeAnimValue < 1.0) {
             canvas.save();
             canvas.translate(rect.center.dx, rect.center.dy);
             canvas.scale(0.3 + 0.7 * Curves.elasticOut.transform(placeAnimValue));
             canvas.translate(-rect.center.dx, -rect.center.dy);
          }
          
          canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(2.0), const Radius.circular(6)), paint);
          
          if (isPlaced && placeAnimValue < 1.0) {
             canvas.restore();
          }
        }
      }
    }

    if (hoverRow != null && hoverCol != null && hoverShape != null) {
      paint.color = (isDarkMode ? Colors.white : Colors.black).withOpacity(0.2);
      for (int i = 0; i < hoverShape!.rows; i++) {
        for (int j = 0; j < hoverShape!.cols; j++) {
          if (hoverShape!.matrix[i][j] == 1) {
            int br = hoverRow! + i;
            int bc = hoverCol! + j;
            if (br >= 0 && br < GameState.rows && bc >= 0 && bc < GameState.cols) {
              Rect ghostRect = Rect.fromLTWH(bc * cellSize, br * cellSize, cellSize, cellSize);
              canvas.drawRRect(RRect.fromRectAndRadius(ghostRect.deflate(2.0), const Radius.circular(6)), paint);
            }
          }
        }
      }
    }

    if (gameState.lastClearedCells.isNotEmpty && clearAnimValue > 0) {
      for (var point in gameState.lastClearedCells) {
        int r = point.x.toInt();
        int c = point.y.toInt();
        Rect baseRect = Rect.fromLTWH(c * cellSize, r * cellSize, cellSize, cellSize);
        
        double scale = 1.0;
        double opacity = 1.0;
        if (clearAnimValue < 0.33) {
          double t = clearAnimValue / 0.33;
          scale = 1.0 + 0.3 * Curves.easeOut.transform(t);
        } else if (clearAnimValue < 0.66) {
          double t = (clearAnimValue - 0.33) / 0.33;
          scale = 1.3 - 0.5 * Curves.easeInOut.transform(t);
        } else {
          double t = (clearAnimValue - 0.66) / 0.34;
          scale = 0.8;
          opacity = 1.0 - Curves.easeOut.transform(t);
        }

        canvas.save();
        canvas.translate(baseRect.center.dx, baseRect.center.dy);
        canvas.scale(scale);
        canvas.translate(-baseRect.center.dx, -baseRect.center.dy);
        
        Paint clearPaint = Paint()..color = Colors.white.withValues(alpha: opacity);
        canvas.drawRRect(RRect.fromRectAndRadius(baseRect.deflate(1.5), const Radius.circular(6)), clearPaint);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) {
    return true; 
  }
}
