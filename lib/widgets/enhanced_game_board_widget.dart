import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../models/enhanced_game_state.dart';
import '../models/player_profile.dart';
import '../models/game_state.dart';
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
  Position? _touchPreviewPosition;
  bool _isPressed = false;
  bool _isTouchPreview = false;
  Position? _aimPosition;
  final ScrollController _scrollController =
      ScrollController();
  late TransformationController
  _transformationController;
  Timer? _hoverTimer;

  @override
  void initState() {
    super.initState();
    _transformationController =
        TransformationController();

    WidgetsBinding.instance.addPostFrameCallback((
      _,
    ) {
      _centerOnBoard();
    });
  }

  void _centerOnBoard() {
    final screenSize = MediaQuery.of(
      context,
    ).size;
    final boardSize = widget.boardSize ?? 400.0;

    // 화면 중앙 계산
    final screenCenterX = screenSize.width * 0.5;
    final screenCenterY = screenSize.height * 0.5;

    // 오목판의 중앙점 계산 (보드 크기의 절반)
    final boardCenterX = boardSize * 0.5;
    final boardCenterY = boardSize * 0.5;

    // 오목판을 화면 중앙에 맞추기 위한 이동량 계산
    final translateX =
        screenCenterX - boardCenterX;
    final translateY =
        screenCenterY - boardCenterY;

    // 초기 확대 설정 (1.3배 확대)
    const initialScale = 1.3;
    final matrix = Matrix4.identity()
      ..scale(initialScale)
      ..translate(
        translateX / initialScale,
        translateY / initialScale,
      );
    _transformationController.value = matrix;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _transformationController.dispose();
    _hoverTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boardSize = widget.boardSize ?? 400.0;

    return Container(
      width: boardSize + 100,
      height: boardSize + 100,
      child: InteractiveViewer(
        constrained: false,
        boundaryMargin: const EdgeInsets.all(100),
        minScale: 0.5,
        maxScale: 3.0,
        transformationController:
            _transformationController,
        panEnabled: true,
        scaleEnabled: true,
        child: Container(
          width: boardSize,
          height: boardSize,
          alignment: Alignment.center,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                12,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    0.4,
                  ),
                  offset: const Offset(0, -15),
                  blurRadius: 25,
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(
                    0.2,
                  ),
                  offset: const Offset(0, -8),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Container(
              alignment: Alignment.center,
              child: Container(
                width: boardSize,
                height: boardSize,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(16),
                  color: Colors.transparent,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.15),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // 오목판 배경 이미지
                      Container(
                        width: boardSize,
                        height: boardSize,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              _getBoardImagePath(),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // 터치 감지 영역
                      Positioned.fill(
                        child: MouseRegion(
                          onHover: _onHover,
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
                                  () =>
                                      _isPressed =
                                          false,
                                ),
                            onTapCancel: () =>
                                setState(
                                  () =>
                                      _isPressed =
                                          false,
                                ),
                            onTap: _executeMove,
                            child: Container(
                              color: Colors
                                  .transparent,
                            ),
                          ),
                        ),
                      ),

                      // 오목돌들
                      ..._buildGameStones(
                        boardSize /
                            widget
                                .gameState
                                .boardSize,
                      ),

                      // 금지수 마커들
                      ..._buildForbiddenMoveMarkers(
                        boardSize /
                            widget
                                .gameState
                                .boardSize,
                      ),

                      // 조준점 (FPS 스타일)
                      if (_aimPosition != null)
                        _buildCrosshair(),

                      // 터치 미리보기
                      if (_touchPreviewPosition !=
                              null &&
                          _isTouchPreview)
                        _buildTouchPreview(
                          boardSize /
                              widget
                                  .gameState
                                  .boardSize,
                        ),

                      // 게임 컨트롤 버튼들 제거 (오목판 위에 표시하지 않음)
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

  void _onHover(PointerHoverEvent event) {
    setState(() {
      final position = _getGridPosition(
        event.localPosition,
        widget.boardSize ?? 400.0,
      );
      _hoverPosition = position;
    });
  }

  void _handleTapDown(
    TapDownDetails details,
    double size,
  ) {
    HapticFeedback.lightImpact();
    setState(() => _isPressed = true);

    final position = _getGridPosition(
      details.localPosition,
      size,
    );

    if (position != null &&
        _isValidPosition(position)) {
      setState(() {
        _aimPosition = position;
      });
      _autoScrollToPosition(position, size);
    }
  }

  void _autoScrollToPosition(
    Position position,
    double boardSize,
  ) {
    // InteractiveViewer 자동 스크롤 기능은 추후 구현
  }

  void _executeMove() {
    if (_aimPosition != null) {
      widget.onTileTap(
        _aimPosition!.row,
        _aimPosition!.col,
      );
      setState(() {
        _aimPosition = null;
      });
    }
  }

  Position? _getGridPosition(
    Offset localPosition,
    double size,
  ) {
    final boardSize = widget.gameState.boardSize;
    final gridCoordinates = _getGridCoordinates(
      boardSize,
    );
    final touchTolerance =
        size * 0.10; // 터치 허용 범위를 10%로 확대

    double minDistance = double.infinity;
    Position? closestPosition;

    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        final gridPoint =
            gridCoordinates[row][col];
        final distance =
            (localPosition - gridPoint).distance;

        if (distance < minDistance &&
            distance <= touchTolerance) {
          minDistance = distance;
          closestPosition = Position(row, col);
        }
      }
    }

    return closestPosition;
  }

  bool _isValidPosition(Position position) {
    return widget.gameState.board[position
            .row][position.col] ==
        null;
  }

  String _getBoardImagePath() {
    return 'assets/image/board/board_${widget.gameState.boardSize}x${widget.gameState.boardSize}.png';
  }

  List<Widget> _buildGameStones(double cellSize) {
    final stoneWidgets = <Widget>[];
    final stoneSize =
        cellSize * 0.75; // 오목돌 크기를 75%로 축소

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
        final playerType =
            widget.gameState.board[row][col];
        if (playerType != null) {
          final gridPosition =
              _getExactGridPosition(row, col);

          stoneWidgets.add(
            Positioned(
              left:
                  gridPosition.dx -
                  (stoneSize / 2),
              top:
                  gridPosition.dy -
                  (stoneSize / 2),
              child: Container(
                width: stoneSize,
                height: stoneSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient:
                      playerType ==
                          PlayerType.black
                      ? const RadialGradient(
                          center: Alignment(
                            -0.3,
                            -0.3,
                          ),
                          colors: [
                            Color(0xFF4A4A4A),
                            Color(0xFF1A1A1A),
                            Color(0xFF000000),
                          ],
                        )
                      : const RadialGradient(
                          center: Alignment(
                            -0.3,
                            -0.3,
                          ),
                          colors: [
                            Color(0xFFFFFFFF),
                            Color(0xFFF5F5F5),
                            Color(0xFFE0E0E0),
                          ],
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.3),
                      offset: const Offset(2, 3),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }
    }
    return stoneWidgets;
  }

  List<Widget> _buildForbiddenMoveMarkers(
    double cellSize,
  ) {
    final markers = <Widget>[];

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
        if (widget.gameState.board[row][col] ==
            null) {
          final renjuEvaluator =
              AdvancedRenjuRuleEvaluator();
          final tempBoard = List.generate(
            widget.gameState.boardSize,
            (i) => List<PlayerType?>.from(
              widget.gameState.board[i],
            ),
          );

          tempBoard[row][col] = PlayerType.black;

          if (AdvancedRenjuRuleEvaluator.getForbiddenTypeAt(
                tempBoard,
                row,
                col,
                PlayerType.black,
                null,
              ) !=
              ForbiddenType.none) {
            final gridPosition =
                _getExactGridPosition(row, col);

            markers.add(
              Positioned(
                left: gridPosition.dx - 18,
                top: gridPosition.dy - 18,
                child: CustomPaint(
                  size: const Size(36, 36),
                  painter:
                      const ForbiddenMovePainter(),
                ),
              ),
            );
          }
        }
      }
    }
    return markers;
  }

  Widget _buildCrosshair() {
    if (_aimPosition == null)
      return const SizedBox.shrink();

    final gridPosition = _getExactGridPosition(
      _aimPosition!.row,
      _aimPosition!.col,
    );

    return Positioned(
      left: gridPosition.dx - 25,
      top: gridPosition.dy - 25,
      child: CustomPaint(
        size: const Size(50, 50),
        painter: CrosshairPainter(
          color: Colors.orange.withOpacity(
            0.9,
          ), // 주황색으로 변경하여 더 눈에 띄게
          strokeWidth: 2.5,
        ),
      ),
    );
  }

  Widget _buildTouchPreview(double cellSize) {
    if (_touchPreviewPosition == null)
      return const SizedBox.shrink();

    final gridPosition = _getExactGridPosition(
      _touchPreviewPosition!.row,
      _touchPreviewPosition!.col,
    );
    final stoneSize =
        cellSize * 0.75; // 터치 미리보기도 동일한 크기로

    return Positioned(
      left: gridPosition.dx - (stoneSize / 2),
      top: gridPosition.dy - (stoneSize / 2),
      child: Container(
        width: stoneSize,
        height: stoneSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
              widget.gameState.currentPlayer ==
                  PlayerType.black
              ? Colors.black.withOpacity(0.5)
              : Colors.white.withOpacity(0.7),
          border: Border.all(
            color: Colors.orange.withOpacity(0.9),
            width: 2.5, // 조준점과 동일한 굵기
          ),
        ),
      ),
    );
  }

  Widget _buildGameControlButtons(
    double boardSize,
  ) {
    return Positioned(
      bottom: 20,
      left: 20,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: "undo",
            mini: true,
            onPressed: () {
              // 무르기 기능
            },
            backgroundColor: Colors.blue
                .withOpacity(0.9),
            child: const Icon(
              Icons.undo,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "hint",
            mini: true,
            onPressed: () {
              // 힌트 기능
            },
            backgroundColor: Colors.green
                .withOpacity(0.9),
            child: const Icon(
              Icons.lightbulb,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Offset _getExactGridPosition(int row, int col) {
    final boardSize = widget.gameState.boardSize;
    final gridCoordinates = _getGridCoordinates(
      boardSize,
    );
    return gridCoordinates[row][col];
  }

  List<List<Offset>> _getGridCoordinates(
    int boardSize,
  ) {
    final size = widget.boardSize ?? 400.0;
    const originalSize = 1080.0; // 새로운 1080px 기준
    final scale = size / originalSize;

    if (boardSize == 13) {
      return _get13x13Coordinates(scale);
    } else if (boardSize == 17) {
      return _get17x17Coordinates(scale);
    } else if (boardSize == 21) {
      return _get21x21Coordinates(scale);
    } else {
      // 기본값 (기존 방식 사용)
      final marginPercent = 0.10;
      final gridMargin = size * marginPercent;
      final gridArea = size - (gridMargin * 2);
      final cellSize = gridArea / (boardSize - 1);

      final coordinates = <List<Offset>>[];
      for (int row = 0; row < boardSize; row++) {
        final rowCoords = <Offset>[];
        for (
          int col = 0;
          col < boardSize;
          col++
        ) {
          rowCoords.add(
            Offset(
              gridMargin + (col * cellSize),
              gridMargin + (row * cellSize),
            ),
          );
        }
        coordinates.add(rowCoords);
      }
      return coordinates;
    }
  }

  List<List<Offset>> _get13x13Coordinates(
    double scale,
  ) {
    // 13x13 보드의 정확한 좌표 데이터
    final rawCoordinates = [
      [80.0, 80.0],
      [156.67, 80.0],
      [233.33, 80.0],
      [310.0, 80.0],
      [386.67, 80.0],
      [463.33, 80.0],
      [540.0, 80.0],
      [616.67, 80.0],
      [693.33, 80.0],
      [770.0, 80.0],
      [846.67, 80.0],
      [923.33, 80.0],
      [1000.0, 80.0],
      [80.0, 154.05],
      [156.67, 154.05],
      [233.33, 154.05],
      [310.0, 154.05],
      [386.67, 154.05],
      [463.33, 154.05],
      [540.0, 154.05],
      [616.67, 154.05],
      [693.33, 154.05],
      [770.0, 154.05],
      [846.67, 154.05],
      [923.33, 154.05],
      [1000.0, 154.05],
      [80.0, 228.11],
      [156.67, 228.11],
      [233.33, 228.11],
      [310.0, 228.11],
      [386.67, 228.11],
      [463.33, 228.11],
      [540.0, 228.11],
      [616.67, 228.11],
      [693.33, 228.11],
      [770.0, 228.11],
      [846.67, 228.11],
      [923.33, 228.11],
      [1000.0, 228.11],
      [80.0, 302.16],
      [156.67, 302.16],
      [233.33, 302.16],
      [310.0, 302.16],
      [386.67, 302.16],
      [463.33, 302.16],
      [540.0, 302.16],
      [616.67, 302.16],
      [693.33, 302.16],
      [770.0, 302.16],
      [846.67, 302.16],
      [923.33, 302.16],
      [1000.0, 302.16],
      [80.0, 376.22],
      [156.67, 376.22],
      [233.33, 376.22],
      [310.0, 376.22],
      [386.67, 376.22],
      [463.33, 376.22],
      [540.0, 376.22],
      [616.67, 376.22],
      [693.33, 376.22],
      [770.0, 376.22],
      [846.67, 376.22],
      [923.33, 376.22],
      [1000.0, 376.22],
      [80.0, 450.27],
      [156.67, 450.27],
      [233.33, 450.27],
      [310.0, 450.27],
      [386.67, 450.27],
      [463.33, 450.27],
      [540.0, 450.27],
      [616.67, 450.27],
      [693.33, 450.27],
      [770.0, 450.27],
      [846.67, 450.27],
      [923.33, 450.27],
      [1000.0, 450.27],
      [80.0, 524.33],
      [156.67, 524.33],
      [233.33, 524.33],
      [310.0, 524.33],
      [386.67, 524.33],
      [463.33, 524.33],
      [540.0, 524.33],
      [616.67, 524.33],
      [693.33, 524.33],
      [770.0, 524.33],
      [846.67, 524.33],
      [923.33, 524.33],
      [1000.0, 524.33],
      [80.0, 598.38],
      [156.67, 598.38],
      [233.33, 598.38],
      [310.0, 598.38],
      [386.67, 598.38],
      [463.33, 598.38],
      [540.0, 598.38],
      [616.67, 598.38],
      [693.33, 598.38],
      [770.0, 598.38],
      [846.67, 598.38],
      [923.33, 598.38],
      [1000.0, 598.38],
      [80.0, 672.43],
      [156.67, 672.43],
      [233.33, 672.43],
      [310.0, 672.43],
      [386.67, 672.43],
      [463.33, 672.43],
      [540.0, 672.43],
      [616.67, 672.43],
      [693.33, 672.43],
      [770.0, 672.43],
      [846.67, 672.43],
      [923.33, 672.43],
      [1000.0, 672.43],
      [80.0, 746.49],
      [156.67, 746.49],
      [233.33, 746.49],
      [310.0, 746.49],
      [386.67, 746.49],
      [463.33, 746.49],
      [540.0, 746.49],
      [616.67, 746.49],
      [693.33, 746.49],
      [770.0, 746.49],
      [846.67, 746.49],
      [923.33, 746.49],
      [1000.0, 746.49],
      [80.0, 820.54],
      [156.67, 820.54],
      [233.33, 820.54],
      [310.0, 820.54],
      [386.67, 820.54],
      [463.33, 820.54],
      [540.0, 820.54],
      [616.67, 820.54],
      [693.33, 820.54],
      [770.0, 820.54],
      [846.67, 820.54],
      [923.33, 820.54],
      [1000.0, 820.54],
      [80.0, 894.6],
      [156.67, 894.6],
      [233.33, 894.6],
      [310.0, 894.6],
      [386.67, 894.6],
      [463.33, 894.6],
      [540.0, 894.6],
      [616.67, 894.6],
      [693.33, 894.6],
      [770.0, 894.6],
      [846.67, 894.6],
      [923.33, 894.6],
      [1000.0, 894.6],
      [80.0, 968.65],
      [156.67, 968.65],
      [233.33, 968.65],
      [310.0, 968.65],
      [386.67, 968.65],
      [463.33, 968.65],
      [540.0, 968.65],
      [616.67, 968.65],
      [693.33, 968.65],
      [770.0, 968.65],
      [846.67, 968.65],
      [923.33, 968.65],
      [1000.0, 968.65],
    ];

    final coordinates = <List<Offset>>[];
    int index = 0;

    for (int row = 0; row < 13; row++) {
      final rowCoords = <Offset>[];
      for (int col = 0; col < 13; col++) {
        final x =
            rawCoordinates[index][0] * scale;
        final y =
            rawCoordinates[index][1] * scale;
        rowCoords.add(Offset(x, y));
        index++;
      }
      coordinates.add(rowCoords);
    }

    return coordinates;
  }

  List<List<Offset>> _get17x17Coordinates(
    double scale,
  ) {
    // 17x17 보드의 정확한 좌표 데이터
    final rawCoordinates = [
      [80.0, 80.0],
      [137.5, 80.0],
      [195.0, 80.0],
      [252.5, 80.0],
      [310.0, 80.0],
      [367.5, 80.0],
      [425.0, 80.0],
      [482.5, 80.0],
      [540.0, 80.0],
      [597.5, 80.0],
      [655.0, 80.0],
      [712.5, 80.0],
      [770.0, 80.0],
      [827.5, 80.0],
      [885.0, 80.0],
      [942.5, 80.0],
      [1000.0, 80.0],
      [80.0, 135.54],
      [137.5, 135.54],
      [195.0, 135.54],
      [252.5, 135.54],
      [310.0, 135.54],
      [367.5, 135.54],
      [425.0, 135.54],
      [482.5, 135.54],
      [540.0, 135.54],
      [597.5, 135.54],
      [655.0, 135.54],
      [712.5, 135.54],
      [770.0, 135.54],
      [827.5, 135.54],
      [885.0, 135.54],
      [942.5, 135.54],
      [1000.0, 135.54],
      [80.0, 191.08],
      [137.5, 191.08],
      [195.0, 191.08],
      [252.5, 191.08],
      [310.0, 191.08],
      [367.5, 191.08],
      [425.0, 191.08],
      [482.5, 191.08],
      [540.0, 191.08],
      [597.5, 191.08],
      [655.0, 191.08],
      [712.5, 191.08],
      [770.0, 191.08],
      [827.5, 191.08],
      [885.0, 191.08],
      [942.5, 191.08],
      [1000.0, 191.08],
      [80.0, 246.62],
      [137.5, 246.62],
      [195.0, 246.62],
      [252.5, 246.62],
      [310.0, 246.62],
      [367.5, 246.62],
      [425.0, 246.62],
      [482.5, 246.62],
      [540.0, 246.62],
      [597.5, 246.62],
      [655.0, 246.62],
      [712.5, 246.62],
      [770.0, 246.62],
      [827.5, 246.62],
      [885.0, 246.62],
      [942.5, 246.62],
      [1000.0, 246.62],
      [80.0, 302.16],
      [137.5, 302.16],
      [195.0, 302.16],
      [252.5, 302.16],
      [310.0, 302.16],
      [367.5, 302.16],
      [425.0, 302.16],
      [482.5, 302.16],
      [540.0, 302.16],
      [597.5, 302.16],
      [655.0, 302.16],
      [712.5, 302.16],
      [770.0, 302.16],
      [827.5, 302.16],
      [885.0, 302.16],
      [942.5, 302.16],
      [1000.0, 302.16],
      [80.0, 357.7],
      [137.5, 357.7],
      [195.0, 357.7],
      [252.5, 357.7],
      [310.0, 357.7],
      [367.5, 357.7],
      [425.0, 357.7],
      [482.5, 357.7],
      [540.0, 357.7],
      [597.5, 357.7],
      [655.0, 357.7],
      [712.5, 357.7],
      [770.0, 357.7],
      [827.5, 357.7],
      [885.0, 357.7],
      [942.5, 357.7],
      [1000.0, 357.7],
      [80.0, 413.24],
      [137.5, 413.24],
      [195.0, 413.24],
      [252.5, 413.24],
      [310.0, 413.24],
      [367.5, 413.24],
      [425.0, 413.24],
      [482.5, 413.24],
      [540.0, 413.24],
      [597.5, 413.24],
      [655.0, 413.24],
      [712.5, 413.24],
      [770.0, 413.24],
      [827.5, 413.24],
      [885.0, 413.24],
      [942.5, 413.24],
      [1000.0, 413.24],
      [80.0, 468.79],
      [137.5, 468.79],
      [195.0, 468.79],
      [252.5, 468.79],
      [310.0, 468.79],
      [367.5, 468.79],
      [425.0, 468.79],
      [482.5, 468.79],
      [540.0, 468.79],
      [597.5, 468.79],
      [655.0, 468.79],
      [712.5, 468.79],
      [770.0, 468.79],
      [827.5, 468.79],
      [885.0, 468.79],
      [942.5, 468.79],
      [1000.0, 468.79],
      [80.0, 524.33],
      [137.5, 524.33],
      [195.0, 524.33],
      [252.5, 524.33],
      [310.0, 524.33],
      [367.5, 524.33],
      [425.0, 524.33],
      [482.5, 524.33],
      [540.0, 524.33],
      [597.5, 524.33],
      [655.0, 524.33],
      [712.5, 524.33],
      [770.0, 524.33],
      [827.5, 524.33],
      [885.0, 524.33],
      [942.5, 524.33],
      [1000.0, 524.33],
      [80.0, 579.87],
      [137.5, 579.87],
      [195.0, 579.87],
      [252.5, 579.87],
      [310.0, 579.87],
      [367.5, 579.87],
      [425.0, 579.87],
      [482.5, 579.87],
      [540.0, 579.87],
      [597.5, 579.87],
      [655.0, 579.87],
      [712.5, 579.87],
      [770.0, 579.87],
      [827.5, 579.87],
      [885.0, 579.87],
      [942.5, 579.87],
      [1000.0, 579.87],
      [80.0, 635.41],
      [137.5, 635.41],
      [195.0, 635.41],
      [252.5, 635.41],
      [310.0, 635.41],
      [367.5, 635.41],
      [425.0, 635.41],
      [482.5, 635.41],
      [540.0, 635.41],
      [597.5, 635.41],
      [655.0, 635.41],
      [712.5, 635.41],
      [770.0, 635.41],
      [827.5, 635.41],
      [885.0, 635.41],
      [942.5, 635.41],
      [1000.0, 635.41],
      [80.0, 690.95],
      [137.5, 690.95],
      [195.0, 690.95],
      [252.5, 690.95],
      [310.0, 690.95],
      [367.5, 690.95],
      [425.0, 690.95],
      [482.5, 690.95],
      [540.0, 690.95],
      [597.5, 690.95],
      [655.0, 690.95],
      [712.5, 690.95],
      [770.0, 690.95],
      [827.5, 690.95],
      [885.0, 690.95],
      [942.5, 690.95],
      [1000.0, 690.95],
      [80.0, 746.49],
      [137.5, 746.49],
      [195.0, 746.49],
      [252.5, 746.49],
      [310.0, 746.49],
      [367.5, 746.49],
      [425.0, 746.49],
      [482.5, 746.49],
      [540.0, 746.49],
      [597.5, 746.49],
      [655.0, 746.49],
      [712.5, 746.49],
      [770.0, 746.49],
      [827.5, 746.49],
      [885.0, 746.49],
      [942.5, 746.49],
      [1000.0, 746.49],
      [80.0, 802.03],
      [137.5, 802.03],
      [195.0, 802.03],
      [252.5, 802.03],
      [310.0, 802.03],
      [367.5, 802.03],
      [425.0, 802.03],
      [482.5, 802.03],
      [540.0, 802.03],
      [597.5, 802.03],
      [655.0, 802.03],
      [712.5, 802.03],
      [770.0, 802.03],
      [827.5, 802.03],
      [885.0, 802.03],
      [942.5, 802.03],
      [1000.0, 802.03],
      [80.0, 857.57],
      [137.5, 857.57],
      [195.0, 857.57],
      [252.5, 857.57],
      [310.0, 857.57],
      [367.5, 857.57],
      [425.0, 857.57],
      [482.5, 857.57],
      [540.0, 857.57],
      [597.5, 857.57],
      [655.0, 857.57],
      [712.5, 857.57],
      [770.0, 857.57],
      [827.5, 857.57],
      [885.0, 857.57],
      [942.5, 857.57],
      [1000.0, 857.57],
      [80.0, 913.11],
      [137.5, 913.11],
      [195.0, 913.11],
      [252.5, 913.11],
      [310.0, 913.11],
      [367.5, 913.11],
      [425.0, 913.11],
      [482.5, 913.11],
      [540.0, 913.11],
      [597.5, 913.11],
      [655.0, 913.11],
      [712.5, 913.11],
      [770.0, 913.11],
      [827.5, 913.11],
      [885.0, 913.11],
      [942.5, 913.11],
      [1000.0, 913.11],
      [80.0, 968.65],
      [137.5, 968.65],
      [195.0, 968.65],
      [252.5, 968.65],
      [310.0, 968.65],
      [367.5, 968.65],
      [425.0, 968.65],
      [482.5, 968.65],
      [540.0, 968.65],
      [597.5, 968.65],
      [655.0, 968.65],
      [712.5, 968.65],
      [770.0, 968.65],
      [827.5, 968.65],
      [885.0, 968.65],
      [942.5, 968.65],
      [1000.0, 968.65],
    ];

    final coordinates = <List<Offset>>[];
    int index = 0;

    for (int row = 0; row < 17; row++) {
      final rowCoords = <Offset>[];
      for (int col = 0; col < 17; col++) {
        final x =
            rawCoordinates[index][0] * scale;
        final y =
            rawCoordinates[index][1] * scale;
        rowCoords.add(Offset(x, y));
        index++;
      }
      coordinates.add(rowCoords);
    }

    return coordinates;
  }

  List<List<Offset>> _get21x21Coordinates(
    double scale,
  ) {
    // 21x21 보드의 정확한 좌표 데이터
    final rawCoordinates = [
      [80.0, 80.0],
      [126.0, 80.0],
      [172.0, 80.0],
      [218.0, 80.0],
      [264.0, 80.0],
      [310.0, 80.0],
      [356.0, 80.0],
      [402.0, 80.0],
      [448.0, 80.0],
      [494.0, 80.0],
      [540.0, 80.0],
      [586.0, 80.0],
      [632.0, 80.0],
      [678.0, 80.0],
      [724.0, 80.0],
      [770.0, 80.0],
      [816.0, 80.0],
      [862.0, 80.0],
      [908.0, 80.0],
      [954.0, 80.0],
      [1000.0, 80.0],
      [80.0, 124.43],
      [126.0, 124.43],
      [172.0, 124.43],
      [218.0, 124.43],
      [264.0, 124.43],
      [310.0, 124.43],
      [356.0, 124.43],
      [402.0, 124.43],
      [448.0, 124.43],
      [494.0, 124.43],
      [540.0, 124.43],
      [586.0, 124.43],
      [632.0, 124.43],
      [678.0, 124.43],
      [724.0, 124.43],
      [770.0, 124.43],
      [816.0, 124.43],
      [862.0, 124.43],
      [908.0, 124.43],
      [954.0, 124.43],
      [1000.0, 124.43],
      [80.0, 168.87],
      [126.0, 168.87],
      [172.0, 168.87],
      [218.0, 168.87],
      [264.0, 168.87],
      [310.0, 168.87],
      [356.0, 168.87],
      [402.0, 168.87],
      [448.0, 168.87],
      [494.0, 168.87],
      [540.0, 168.87],
      [586.0, 168.87],
      [632.0, 168.87],
      [678.0, 168.87],
      [724.0, 168.87],
      [770.0, 168.87],
      [816.0, 168.87],
      [862.0, 168.87],
      [908.0, 168.87],
      [954.0, 168.87],
      [1000.0, 168.87],
      [80.0, 213.3],
      [126.0, 213.3],
      [172.0, 213.3],
      [218.0, 213.3],
      [264.0, 213.3],
      [310.0, 213.3],
      [356.0, 213.3],
      [402.0, 213.3],
      [448.0, 213.3],
      [494.0, 213.3],
      [540.0, 213.3],
      [586.0, 213.3],
      [632.0, 213.3],
      [678.0, 213.3],
      [724.0, 213.3],
      [770.0, 213.3],
      [816.0, 213.3],
      [862.0, 213.3],
      [908.0, 213.3],
      [954.0, 213.3],
      [1000.0, 213.3],
      [80.0, 257.73],
      [126.0, 257.73],
      [172.0, 257.73],
      [218.0, 257.73],
      [264.0, 257.73],
      [310.0, 257.73],
      [356.0, 257.73],
      [402.0, 257.73],
      [448.0, 257.73],
      [494.0, 257.73],
      [540.0, 257.73],
      [586.0, 257.73],
      [632.0, 257.73],
      [678.0, 257.73],
      [724.0, 257.73],
      [770.0, 257.73],
      [816.0, 257.73],
      [862.0, 257.73],
      [908.0, 257.73],
      [954.0, 257.73],
      [1000.0, 257.73],
      [80.0, 302.16],
      [126.0, 302.16],
      [172.0, 302.16],
      [218.0, 302.16],
      [264.0, 302.16],
      [310.0, 302.16],
      [356.0, 302.16],
      [402.0, 302.16],
      [448.0, 302.16],
      [494.0, 302.16],
      [540.0, 302.16],
      [586.0, 302.16],
      [632.0, 302.16],
      [678.0, 302.16],
      [724.0, 302.16],
      [770.0, 302.16],
      [816.0, 302.16],
      [862.0, 302.16],
      [908.0, 302.16],
      [954.0, 302.16],
      [1000.0, 302.16],
      [80.0, 346.6],
      [126.0, 346.6],
      [172.0, 346.6],
      [218.0, 346.6],
      [264.0, 346.6],
      [310.0, 346.6],
      [356.0, 346.6],
      [402.0, 346.6],
      [448.0, 346.6],
      [494.0, 346.6],
      [540.0, 346.6],
      [586.0, 346.6],
      [632.0, 346.6],
      [678.0, 346.6],
      [724.0, 346.6],
      [770.0, 346.6],
      [816.0, 346.6],
      [862.0, 346.6],
      [908.0, 346.6],
      [954.0, 346.6],
      [1000.0, 346.6],
      [80.0, 391.03],
      [126.0, 391.03],
      [172.0, 391.03],
      [218.0, 391.03],
      [264.0, 391.03],
      [310.0, 391.03],
      [356.0, 391.03],
      [402.0, 391.03],
      [448.0, 391.03],
      [494.0, 391.03],
      [540.0, 391.03],
      [586.0, 391.03],
      [632.0, 391.03],
      [678.0, 391.03],
      [724.0, 391.03],
      [770.0, 391.03],
      [816.0, 391.03],
      [862.0, 391.03],
      [908.0, 391.03],
      [954.0, 391.03],
      [1000.0, 391.03],
      [80.0, 435.46],
      [126.0, 435.46],
      [172.0, 435.46],
      [218.0, 435.46],
      [264.0, 435.46],
      [310.0, 435.46],
      [356.0, 435.46],
      [402.0, 435.46],
      [448.0, 435.46],
      [494.0, 435.46],
      [540.0, 435.46],
      [586.0, 435.46],
      [632.0, 435.46],
      [678.0, 435.46],
      [724.0, 435.46],
      [770.0, 435.46],
      [816.0, 435.46],
      [862.0, 435.46],
      [908.0, 435.46],
      [954.0, 435.46],
      [1000.0, 435.46],
      [80.0, 479.89],
      [126.0, 479.89],
      [172.0, 479.89],
      [218.0, 479.89],
      [264.0, 479.89],
      [310.0, 479.89],
      [356.0, 479.89],
      [402.0, 479.89],
      [448.0, 479.89],
      [494.0, 479.89],
      [540.0, 479.89],
      [586.0, 479.89],
      [632.0, 479.89],
      [678.0, 479.89],
      [724.0, 479.89],
      [770.0, 479.89],
      [816.0, 479.89],
      [862.0, 479.89],
      [908.0, 479.89],
      [954.0, 479.89],
      [1000.0, 479.89],
      [80.0, 524.33],
      [126.0, 524.33],
      [172.0, 524.33],
      [218.0, 524.33],
      [264.0, 524.33],
      [310.0, 524.33],
      [356.0, 524.33],
      [402.0, 524.33],
      [448.0, 524.33],
      [494.0, 524.33],
      [540.0, 524.33],
      [586.0, 524.33],
      [632.0, 524.33],
      [678.0, 524.33],
      [724.0, 524.33],
      [770.0, 524.33],
      [816.0, 524.33],
      [862.0, 524.33],
      [908.0, 524.33],
      [954.0, 524.33],
      [1000.0, 524.33],
      [80.0, 568.76],
      [126.0, 568.76],
      [172.0, 568.76],
      [218.0, 568.76],
      [264.0, 568.76],
      [310.0, 568.76],
      [356.0, 568.76],
      [402.0, 568.76],
      [448.0, 568.76],
      [494.0, 568.76],
      [540.0, 568.76],
      [586.0, 568.76],
      [632.0, 568.76],
      [678.0, 568.76],
      [724.0, 568.76],
      [770.0, 568.76],
      [816.0, 568.76],
      [862.0, 568.76],
      [908.0, 568.76],
      [954.0, 568.76],
      [1000.0, 568.76],
      [80.0, 613.19],
      [126.0, 613.19],
      [172.0, 613.19],
      [218.0, 613.19],
      [264.0, 613.19],
      [310.0, 613.19],
      [356.0, 613.19],
      [402.0, 613.19],
      [448.0, 613.19],
      [494.0, 613.19],
      [540.0, 613.19],
      [586.0, 613.19],
      [632.0, 613.19],
      [678.0, 613.19],
      [724.0, 613.19],
      [770.0, 613.19],
      [816.0, 613.19],
      [862.0, 613.19],
      [908.0, 613.19],
      [954.0, 613.19],
      [1000.0, 613.19],
      [80.0, 657.62],
      [126.0, 657.62],
      [172.0, 657.62],
      [218.0, 657.62],
      [264.0, 657.62],
      [310.0, 657.62],
      [356.0, 657.62],
      [402.0, 657.62],
      [448.0, 657.62],
      [494.0, 657.62],
      [540.0, 657.62],
      [586.0, 657.62],
      [632.0, 657.62],
      [678.0, 657.62],
      [724.0, 657.62],
      [770.0, 657.62],
      [816.0, 657.62],
      [862.0, 657.62],
      [908.0, 657.62],
      [954.0, 657.62],
      [1000.0, 657.62],
      [80.0, 702.06],
      [126.0, 702.06],
      [172.0, 702.06],
      [218.0, 702.06],
      [264.0, 702.06],
      [310.0, 702.06],
      [356.0, 702.06],
      [402.0, 702.06],
      [448.0, 702.06],
      [494.0, 702.06],
      [540.0, 702.06],
      [586.0, 702.06],
      [632.0, 702.06],
      [678.0, 702.06],
      [724.0, 702.06],
      [770.0, 702.06],
      [816.0, 702.06],
      [862.0, 702.06],
      [908.0, 702.06],
      [954.0, 702.06],
      [1000.0, 702.06],
      [80.0, 746.49],
      [126.0, 746.49],
      [172.0, 746.49],
      [218.0, 746.49],
      [264.0, 746.49],
      [310.0, 746.49],
      [356.0, 746.49],
      [402.0, 746.49],
      [448.0, 746.49],
      [494.0, 746.49],
      [540.0, 746.49],
      [586.0, 746.49],
      [632.0, 746.49],
      [678.0, 746.49],
      [724.0, 746.49],
      [770.0, 746.49],
      [816.0, 746.49],
      [862.0, 746.49],
      [908.0, 746.49],
      [954.0, 746.49],
      [1000.0, 746.49],
      [80.0, 790.92],
      [126.0, 790.92],
      [172.0, 790.92],
      [218.0, 790.92],
      [264.0, 790.92],
      [310.0, 790.92],
      [356.0, 790.92],
      [402.0, 790.92],
      [448.0, 790.92],
      [494.0, 790.92],
      [540.0, 790.92],
      [586.0, 790.92],
      [632.0, 790.92],
      [678.0, 790.92],
      [724.0, 790.92],
      [770.0, 790.92],
      [816.0, 790.92],
      [862.0, 790.92],
      [908.0, 790.92],
      [954.0, 790.92],
      [1000.0, 790.92],
      [80.0, 835.35],
      [126.0, 835.35],
      [172.0, 835.35],
      [218.0, 835.35],
      [264.0, 835.35],
      [310.0, 835.35],
      [356.0, 835.35],
      [402.0, 835.35],
      [448.0, 835.35],
      [494.0, 835.35],
      [540.0, 835.35],
      [586.0, 835.35],
      [632.0, 835.35],
      [678.0, 835.35],
      [724.0, 835.35],
      [770.0, 835.35],
      [816.0, 835.35],
      [862.0, 835.35],
      [908.0, 835.35],
      [954.0, 835.35],
      [1000.0, 835.35],
      [80.0, 879.79],
      [126.0, 879.79],
      [172.0, 879.79],
      [218.0, 879.79],
      [264.0, 879.79],
      [310.0, 879.79],
      [356.0, 879.79],
      [402.0, 879.79],
      [448.0, 879.79],
      [494.0, 879.79],
      [540.0, 879.79],
      [586.0, 879.79],
      [632.0, 879.79],
      [678.0, 879.79],
      [724.0, 879.79],
      [770.0, 879.79],
      [816.0, 879.79],
      [862.0, 879.79],
      [908.0, 879.79],
      [954.0, 879.79],
      [1000.0, 879.79],
      [80.0, 924.22],
      [126.0, 924.22],
      [172.0, 924.22],
      [218.0, 924.22],
      [264.0, 924.22],
      [310.0, 924.22],
      [356.0, 924.22],
      [402.0, 924.22],
      [448.0, 924.22],
      [494.0, 924.22],
      [540.0, 924.22],
      [586.0, 924.22],
      [632.0, 924.22],
      [678.0, 924.22],
      [724.0, 924.22],
      [770.0, 924.22],
      [816.0, 924.22],
      [862.0, 924.22],
      [908.0, 924.22],
      [954.0, 924.22],
      [1000.0, 924.22],
      [80.0, 968.65],
      [126.0, 968.65],
      [172.0, 968.65],
      [218.0, 968.65],
      [264.0, 968.65],
      [310.0, 968.65],
      [356.0, 968.65],
      [402.0, 968.65],
      [448.0, 968.65],
      [494.0, 968.65],
      [540.0, 968.65],
      [586.0, 968.65],
      [632.0, 968.65],
      [678.0, 968.65],
      [724.0, 968.65],
      [770.0, 968.65],
      [816.0, 968.65],
      [862.0, 968.65],
      [908.0, 968.65],
      [954.0, 968.65],
      [1000.0, 968.65],
    ];

    final coordinates = <List<Offset>>[];
    int index = 0;

    for (int row = 0; row < 21; row++) {
      final rowCoords = <Offset>[];
      for (int col = 0; col < 21; col++) {
        final x =
            rawCoordinates[index][0] * scale;
        final y =
            rawCoordinates[index][1] * scale;
        rowCoords.add(Offset(x, y));
        index++;
      }
      coordinates.add(rowCoords);
    }

    return coordinates;
  }
}

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
    final radius = size.width * 0.4;

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

    canvas.drawCircle(
      center + const Offset(1.5, 2),
      radius,
      shadowPaint,
    );
    canvas.drawCircle(center, radius, basePaint);

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

    final xPaint = Paint()
      ..color = Colors.red.shade800.withOpacity(
        opacity,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final xSize = radius * 0.6;

    canvas.drawLine(
      center - Offset(xSize, xSize),
      center + Offset(xSize, xSize),
      xPaint,
    );

    canvas.drawLine(
      center - Offset(xSize, -xSize),
      center + Offset(xSize, -xSize),
      xPaint,
    );

    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      center - const Offset(3, 3),
      radius * 0.3,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) => false;
}

class CrosshairPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const CrosshairPainter({
    required this.color,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final cornerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final cornerSize = 8.0;
    final cornerOffset = 12.0;

    // 좌상단 괄호 ┌
    canvas.drawLine(
      Offset(
        center.dx - cornerOffset,
        center.dy - cornerOffset,
      ),
      Offset(
        center.dx - cornerOffset + cornerSize,
        center.dy - cornerOffset,
      ),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(
        center.dx - cornerOffset,
        center.dy - cornerOffset,
      ),
      Offset(
        center.dx - cornerOffset,
        center.dy - cornerOffset + cornerSize,
      ),
      cornerPaint,
    );

    // 우상단 괄호 ┐
    canvas.drawLine(
      Offset(
        center.dx + cornerOffset,
        center.dy - cornerOffset,
      ),
      Offset(
        center.dx + cornerOffset - cornerSize,
        center.dy - cornerOffset,
      ),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(
        center.dx + cornerOffset,
        center.dy - cornerOffset,
      ),
      Offset(
        center.dx + cornerOffset,
        center.dy - cornerOffset + cornerSize,
      ),
      cornerPaint,
    );

    // 좌하단 괄호 └
    canvas.drawLine(
      Offset(
        center.dx - cornerOffset,
        center.dy + cornerOffset,
      ),
      Offset(
        center.dx - cornerOffset + cornerSize,
        center.dy + cornerOffset,
      ),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(
        center.dx - cornerOffset,
        center.dy + cornerOffset,
      ),
      Offset(
        center.dx - cornerOffset,
        center.dy + cornerOffset - cornerSize,
      ),
      cornerPaint,
    );

    // 우하단 괄호 ┘
    canvas.drawLine(
      Offset(
        center.dx + cornerOffset,
        center.dy + cornerOffset,
      ),
      Offset(
        center.dx + cornerOffset - cornerSize,
        center.dy + cornerOffset,
      ),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(
        center.dx + cornerOffset,
        center.dy + cornerOffset,
      ),
      Offset(
        center.dx + cornerOffset,
        center.dy + cornerOffset - cornerSize,
      ),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) => false;
}
