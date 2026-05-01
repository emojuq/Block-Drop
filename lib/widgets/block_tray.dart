import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import 'block_piece.dart';

class BlockTray extends StatelessWidget {
  final GameState gameState;
  final double boardCellSize;

  const BlockTray({
    super.key,
    required this.gameState,
    required this.boardCellSize,
  });

  @override
  Widget build(BuildContext context) {
    double trayCellSize = boardCellSize * 0.75;

    return RepaintBoundary(
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              border: const Border(top: BorderSide(color: Colors.white, width: 1.0)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
            child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(3, (index) {
          final shape = gameState.availableBlocks[index];
          if (shape == null) {
            return SizedBox(width: trayCellSize * 4, height: trayCellSize * 4);
          }

          bool isPlaceable = gameState.canPlaceAnywhere(shape);

          Widget idlePiece = BlockPiece(shape: shape, cellSize: trayCellSize);
          Widget feedbackPiece = BlockPiece(shape: shape, cellSize: boardCellSize);

          if (!isPlaceable) {
            idlePiece = ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                0.33, 0.33, 0.33, 0, 0,
                0.33, 0.33, 0.33, 0, 0,
                0.33, 0.33, 0.33, 0, 0,
                0,    0,    0,    1, 0,
              ]),
              child: Opacity(
                opacity: 0.5, // Ghostly disabled look
                child: idlePiece,
              ),
            );
          }

          return SizedBox(
            width: trayCellSize * 4,
            height: trayCellSize * 4,
            child: Center(
              child: Draggable<int>(
                data: index,
                feedback: Material(
                  color: Colors.transparent,
                  child: Opacity(
                    opacity: 0.85,
                    child: feedbackPiece,
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: idlePiece,
                ),
                dragAnchorStrategy: (draggable, context, position) {
                  final RenderBox renderObject = context.findRenderObject()! as RenderBox;
                  return renderObject.globalToLocal(position);
                },
                child: idlePiece,
              ),
            ),
          );
        }),
            ),
          ),
        ),
      ),
    );
  }
}
