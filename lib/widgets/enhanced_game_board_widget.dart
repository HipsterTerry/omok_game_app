import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/enhanced_game_state.dart';
import '../models/player_profile.dart';
import '../models/game_state.dart';
import 'enhanced_omok_board_painter.dart';

class EnhancedGameBoardWidget
    extends StatefulWidget {
  final EnhancedGameState gameState;
  final Function(int row, int col) onTileTap;
  final double? boardSize;
  final bool showCoordinates;
  final BoardSize boardSizeType;

  const EnhancedGameBoardWidget({
    super.key,
    required this.gameState,
    required this.onTileTap,
    required this.boardSizeType,
    this.boardSize,
    this.showCoordinates = false,
  });

  @override
  State<EnhancedGameBoardWidget> createState() =>
      _EnhancedGameBoardWidgetState();
}

class _EnhancedGameBoardWidgetState
    extends State<EnhancedGameBoardWidget> {
  Position? _hoverPosition;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final size =
        widget.boardSize ??
        MediaQuery.of(context).size.width *
            0.95; // 크기 확대

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: MouseRegion(
          onHover: (event) =>
              _handleHover(event, size),
          onExit: (_) => setState(
            () => _hoverPosition = null,
          ),
          child: GestureDetector(
            onTapDown: (details) =>
                _handleTapDown(details, size),
            onTapUp: (_) => setState(
              () => _isPressed = false,
            ),
            onTapCancel: () => setState(
              () => _isPressed = false,
            ),
            child: CustomPaint(
              size: Size(size, size),
              painter: EnhancedOmokBoardPainter(
                gameState: widget.gameState,
                boardSizeType:
                    widget.boardSizeType,
                showCoordinates:
                    widget.showCoordinates,
                hoverPosition: _hoverPosition,
                isPressed: _isPressed,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleHover(
    PointerHoverEvent event,
    double size,
  ) {
    final position = _getGridPosition(
      event.localPosition,
      size,
    );
    if (position != null &&
        _isValidPosition(position)) {
      setState(() {
        _hoverPosition = position;
      });
    } else {
      setState(() {
        _hoverPosition = null;
      });
    }
  }

  void _handleTapDown(
    TapDownDetails details,
    double size,
  ) {
    setState(() => _isPressed = true);
    final position = _getGridPosition(
      details.localPosition,
      size,
    );
    if (position != null &&
        _isValidPosition(position)) {
      widget.onTileTap(
        position.row,
        position.col,
      );
    }
  }

  Position? _getGridPosition(
    Offset localPosition,
    double size,
  ) {
    final boardSize = widget.gameState.boardSize;
    final cellSize = size / (boardSize + 1);

    final col =
        ((localPosition.dx / cellSize) - 1)
            .round();
    final row =
        ((localPosition.dy / cellSize) - 1)
            .round();

    if (row >= 0 &&
        row < boardSize &&
        col >= 0 &&
        col < boardSize) {
      return Position(row, col);
    }
    return null;
  }

  bool _isValidPosition(Position position) {
    return widget.gameState.board[position
            .row][position.col] ==
        null;
  }
}
