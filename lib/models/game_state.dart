import 'dart:math';
import 'package:flutter/material.dart';
import '../services/mission_service.dart';
import 'block_shape.dart';

class GameState extends ChangeNotifier {
  static const int rows = 8;
  static const int cols = 8;

  List<List<Color?>> board = List.generate(rows, (_) => List.filled(cols, null));
  List<BlockShape?> availableBlocks = [null, null, null];
  BlockShape? holdBlock;
  
  GameState? previousState;
  bool isHammerActive = false;

  int shuffleUses = 0;
  int undoUses = 0;
  int hammerUses = 0;

  // Stats
  int blocksPlaced = 0;
  int linesClearedTotal = 0;
  int maxCombo = 0;
  int lastScoreGained = 0;

  int score = 0;
  bool isGameOver = false;
  Set<Point<int>> lastClearedCells = {};
  Set<Point<int>> lastPlacedCells = {};
  int streakCount = 0;

  GameState() {
    _loadNewBlocks();
  }

  void _loadNewBlocks() {
    final random = Random();
    for (int i = 0; i < 3; i++) {
      availableBlocks[i] = Shapes.all[random.nextInt(Shapes.all.length)];
    }
  }

  bool canPlace(BlockShape shape, int boardRow, int boardCol) {
    if (boardRow < 0 || boardCol < 0 || boardRow + shape.rows > rows || boardCol + shape.cols > cols) return false;
    for (int r = 0; r < shape.rows; r++) {
      for (int c = 0; c < shape.cols; c++) {
        if (shape.matrix[r][c] == 1 && board[boardRow + r][boardCol + c] != null) {
          return false;
        }
      }
    }
    return true;
  }

