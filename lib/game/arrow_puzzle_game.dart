import 'dart:async';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../data/models/level.dart';
import 'components/grid_component.dart';
import 'game_state.dart';

class ArrowPuzzleGame extends FlameGame {
  // ── State ─────────────────────────────────────────────────────────────────────
  final LevelModel level;
  final GameState gameState;
  GridComponent? gridComponent;

  // ── Callbacks to Flutter ──────────────────────────────────────────────────────
  final void Function() onLevelComplete;
  final void Function() onGameOver;
  final void Function() onLifeLost;

  ArrowPuzzleGame({
    required this.level,
    required this.gameState,
    required this.onLevelComplete,
    required this.onGameOver,
    required this.onLifeLost,
  });

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    final (gridSize, gridX, gridY) = _calcLayout(size);

    gridComponent = GridComponent(
      gameState: gameState,
      gridPixelSize: gridSize,
      position: Vector2(gridX, gridY),
    );

    add(gridComponent!);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    final (gridSize, gridX, gridY) = _calcLayout(size);

    if (gridComponent != null) {
      gridComponent!.position = Vector2(gridX, gridY);
      gridComponent!.resize(gridSize);
    }
  }

  (double gridSize, double gridX, double gridY) _calcLayout(Vector2 screenSize) {
    final levelType = AppConstants.levelTypeFor(level.levelNumber);
    // Clamp scale to 1.0: values > 1.0 make gridPixelWidth > screenSize,
    // giving a negative gridX so edge cells fall outside the Flutter SizedBox
    // and their touch events get clipped. canvasScaleForType can still be set
    // > 1.0 for visual zoom by the InteractiveViewer, not the Flame layout.
    final scale = AppConstants.canvasScaleForType(levelType).clamp(0.1, 1.0);

    double activeCols = level.gridSize.toDouble();
    double activeRows = level.gridSize.toDouble();
    int minR = 0;
    int minC = 0;

    if (level.mask.isNotEmpty) {
      int minRFound = 999, maxRFound = -1, minCFound = 999, maxCFound = -1;
      for (final cell in level.mask) {
        final parts = cell.split(',');
        final r = int.parse(parts[0]);
        final c = int.parse(parts[1]);
        if (r < minRFound) minRFound = r;
        if (r > maxRFound) maxRFound = r;
        if (c < minCFound) minCFound = c;
        if (c > maxCFound) maxCFound = c;
      }
      if (minRFound <= maxRFound && minCFound <= maxCFound) {
        activeRows = (maxRFound - minRFound + 1).toDouble();
        activeCols = (maxCFound - minCFound + 1).toDouble();
        minR = minRFound;
        minC = minCFound;
      }
    }

    final maxW = screenSize.x * scale;
    final maxH = screenSize.y * scale;

    final cellW = maxW / activeCols;
    final cellH = maxH / activeRows;
    final cellSize = cellW < cellH ? cellW : cellH;

    final gridPixelWidth  = level.gridSize * cellSize;
    final gridPixelHeight = level.gridSize * cellSize;

    final activePixelWidth  = activeCols * cellSize;
    final activePixelHeight = activeRows * cellSize;

    // Center the active mask bounds on screen, ensuring all active cells
    // have positive coordinates within the Flutter GameWidget viewport.
    final gridX = (screenSize.x - activePixelWidth) / 2 - (minC * cellSize);
    final gridY = (screenSize.y - activePixelHeight) / 2 - (minR * cellSize);

    return (gridPixelWidth, gridX, gridY);
  }

  /// Reset board to initial state (restart level)
  void resetLevel() {
    gameState.resetLevel();
    gridComponent?.rebuild();
  }
}
