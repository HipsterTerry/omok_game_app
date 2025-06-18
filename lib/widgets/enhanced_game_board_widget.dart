import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/enhanced_game_state.dart';
import '../models/player_profile.dart';
import '../models/game_state.dart';
import '../models/character.dart';
import '../logic/advanced_renju_rule_evaluator.dart';
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
  final ScrollController _scrollController =
      ScrollController();
  late TransformationController
  _transformationController;

  @override
  void initState() {
    super.initState();
    _transformationController =
        TransformationController();

    // 초기 위치를 중앙화점 기준으로 설정
    WidgetsBinding.instance.addPostFrameCallback((
      _,
    ) {
      _centerOnBoard();
    });
  }

  void _centerOnBoard() {
    // 화면 크기 확인
    final screenSize = MediaQuery.of(
      context,
    ).size;

    // 2.5D 효과를 고려한 바둑판 크기 계산
    final baseSize =
        screenSize.width < screenSize.height
        ? screenSize.width - 20
        : screenSize.height - 100;
    final boardSize =
        (widget.boardSize ?? baseSize) * 1.5;

    // 🎯 중앙화점 위치 계산 (15x15 바둑판의 중앙은 (7,7) - 0-based index)
    final centerRow =
        (widget.gameState.boardSize - 1) /
        2; // 7.0
    final centerCol =
        (widget.gameState.boardSize - 1) /
        2; // 7.0
    final cellSize =
        boardSize /
        (widget.gameState.boardSize + 1);

    // 중앙화점의 실제 픽셀 위치 (1-based로 변환)
    final centerX =
        cellSize * (centerCol + 1); // 8번째 셀
    final centerY =
        cellSize * (centerRow + 1); // 8번째 셀

    // 화면 중앙 좌표 (왼쪽으로 더 이동)
    final screenCenterX =
        screenSize.width *
        0.4; // 40% 지점으로 이동 (왼쪽으로)
    final screenCenterY =
        (screenSize.height * 0.7) /
        2; // 컨테이너 높이의 중앙

    // 중앙화점을 화면 중앙으로 이동시키는 변환 계산
    final translateX = screenCenterX - centerX;
    final translateY = screenCenterY - centerY;

    // 변환 행렬 설정 (중앙화점이 화면의 40% 지점에 위치)
    final matrix = Matrix4.identity()
      ..translate(translateX, translateY);

    _transformationController.value = matrix;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 화면 크기 확인
    final screenSize = MediaQuery.of(
      context,
    ).size;

    // 2.5D 효과를 고려한 더 큰 바둑판 크기 설정
    final baseSize =
        screenSize.width < screenSize.height
        ? screenSize.width -
              20 // 세로 모드: 최소 여백
        : screenSize.height -
              100; // 가로 모드: UI 공간 확보

    // 2.5D 변형으로 인한 크기 증가 고려 (약 1.5배)
    final boardSize =
        (widget.boardSize ?? baseSize) * 1.5;

    // 스크롤 가능한 컨테이너로 감싸기
    return Container(
      width: screenSize.width,
      height:
          screenSize.height *
          0.7, // 화면의 70% 높이 사용
      child: InteractiveViewer(
        constrained: false,
        boundaryMargin: const EdgeInsets.all(20),
        minScale: 0.5,
        maxScale: 2.0,
        transformationController:
            _transformationController,
        child: Container(
          // 스크롤 영역을 바둑판보다 크게 설정
          width: boardSize + 100,
          height: boardSize + 100,
          alignment: Alignment.center,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                12,
              ),
              boxShadow: [
                // 강화된 그림자 효과 (바둑판이 더 누운 시점에 맞춘 강한 입체감)
                BoxShadow(
                  color: Colors.black.withOpacity(
                    0.4,
                  ),
                  offset: const Offset(
                    0,
                    -15,
                  ), // 그림자가 더 멀리 뒤쪽으로 떨어짐
                  blurRadius: 25,
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(
                    0.2,
                  ),
                  offset: const Offset(
                    0,
                    -8,
                  ), // 보조 그림자도 더 강하게
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Transform(
              // 🎯 2.5D 효과: 위에서 아래로 내려다보는 시점
              transform: Matrix4.identity()
                ..setEntry(
                  3,
                  2,
                  0.003,
                ) // 원근감 대폭 강화
                ..rotateX(
                  -0.5,
                ), // X축 기준 회전 (더 세워서 전체 보이도록)
              alignment: Alignment.center,
              child: Container(
                width: boardSize,
                height: boardSize,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(16),
                  // 🎨 체스판 스타일 나무 배경색
                  color: const Color(0xFFF7ECE1),
                  // 🎯 입체적인 깊이 효과
                  boxShadow: [
                    // 주 그림자 - 깊이감
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.25),
                      offset: const Offset(0, 8),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                    // 접촉 그림자 - 바닥과의 접촉감
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.15),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                    // 상단 하이라이트 - 입체감
                    BoxShadow(
                      color: Colors.white
                          .withOpacity(0.3),
                      offset: const Offset(0, -2),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                  // 🎨 나무 질감을 위한 미세한 테두리
                  border: Border.all(
                    color: const Color(
                      0xFFE8D5B7,
                    ),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // 🎯 바둑판 배경 이미지 (CustomPaint 대체)
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/board/board_17x17.png',
                          fit: BoxFit.cover,
                        ),
                      ),

                      // 🎮 터치 감지 레이어 (투명한 오버레이)
                      MouseRegion(
                        onHover: (event) =>
                            _handleHover(
                              event,
                              boardSize,
                            ),
                        onExit: (_) => setState(
                          () => _hoverPosition =
                              null,
                        ),
                        child: GestureDetector(
                          onTapDown: (details) =>
                              _handleTapDown(
                                details,
                                boardSize,
                              ),
                          onTapUp: (_) =>
                              setState(
                                () => _isPressed =
                                    false,
                              ),
                          onTapCancel: () =>
                              setState(
                                () => _isPressed =
                                    false,
                              ),
                          // 모바일 터치 개선: 더 정확한 터치 감지
                          behavior:
                              HitTestBehavior
                                  .opaque,
                          child: Container(
                            width: boardSize,
                            height: boardSize,
                            color: Colors
                                .transparent, // 투명한 터치 감지 영역
                          ),
                        ),
                      ),

                      // 🎯 오목돌 이미지 레이어 - 돌이 놓인 위치에만 표시
                      ..._buildStoneImages(
                        boardSize,
                      ),

                      // 🚫 렌주룰 금지수 오버레이 - 바둑판과 동일한 Transform 적용
                      ..._buildForbiddenMoveOverlay(
                        boardSize,
                      ),
                    ],
                  ),
                ),
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
    // 햅틱 피드백 추가 (모바일 환경)
    HapticFeedback.lightImpact();

    setState(() => _isPressed = true);
    final position = _getGridPosition(
      details.localPosition,
      size,
    );
    if (position != null &&
        _isValidPosition(position)) {
      // 자동 스크롤: 돌을 놓은 위치가 화면 중앙에 오도록 조정
      _autoScrollToPosition(position, size);

      widget.onTileTap(
        position.row,
        position.col,
      );
    }
  }

  // 자동 스크롤 기능: 돌을 놓은 위치로 부드럽게 이동
  void _autoScrollToPosition(
    Position position,
    double boardSize,
  ) {
    // InteractiveViewer는 자동 스크롤을 지원하지 않으므로
    // 사용자가 수동으로 드래그/줌해서 확인할 수 있도록 함
    // 추후 필요시 TransformationController를 사용하여 구현 가능
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

  List<Widget> _buildStoneImages(
    double boardSize,
  ) {
    final List<Widget> stoneWidgets = [];
    final cellSize =
        boardSize /
        (widget.gameState.boardSize + 1);

    // 바둑판의 모든 위치를 확인하여 돌이 놓인 곳에 PNG 이미지 배치
    for (
      int row = 0;
      row < widget.gameState.boardSize;
      row++
    ) {
      for (
        int col = 0;
        col < widget.gameState.boardSize;
        col++
      ) {
        final stone =
            widget.gameState.board[row][col];

        // 🎯 돌이 놓인 위치에만 PNG 이미지 표시
        if (stone != null) {
          // 격자점의 실제 픽셀 위치 계산
          final x = cellSize * (col + 1);
          final y = cellSize * (row + 1);

          // 🎨 감성적인 3D 오목돌 fallback (PNG 이미지 없을 때)
          stoneWidgets.add(
            Positioned(
              left:
                  x -
                  (cellSize * 2.4 / 2), // 중앙 정렬
              top:
                  y -
                  (cellSize * 2.4 / 2), // 중앙 정렬
              child: Image.asset(
                stone == PlayerType.black
                    ? 'assets/image/black_stone.png'
                    : 'assets/image/white_stone.png',
                width: cellSize * 2.4,
                height: cellSize * 2.4,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // 🎨 감성적인 3D 오목돌 fallback (PNG 이미지 없을 때)
                  return Container(
                    width: cellSize * 2.4,
                    height: cellSize * 2.4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient:
                          stone ==
                              PlayerType.black
                          ? RadialGradient(
                              center:
                                  const Alignment(
                                    -0.3,
                                    -0.3,
                                  ),
                              radius: 0.8,
                              colors: [
                                Colors.grey[400]!,
                                Colors.grey[700]!,
                                Colors.grey[900]!,
                                Colors.black,
                              ],
                              stops: const [
                                0.0,
                                0.3,
                                0.7,
                                1.0,
                              ],
                            )
                          : RadialGradient(
                              center:
                                  const Alignment(
                                    -0.3,
                                    -0.3,
                                  ),
                              radius: 0.8,
                              colors: [
                                Colors.white,
                                const Color(
                                  0xFFF8F8F8,
                                ),
                                const Color(
                                  0xFFE8E8E8,
                                ),
                                const Color(
                                  0xFFD0D0D0,
                                ),
                              ],
                              stops: const [
                                0.0,
                                0.3,
                                0.7,
                                1.0,
                              ],
                            ),
                      boxShadow: [
                        // 주 그림자
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(0.3),
                          offset: const Offset(
                            3,
                            4,
                          ),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                        // 접촉 그림자
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(0.1),
                          offset: const Offset(
                            1,
                            2,
                          ),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // 하이라이트 효과
                        gradient: RadialGradient(
                          center: const Alignment(
                            -0.4,
                            -0.4,
                          ),
                          radius: 0.3,
                          colors: [
                            stone ==
                                    PlayerType
                                        .black
                                ? Colors
                                      .grey[300]!
                                      .withOpacity(
                                        0.4,
                                      )
                                : Colors.white
                                      .withOpacity(
                                        0.8,
                                      ),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 1.0],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }
      }
    }

    return stoneWidgets;
  }

  // 🚫 렌주룰 금지수 오버레이 빌드 - 바둑판과 완전 동일한 위치
  List<Widget> _buildForbiddenMoveOverlay(
    double boardSize,
  ) {
    final List<Widget> forbiddenWidgets = [];

    // 흑돌이 아니면 렌주룰 적용 안함
    if (widget.gameState.currentPlayer !=
        PlayerType.black) {
      return forbiddenWidgets;
    }

    final cellSize =
        boardSize /
        (widget.gameState.boardSize + 1);

    // 금지 위치 계산
    final forbiddenPositions =
        AdvancedRenjuRuleEvaluator.getForbiddenPositions(
          widget.gameState.board,
          widget.gameState.currentPlayer,
          null, // aiDifficulty - wrapper에서 처리하므로 null
        );

    // 디버깅: 금지 위치가 있을 때만 로그 출력
    if (forbiddenPositions.isNotEmpty) {
      print(
        '🚫 렌주룰 금지수 발견! 개수: ${forbiddenPositions.length}',
      );
      for (final pos in forbiddenPositions) {
        print(
          '🚫 금지 위치: (${pos.row}, ${pos.col})',
        );
      }
    }

    // 각 금지 위치에 X 마크 표시
    for (final position in forbiddenPositions) {
      // 해당 위치에 이미 돌이 있는지 확인
      final hasStone =
          widget.gameState.board[position
              .row][position.col] !=
          null;

      // 격자점의 실제 픽셀 위치 계산 (오목돌과 정확히 동일한 방식)
      final x = cellSize * (position.col + 1);
      final y = cellSize * (position.row + 1);

      // 🎯 돌이 있으면 작고 투명하게, 없으면 명확하게 표시
      final markerSize = hasStone
          ? cellSize * 0.6
          : cellSize * 0.75; // 오목돌보다 약간 작게
      final opacity = hasStone
          ? 0.4
          : 0.8; // 돌이 있으면 더 투명하게

      forbiddenWidgets.add(
        Positioned(
          // 🎯 격자줄 중심에 완벽하게 맞춤 - 픽셀 단위로 정확하게
          left: (x - (markerSize / 2))
              .roundToDouble(),
          top: (y - (markerSize / 2))
              .roundToDouble(),
          child: IgnorePointer(
            // 터치 이벤트 무시
            child: Opacity(
              opacity: opacity,
              child: Image.asset(
                'assets/images/forbidden_move_marker.png',
                width: markerSize,
                height: markerSize,
                fit: BoxFit.contain,
                errorBuilder:
                    (context, error, stackTrace) {
                      // PNG 파일이 없을 경우 CustomPainter로 fallback
                      return CustomPaint(
                        size: Size(
                          markerSize,
                          markerSize,
                        ),
                        painter:
                            ForbiddenMovePainter(
                              opacity: opacity,
                              size: markerSize,
                            ),
                      );
                    },
              ),
            ),
          ),
        ),
      );
    }

    return forbiddenWidgets;
  }
}

/// 🚫 렌주룰 금지수 X 표시를 그리는 CustomPainter
/// 격자점에 자연스럽게 안착된 느낌을 위해 직접 그리기
class ForbiddenMovePainter extends CustomPainter {
  final double opacity;
  final double size;

  const ForbiddenMovePainter({
    this.opacity = 0.8,
    this.size = 36.0,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );
    final radius = size.width * 0.4; // 크기 조정

    // 🎯 바둑돌과 유사한 원형 베이스 그리기
    final basePaint = Paint()
      ..color = Colors.white.withOpacity(
        0.95 * opacity,
      )
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        2,
      );

    // 그림자 원
    canvas.drawCircle(
      center + const Offset(1.5, 2),
      radius,
      shadowPaint,
    );

    // 메인 원형 베이스
    canvas.drawCircle(center, radius, basePaint);

    // 테두리
    final borderPaint = Paint()
      ..color = Colors.red.withOpacity(
        0.7 * opacity,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(
      center,
      radius,
      borderPaint,
    );

    // 🚫 X 표시 그리기 (더 굵고 명확하게)
    final xPaint = Paint()
      ..color = Colors.red.shade800.withOpacity(
        opacity,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final xSize = radius * 0.6; // X 크기

    // X의 첫 번째 선 (\)
    canvas.drawLine(
      center - Offset(xSize, xSize),
      center + Offset(xSize, xSize),
      xPaint,
    );

    // X의 두 번째 선 (/)
    canvas.drawLine(
      center - Offset(xSize, -xSize),
      center + Offset(xSize, -xSize),
      xPaint,
    );

    // 🌟 미세한 하이라이트 효과 (격자점에 안착된 느낌)
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      center - const Offset(3, 3), // 좌상단 하이라이트
      radius * 0.3,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) => false;
}
