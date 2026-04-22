import 'package:flutter/material.dart';

class BlockShape {
  final List<List<int>> matrix;
  final Color color;

  const BlockShape({required this.matrix, required this.color});

  int get rows => matrix.length;
  int get cols => matrix[0].length;
}

class Shapes {
  static const BlockShape single = BlockShape(
    matrix: [[1]],
    color: Color(0xFFFF3B3B), // Vibrant Red
  );

  static const BlockShape h2 = BlockShape(
    matrix: [[1, 1]],
    color: Color(0xFF00D2FE), // Cyan
  );

  static const BlockShape v2 = BlockShape(
    matrix: [
      [1],
      [1]
    ],
    color: Color(0xFF00E676), // Bright Green
  );

  static const BlockShape h3 = BlockShape(
    matrix: [[1, 1, 1]],
    color: Color(0xFFFFD500), // Bright Yellow
  );

  static const BlockShape v3 = BlockShape(
    matrix: [
      [1],
      [1],
      [1]
    ],
    color: Color(0xFFB145FF), // Deep Purple
  );

  static const BlockShape square2x2 = BlockShape(
    matrix: [
      [1, 1],
      [1, 1]
    ],
    color: Color(0xFFFF7B00), // Orange
  );

  static const BlockShape lShape = BlockShape(
    matrix: [
      [1, 0],
      [1, 0],
      [1, 1]
    ],
    color: Color(0xFFFF2C8A), // Hot Pink
  );

  static const BlockShape reverseLShape = BlockShape(
    matrix: [
      [0, 1],
      [0, 1],
      [1, 1]
    ],
    color: Color(0xFF00E5FF), // Aqua
  );

  static const BlockShape tShape = BlockShape(
    matrix: [
      [1, 1, 1],
      [0, 1, 0]
    ],
    color: Color(0xFF1DE9B6), // Teal
  );

  static const BlockShape square3x3 = BlockShape(
    matrix: [
      [1, 1, 1],
      [1, 1, 1],
      [1, 1, 1]
    ],
    color: Color(0xFF536DFE), // Indigo
  );

  static const BlockShape h4 = BlockShape(
    matrix: [[1, 1, 1, 1]],
    color: Color(0xFFFF5252), // Coral Red
  );

  static const BlockShape v4 = BlockShape(
    matrix: [
      [1],
      [1],
      [1],
      [1]
    ],
    color: Color(0xFFE040FB), // Bright Magenta
  );

  static const BlockShape zShape = BlockShape(
    matrix: [
      [1, 1, 0],
      [0, 1, 1]
    ],
    color: Color(0xFF76FF03), // Neon Green
  );

  static const BlockShape sShape = BlockShape(
    matrix: [
      [0, 1, 1],
      [1, 1, 0]
    ],
    color: Color(0xFFFFCA28), // Amber
  );

  static const List<BlockShape> all = [
    single, h2, v2, h3, v3, square2x2, lShape, reverseLShape,
    tShape, square3x3, h4, v4, zShape, sShape
  ];
}