  bool canPlaceAnywhere(BlockShape shape) {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (canPlace(shape, r, c)) {
          return true;
        }
      }
    }
    return false;
  }

  int placeBlock(int trayIndex, int row, int col) {
    if (isHammerActive) return -1;
    BlockShape shape = trayIndex == -1 ? holdBlock! : availableBlocks[trayIndex]!;
    if (!canPlace(shape, row, col)) return -1;

    saveState();

    lastPlacedCells.clear();
    for (int r = 0; r < shape.rows; r++) {
      for (int c = 0; c < shape.cols; c++) {
        if (shape.matrix[r][c] == 1) {
          board[row + r][col + c] = shape.color;
          lastPlacedCells.add(Point(row + r, col + c));
        }
      }
    }
    
    blocksPlaced++;
    MissionService.updateProgress('blocks', 1);

    if (trayIndex == -1) {
      holdBlock = null;
    } else {
      availableBlocks[trayIndex] = null;
    }

    int clearedLines = _clearCompletedLines();

    // Check if tray is empty
    if (availableBlocks.every((b) => b == null)) {
      _loadNewBlocks();
    }

    checkGameOver();
    notifyListeners();
    return clearedLines;
  }

  void swapHoldBlock(int trayIndex) {
    if (isHammerActive) return;
    saveState();
    if (holdBlock == null) {
      holdBlock = availableBlocks[trayIndex];
      availableBlocks[trayIndex] = null;
      if (availableBlocks.every((b) => b == null)) {
        _loadNewBlocks();
      }
    } else {
      BlockShape temp = holdBlock!;
      holdBlock = availableBlocks[trayIndex];
      availableBlocks[trayIndex] = temp;
    }
    checkGameOver();
    notifyListeners();
  }

  int _clearCompletedLines() {
    List<int> fullRows = [];
    List<int> fullCols = [];
    lastClearedCells.clear();

    for (int r = 0; r < rows; r++) {
      bool isFull = true;
      for (int c = 0; c < cols; c++) {
        if (board[r][c] == null) {
          isFull = false;
          break;
        }
      }
      if (isFull) fullRows.add(r);
    }

    for (int c = 0; c < cols; c++) {
      bool isFull = true;
      for (int r = 0; r < rows; r++) {
        if (board[r][c] == null) {
          isFull = false;
          break;
        }
      }
      if (isFull) fullCols.add(c);
    }

    int clearedCount = fullRows.length + fullCols.length;

    for (int r in fullRows) {
      for (int c = 0; c < cols; c++) {
        board[r][c] = null;
        lastClearedCells.add(Point(r, c));
      }
    }

    for (int c in fullCols) {
      for (int r = 0; r < rows; r++) {
        board[r][c] = null;
        lastClearedCells.add(Point(r, c));
      }
    }

    if (clearedCount > 0) {
      streakCount++;
      double baseScore = clearedCount * 80.0;
      double multiplier = 1.0;
      int extraBonus = 0;

      if (clearedCount == 2) {
        multiplier = 1.5;
        extraBonus = 30;
      } else if (clearedCount == 3) {
        multiplier = 2.0;
        extraBonus = 80;
      } else if (clearedCount >= 4) {
        multiplier = 3.0;
        extraBonus = 200;
      }

      double addedScore = (baseScore * multiplier) + extraBonus;

      if (streakCount >= 8) {
        addedScore *= 2.0;
      } else if (streakCount >= 5) {
        addedScore *= 1.5;
      } else if (streakCount >= 3) {
        addedScore *= 1.25;
      }

      lastScoreGained = addedScore.toInt();
      score += lastScoreGained;
      
      linesClearedTotal += clearedCount;
      MissionService.updateProgress('lines', clearedCount);
      
      if (clearedCount >= 2) {
        MissionService.updateProgress('combo', 1);
      }

      if (clearedCount > maxCombo) {
        maxCombo = clearedCount;
      }
    } else {
      streakCount = 0;
      lastScoreGained = 0;
    }

    return clearedCount;
  }

  void checkGameOver() {
    isGameOver = true;
    
    // Check tray blocks
    for (int i = 0; i < 3; i++) {
      final shape = availableBlocks[i];
      if (shape == null) continue;
      if (canPlaceAnywhere(shape)) {
        isGameOver = false;
        return;
      }
    }
    
    // Check hold block
    if (holdBlock != null && canPlaceAnywhere(holdBlock!)) {
        isGameOver = false;
        return;
    }
  }

  void continueGame() {
    isGameOver = false;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        board[r][c] = null;
      }
    }
    holdBlock = null;
    shuffleUses = 0;
    undoUses = 0;
    hammerUses = 0;
    _loadNewBlocks();
    notifyListeners();
  }

  void saveState() {
    previousState = GameState()
      ..board = board.map((row) => List<Color?>.from(row)).toList()
      ..availableBlocks = List<BlockShape?>.from(availableBlocks)
      ..holdBlock = holdBlock
      ..score = score
      ..blocksPlaced = blocksPlaced
      ..linesClearedTotal = linesClearedTotal
      ..maxCombo = maxCombo
      ..streakCount = streakCount;
  }

  bool undoLastMove() {
     if (previousState == null) return false;
     board = previousState!.board.map((row) => List<Color?>.from(row)).toList();
     availableBlocks = List<BlockShape?>.from(previousState!.availableBlocks);
     holdBlock = previousState!.holdBlock;
     score = previousState!.score;
     blocksPlaced = previousState!.blocksPlaced;
     linesClearedTotal = previousState!.linesClearedTotal;
     maxCombo = previousState!.maxCombo;
     streakCount = previousState!.streakCount;
     
     // Only allow 1 undo
     previousState = null;
     isGameOver = false;
     notifyListeners();
     return true;
  }

  void shuffleBlocks() {
     saveState();
     _loadNewBlocks();
     checkGameOver();
     notifyListeners();
  }

  void toggleHammer() {
    isHammerActive = !isHammerActive;
    notifyListeners();
  }

  void clearLastClearedCells() {
    lastClearedCells.clear();
    notifyListeners();
  }

  bool useHammer(int row, int col) {
     if (board[row][col] == null) return false;
     saveState();
     board[row][col] = null;
     isHammerActive = false;
     checkGameOver();
     notifyListeners();
     return true;
  }
}
