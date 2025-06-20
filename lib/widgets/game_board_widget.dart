import 'package:flutter/material.dart';
import '../models/game_state.dart';
import 'dart:math' as math;

class GameBoardWidget extends StatelessWidget {
  final GameState gameState;
  final Function(Position) onStonePlace;

  // 🔍 디버깅용 변수들
  static Offset? _lastTouchPosition;
  static Position? _lastSelectedGrid;
  static double? _lastCellSize;
  static double? _lastBoardMargin;

  const GameBoardWidget({
    super.key,
    required this.gameState,
    required this.onStonePlace,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;

        return Stack(
          children: [
            // 🖼️ 보드 이미지 (PNG 파일)
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    _getBoardImagePath(),
                  ),
                  fit: BoxFit.cover,
                  onError:
                      (exception, stackTrace) {
                        // 무인 루프 방지 - 디버깅 로그 제거
                      },
                ),
              ),
              child: CustomPaint(
                painter: BoardLinePainter(
                  gameState.boardSize,
                ),
                size: Size(size, size),
              ),
            ),

            // 🎯 돌들 렌더링
            ..._buildStones(Size(size, size)),

            // 디버깅 오버레이 제거됨

            // 🎯 터치 감지 영역
            GestureDetector(
              onTapDown: (details) {
                final position = _getGridPosition(
                  details.localPosition,
                  Size(size, size),
                );
                if (position != null) {
                  onStonePlace(position);
                }
              },
              child: Container(
                width: size,
                height: size,
                color: Colors.transparent,
              ),
            ),
          ],
        );
      },
    );
  }

  // 🎯 바둑판 배경 이미지 빌드 (보드 크기별 동적 선택)
  Widget _buildBoardBackground() {
    String imagePath;
    switch (gameState.boardSize) {
      case 13: // 13x13
        imagePath =
            'assets/image/board/board_13x13.png';
        break;
      case 17: // 17x17
        imagePath =
            'assets/image/board/board_17x17.png';
        break;
      case 21: // 21x21
        imagePath =
            'assets/image/board/board_21x21.png';
        break;
      default:
        imagePath =
            'assets/image/board/board_13x13.png';
    }

    // 무한 루프 방지 - 디버깅 로그 제거

    return Image.asset(
      imagePath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // 무인 루프 방지 - 디버깅 로그 제거

        // 🎨 이미지 로딩 실패시 CustomPainter fallback
        return CustomPaint(
          painter: BoardLinePainter(
            gameState.boardSize,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(
                0xFFD2B48C,
              ), // 바둑판 색상
              border: Border.all(
                color: Colors.black,
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildStones(Size size) {
    final stones = <Widget>[];
    final cellSize =
        size.width / gameState.boardSize;
    final boardMargin = cellSize * 0.6;

    // ✅ 돌 크기를 크게 조정 (cellSize * 1.2)
    final stoneSize =
        cellSize * 1.8; // 오목돌 크기를 훨씬 크게 조정
    final stoneSizeMultiplier =
        1.2; // 0.7에서 1.2로 증가

    // 돌 크기 디버깅 로그 제거 - 무한 루프 방지

    for (
      int row = 0;
      row < gameState.boardSize;
      row++
    ) {
      for (
        int col = 0;
        col < gameState.boardSize;
        col++
      ) {
        final stone = gameState.board[row][col];
        if (stone != null) {
          // 격자점 중심 위치 계산
          final x = boardMargin + col * cellSize;
          final y = boardMargin + row * cellSize;

          // 🚫 보드 경계 확인
          final maxValidRow =
              gameState.boardSize - 1;
          final maxValidCol =
              gameState.boardSize - 1;

          if (row > maxValidRow ||
              col > maxValidCol) {
            // 무한 루프 방지 - 디버깅 로그 제거
            continue;
          }

          // 무한 루프 방지 - 디버깅 로그 제거

          stones.add(
            Positioned(
              left: x - stoneSize / 2,
              top: y - stoneSize / 2,
              child: Container(
                width: stoneSize,
                height: stoneSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(
                            alpha: 0.15,
                          ),
                      blurRadius: 1,
                      offset: const Offset(
                        0.5,
                        0.5,
                      ),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    stone == PlayerType.black
                        ? 'assets/image/black_stone.png'
                        : 'assets/image/white_stone.png',
                    width: stoneSize,
                    height: stoneSize,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    return stones;
  }

  // 터치/클릭 위치를 그리드 좌표로 변환
  Position? _getGridPosition(
    Offset localPosition,
    Size size,
  ) {
    final cellSize =
        size.width / gameState.boardSize;
    final boardMargin = cellSize * 0.6;

    // 🔍 디버깅 정보 저장
    _lastTouchPosition = localPosition;
    _lastCellSize = cellSize;
    _lastBoardMargin = boardMargin;

    // 🎯 기본 경계 체크
    if (localPosition.dx < boardMargin ||
        localPosition.dx >
            size.width - boardMargin ||
        localPosition.dy < boardMargin ||
        localPosition.dy >
            size.height - boardMargin) {
      // 무한 루프 방지 - 디버깅 로그 제거
      _lastSelectedGrid = null;
      return null;
    }

    // 🎯 보드 크기에 따른 동적 터치 허용 범위 조정 (더 엄격하게)
    double toleranceMultiplier;
    switch (gameState.boardSize) {
      case 13: // 13x13 - 큰 격자, 적당한 허용 범위
        toleranceMultiplier = 0.55; // 0.70 → 0.55
        break;
      case 17: // 17x17 - 중간 격자, 중간 허용 범위
        toleranceMultiplier = 0.50; // 0.65 → 0.50
        break;
      case 21: // 21x21 - 작은 격자, 작은 허용 범위
        toleranceMultiplier = 0.45; // 0.60 → 0.45
        break;
      default:
        toleranceMultiplier = 0.50;
    }

    final tolerance =
        cellSize * toleranceMultiplier;

    // 디버그 로그 제거됨

    // 전체 그리드를 스캔하여 가장 가까운 교점 찾기
    Position? bestMatch;
    double bestDistance = double.infinity;
    List<Map<String, dynamic>> nearbyGrids =
        []; // 근처 격자점들 기록

    for (
      int row = 0;
      row < gameState.boardSize;
      row++
    ) {
      for (
        int col = 0;
        col < gameState.boardSize;
        col++
      ) {
        // 🎯 각 격자점의 중심 좌표 계산 (마진 고려)
        final gridCenterX =
            boardMargin + cellSize * col;
        final gridCenterY =
            boardMargin + cellSize * row;

        // 터치 위치와 격자점 사이의 거리 계산
        final distance =
            (Offset(gridCenterX, gridCenterY) -
                    localPosition)
                .distance;

        // 가까운 격자점들 기록 (거리 50px 이내)
        if (distance <= 50) {
          nearbyGrids.add({
            'row': row,
            'col': col,
            'x': gridCenterX,
            'y': gridCenterY,
            'distance': distance,
            'withinTolerance':
                distance <= tolerance,
          });
        }

        // 허용 범위 내에서 가장 가까운 점 찾기
        if (distance <= tolerance &&
            distance < bestDistance) {
          bestDistance = distance;
          bestMatch = Position(
            row: row,
            col: col,
          );
        }
      }
    }

    // 근처 격자점들 정렬 (디버그 로그 제거됨)
    nearbyGrids.sort(
      (a, b) =>
          a['distance'].compareTo(b['distance']),
    );

    // 최종 결과 처리 (디버그 로그 제거됨)
    if (bestMatch != null) {
      _lastSelectedGrid = bestMatch;
    } else {
      _lastSelectedGrid = null;
    }

    return bestMatch;
  }

  String _getBoardImagePath() {
    return 'assets/image/board/board_${gameState.boardSize}x${gameState.boardSize}.png';
  }
}

class Position {
  final int row;
  final int col;

  Position({
    required this.row,
    required this.col,
  });
}

class BoardLinePainter extends CustomPainter {
  final int boardSize;

  const BoardLinePainter(this.boardSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0;

    final cellSize = size.width / boardSize;
    final boardMargin =
        cellSize * 0.6; // 돌 배치와 동일한 마진

    // 🎯 격자선 그리기 (마진 고려)
    for (int i = 0; i < boardSize; i++) {
      final position = boardMargin + cellSize * i;

      // 세로선 그리기
      canvas.drawLine(
        Offset(position, boardMargin),
        Offset(
          position,
          size.height - boardMargin,
        ),
        paint,
      );

      // 가로선 그리기
      canvas.drawLine(
        Offset(boardMargin, position),
        Offset(
          size.width - boardMargin,
          position,
        ),
        paint,
      );
    }

    // 🎯 화점 (별점) 그리기
    final centerPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // 중앙점 (천원) - 돌 크기에 맞춰 조정
    final center = boardSize ~/ 2;
    final centerX =
        boardMargin + cellSize * center;
    final centerY =
        boardMargin + cellSize * center;

    canvas.drawCircle(
      Offset(centerX, centerY),
      1.8, // 2.5 → 1.8 (30% 감소)
      centerPaint,
    );

    // 🎯 보드 크기별 화점 위치 설정
    List<List<int>> starPoints = [];
    if (boardSize == 13) {
      starPoints = [
        [3, 3], [3, 9], [9, 3], [9, 9], // 모서리 4개
        [6, 3],
        [6, 9],
        [3, 6],
        [9, 6], // 변의 중앙 4개
      ];
    } else if (boardSize == 17) {
      starPoints = [
        [3, 3],
        [3, 13],
        [13, 3],
        [13, 13], // 모서리 4개
        [8, 3],
        [8, 13],
        [3, 8],
        [13, 8], // 변의 중앙 4개
      ];
    } else if (boardSize == 21) {
      starPoints = [
        [3, 3],
        [3, 17],
        [17, 3],
        [17, 17], // 모서리 4개
        [10, 3],
        [10, 17],
        [3, 10],
        [17, 10], // 변의 중앙 4개
      ];
    }

    // 화점 그리기 - 크기 조정
    for (final point in starPoints) {
      if (point[0] != center ||
          point[1] != center) {
        // 중앙점은 이미 그렸으므로 제외
        final x =
            boardMargin + cellSize * point[0];
        final y =
            boardMargin + cellSize * point[1];
        canvas.drawCircle(
          Offset(x, y),
          1.05, // 1.5 → 1.05 (30% 감소)
          centerPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) => false;
}

// TouchDebugPainter 클래스 제거됨
