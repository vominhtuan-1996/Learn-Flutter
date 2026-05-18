import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../rubik_game.dart';
import 'tile_component.dart';

/// Component trung tâm quản lý lưới 3x3 các ô màu Rubik với hiệu ứng 3D.
class RubikGridComponent extends PositionComponent
    with DragCallbacks, HasGameRef<RubikGame> {
  final List<RubikTileComponent> tiles = [];
  Vector2? _dragStart;
  Vector2? _dragEnd;
  bool _isAnimating = false;

  RubikGridComponent({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    final tileSize = size.x / 3;
    final gridCenterPos = Vector2(size.x / 2, size.y / 2);

    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        final color = gameRef.logic.getColor(gameRef.logic.board[row][col]);
        final tile = RubikTileComponent(
          tileColor: color,
          rowIndex: row,
          colIndex: col,
          position: Vector2(col * tileSize, row * tileSize),
          size: Vector2.all(tileSize),
        );
        tile.gridCenter = gridCenterPos;
        tiles.add(tile);
        add(tile);
      }
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    if (_isAnimating) return;
    super.onDragStart(event);
    _dragStart = event.localPosition;
    _dragEnd = event.localPosition;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_isAnimating) return;
    super.onDragUpdate(event);
    _dragEnd = event.localEndPosition;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (_isAnimating || _dragStart == null || _dragEnd == null) return;
    super.onDragEnd(event);

    final delta = _dragEnd! - _dragStart!;
    if (delta.length < 20) return;

    final tileSize = size.x / 3;
    final col = (_dragStart!.x / tileSize).floor().clamp(0, 2);
    final row = (_dragStart!.y / tileSize).floor().clamp(0, 2);

    if (delta.x.abs() > delta.y.abs()) {
      _rotateRow(row, delta.x > 0);
    } else {
      _rotateColumn(col, delta.y > 0);
    }
    _dragStart = null;
    _dragEnd = null;
  }

  void _rotateRow(int rowIndex, bool isRight) {
    _isAnimating = true;
    final tileSize = size.x / 3;
    final movingTiles = tiles.where((t) => t.rowIndex == rowIndex).toList();

    int completedCount = 0;
    for (final tile in movingTiles) {
      final newCol = (tile.colIndex + (isRight ? 1 : 2)) % 3;
      var targetX = newCol * tileSize;

      // Wrap-around animation
      if (isRight && tile.colIndex == 2) targetX = 3 * tileSize;
      if (!isRight && tile.colIndex == 0) targetX = -1 * tileSize;

      tile.add(MoveEffect.to(
        Vector2(targetX, tile.y),
        EffectController(duration: 0.4, curve: Curves.easeInOutCubic),
        onComplete: () {
          tile.colIndex = newCol;
          tile.position = Vector2(newCol * tileSize, tile.y);
          if (tile.position.x >= 2.9 * tileSize) {
            tile.position.x = 2 * tileSize;
          }
          if (tile.position.x <= 0.1 * tileSize) {
            tile.position.x = 0;
          }

          completedCount++;
          if (completedCount == movingTiles.length) {
            _onAnimationComplete(
                isRow: true, index: rowIndex, direction: isRight);
          }
        },
      ));
    }
  }

  void _rotateColumn(int colIndex, bool isDown) {
    _isAnimating = true;
    final tileSize = size.x / 3;
    final movingTiles = tiles.where((t) => t.colIndex == colIndex).toList();

    int completedCount = 0;
    for (final tile in movingTiles) {
      final newRow = (tile.rowIndex + (isDown ? 1 : 2)) % 3;
      var targetY = newRow * tileSize;

      if (isDown && tile.rowIndex == 2) targetY = 3 * tileSize;
      if (!isDown && tile.rowIndex == 0) targetY = -1 * tileSize;

      tile.add(MoveEffect.to(
        Vector2(tile.x, targetY),
        EffectController(duration: 0.4, curve: Curves.easeInOutCubic),
        onComplete: () {
          tile.rowIndex = newRow;
          tile.position = Vector2(tile.x, targetY % (3 * tileSize));
          if (tile.position.y < 0) {
            tile.position.y += 3 * tileSize;
          }
          if (tile.position.y >= 2.9 * tileSize) {
            tile.position.y = 0;
          } // Chống trôi số thực

          completedCount++;
          if (completedCount == movingTiles.length) {
            _onAnimationComplete(
                isRow: false, index: colIndex, direction: isDown);
          }
        },
      ));
    }
  }

  void _onAnimationComplete(
      {required bool isRow, required int index, required bool direction}) {
    if (isRow) {
      gameRef.logic.rotateRow(index, direction);
    } else {
      gameRef.logic.rotateColumn(index, direction);
    }

    refresh();
    _isAnimating = false;
    gameRef.checkGameState();
  }

  void refresh() {
    for (final tile in tiles) {
      final color = gameRef.logic
          .getColor(gameRef.logic.board[tile.rowIndex][tile.colIndex]);
      tile.updateColor(color);
    }
  }
}
