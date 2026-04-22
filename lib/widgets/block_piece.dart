import 'package:flutter/material.dart';
import '../models/block_shape.dart';
import 'block_cell.dart';

class BlockPiece extends StatelessWidget {
  final BlockShape shape;
  final double cellSize;
  final bool isGhost;

  const BlockPiece({
    super.key,
    required this.shape,
    required this.cellSize,
    this.isGhost = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(shape.rows, (r) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(shape.cols, (c) {
            bool isFilled = shape.matrix[r][c] == 1;

            if (!isFilled) {
              return SizedBox(width: cellSize, height: cellSize);
            }

            return BlockCell(
              color: shape.color,
              size: cellSize,
              isGhost: isGhost,
            );
          }),
        );
      }),
    );
  }
}
