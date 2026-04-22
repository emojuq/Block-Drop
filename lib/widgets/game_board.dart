import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/block_shape.dart';
import '../theme/app_theme.dart';
import 'block_cell.dart';

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

class _GameBoardState extends State<GameBoard> {
  int? hoverRow;
  int? hoverCol;
  int? hoverBlockIndex;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(GameState.rows, (r) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(GameState.cols, (c) {
                  return DragTarget<int>(
                    onWillAcceptWithDetails: (details) {
                      int blockIndex = details.data;
                      BlockShape? shape = blockIndex == -1 ? widget.gameState.holdBlock : widget.gameState.availableBlocks[blockIndex];
                      
                      if (shape == null || !widget.gameState.canPlace(shape, r, c)) {
                        return false; 
                      }
                      
                      setState(() {
                        hoverRow = r;
                        hoverCol = c;
                        hoverBlockIndex = blockIndex;
                      });
                      return true;
                    },
                    onAcceptWithDetails: (details) {
                      setState(() {
                        hoverRow = null;
                        hoverCol = null;
                        hoverBlockIndex = null;
                      });
                      widget.onBlockPlaced(details.data, r, c);
                    },
                    onLeave: (data) {
                      setState(() {
                        hoverRow = null;
                        hoverCol = null;
                        hoverBlockIndex = null;
                      });
                    },
                    builder: (context, candidateData, rejectedData) {
                      Color? cellColor = widget.gameState.board[r][c];
                      bool isCleared = widget.gameState.lastClearedCells.contains(Point(r, c));
                      bool renderGhost = false;

                      if (hoverRow != null && hoverCol != null && hoverBlockIndex != null) {
                        BlockShape? hoverShape = hoverBlockIndex == -1 ? widget.gameState.holdBlock : widget.gameState.availableBlocks[hoverBlockIndex!];
                        if (hoverShape != null) {
                          int rOffset = r - hoverRow!;
                          int cOffset = c - hoverCol!;
                          
                          if (rOffset >= 0 && rOffset < hoverShape.rows &&
                              cOffset >= 0 && cOffset < hoverShape.cols) {
                            if (hoverShape.matrix[rOffset][cOffset] == 1) {
                              renderGhost = true;
                            }
                          }
                        }
                      }

                      return GestureDetector(
                        onTap: () {
                          if (widget.gameState.isHammerActive && widget.onHammerTapped != null) {
                            widget.onHammerTapped!(r, c);
                          }
                        },
                        child: Stack(
                        children: [
                          Container(
                            width: widget.cellSize,
                            height: widget.cellSize,
                            padding: const EdgeInsets.all(1.5),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.socketBg,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.black.withAlpha(150), width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.borderHighlight,
                                    offset: const Offset(0, 1),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (cellColor != null)
                             BlockCell(color: cellColor, size: widget.cellSize),
                          if (renderGhost)
                             BlockCell(color: AppTheme.isDarkMode.value ? Colors.white54 : Colors.black45, size: widget.cellSize, isGhost: true),
                             
                          if (isCleared)
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 1.0, end: 0.0),
                              duration: const Duration(milliseconds: 500),
                              key: ValueKey('clear_${r}_$c'),
                              builder: (context, opacity, child) {
                                double scale = 1.0 + (1.0 - opacity) * 0.6; // Scale up to 1.6
                                return Transform.scale(
                                  scale: scale,
                                  child: Opacity(
                                    opacity: opacity,
                                    child: Container(
                                      width: widget.cellSize,
                                      height: widget.cellSize,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.cyanAccent.withAlpha((255 * opacity).toInt()),
                                            blurRadius: 25 * opacity,
                                            spreadRadius: 10 * opacity,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    );
                  },
                  );
                }),
              );
            }),
          ),
        );
      },
    );
  }
}
