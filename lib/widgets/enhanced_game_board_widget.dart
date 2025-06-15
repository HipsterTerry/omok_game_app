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
    // 모바일 환경에 최적화된 보드 크기 설정
    final screenSize = MediaQuery.of(
      context,
    ).size;
    final availableSize =
        screenSize.width < screenSize.height
        ? screenSize.width -
              40 // 세로 모드: 좌우 여백 40px
        : screenSize.height -
              200; // 가로 모드: 상하 UI 공간 확보

    final size =
        widget.boardSize ?? availableSize;

    // 2.5D 스타일을 위한 그림자와 Transform 적용
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          // 강화된 그림자 효과 (내 쪽에서 상대방을 바라보는 시점에 맞춘 그림자)
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(
              0,
              -8,
            ), // 그림자가 뒤쪽(위쪽)으로 떨어짐
            blurRadius: 16,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(
              0,
              -4,
            ), // 보조 그림자도 위쪽으로
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Transform(
        // 2.5D 시점 적용: 내 쪽에서 상대방을 바라보는 형태 (가까운 쪽이 크고 먼 쪽이 작게)
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // 원근감
          ..rotateX(
            -0.3,
          ), // X축 기준 기울기 (음수로 변경하여 시점 반전)
        alignment: Alignment.center,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              12,
            ),
            // 바둑판 자체의 색상과 질감
            color: Colors.brown[100],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              12,
            ),
            child: Stack(
              children: [
                // 기존 바둑판 레이어
                MouseRegion(
                  onHover: (event) =>
                      _handleHover(event, size),
                  onExit: (_) => setState(
                    () => _hoverPosition = null,
                  ),
                  child: GestureDetector(
                    onTapDown: (details) =>
                        _handleTapDown(
                          details,
                          size,
                        ),
                    onTapUp: (_) => setState(
                      () => _isPressed = false,
                    ),
                    onTapCancel: () => setState(
                      () => _isPressed = false,
                    ),
                    // 모바일 터치 개선: 더 정확한 터치 감지
                    behavior:
                        HitTestBehavior.opaque,
                    child: CustomPaint(
                      size: Size(size, size),
                      painter:
                          EnhancedOmokBoardPainter(
                            gameState:
                                widget.gameState,
                            boardSizeType: widget
                                .boardSizeType,
                            showCoordinates: widget
                                .showCoordinates,
                            hoverPosition:
                                _hoverPosition,
                            isPressed: _isPressed,
                          ),
                    ),
                  ),
                ),
                // 추후 캐릭터 이미지 레이어가 여기에 추가될 예정
                // Positioned 위젯들로 각 돌 위치에 캐릭터 PNG 배치 가능
              ],
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
    // 햅틱 피드백 추가 (모바일 환경)
    HapticFeedback.lightImpact();

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

    // 모바일 터치 정밀도 개선: 허용 오차 확대
    final touchTolerance =
        cellSize * 0.45; // 45% 허용 오차

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
      // 실제 터치 위치와 격자점의 거리 계산
      final actualX = (col + 1) * cellSize;
      final actualY = (row + 1) * cellSize;
      final distance =
          (localPosition -
                  Offset(actualX, actualY))
              .distance;

      // 허용 오차 범위 내에서만 유효한 위치로 인정
      if (distance <= touchTolerance) {
        return Position(row, col);
      }
    }
    return null;
  }

  bool _isValidPosition(Position position) {
    return widget.gameState.board[position
            .row][position.col] ==
        null;
  }
}
