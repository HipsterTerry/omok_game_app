import 'package:flutter/material.dart';
import '../models/game_state.dart';

class GameBoardWidget extends StatelessWidget {
  final GameState gameState;
  final Function(int row, int col) onTileTap;
  final double? boardSize;

  const GameBoardWidget({
    super.key,
    required this.gameState,
    required this.onTileTap,
    this.boardSize,
  });

  @override
  Widget build(BuildContext context) {
    final size =
        boardSize ??
        MediaQuery.of(context).size.width * 0.9;
    final tileSize = size / GameState.boardSize;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFD2B48C), // 바둑판 색상
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
      ),
      child: CustomPaint(
        painter: BoardLinePainter(),
        child: GridView.builder(
          physics:
              const NeverScrollableScrollPhysics(),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    GameState.boardSize,
                crossAxisSpacing: 0,
                mainAxisSpacing: 0,
              ),
          itemCount:
              GameState.boardSize *
              GameState.boardSize,
          itemBuilder: (context, index) {
            final row =
                index ~/ GameState.boardSize;
            final col =
                index % GameState.boardSize;
            final stone =
                gameState.board[row][col];

            return GestureDetector(
              onTap: () => onTileTap(row, col),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.transparent,
                    width: 0.5,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 마지막 수 표시
                    if (gameState.lastMove?.row ==
                            row &&
                        gameState.lastMove?.col ==
                            col)
                      Container(
                        width: tileSize * 0.8,
                        height: tileSize * 0.8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.red,
                            width: 3,
                          ),
                        ),
                      ),
                    // 돌 표시
                    if (stone != null)
                      Image.asset(
                        stone == PlayerType.black
                            ? 'assets/image/black_stone.png'
                            : 'assets/image/white_stone.png',
                        width: tileSize * 2.0,
                        height: tileSize * 2.0,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // PNG 이미지가 없을 때 fallback
                          return Container(
                            width: tileSize * 2.0,
                            height:
                                tileSize * 2.0,
                            decoration: BoxDecoration(
                              shape:
                                  BoxShape.circle,
                              color:
                                  stone ==
                                      PlayerType
                                          .black
                                  ? Colors.black
                                  : Colors.white,
                              border: Border.all(
                                color:
                                    stone ==
                                        PlayerType
                                            .white
                                    ? Colors
                                          .black54
                                    : Colors
                                          .transparent,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors
                                      .black
                                      .withOpacity(
                                        0.3,
                                      ),
                                  blurRadius: 3,
                                  offset:
                                      const Offset(
                                        1,
                                        1,
                                      ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class BoardLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0;

    final tileSize =
        size.width / GameState.boardSize;

    // 세로선 그리기
    for (
      int i = 0;
      i <= GameState.boardSize;
      i++
    ) {
      final x = i * tileSize;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // 가로선 그리기
    for (
      int i = 0;
      i <= GameState.boardSize;
      i++
    ) {
      final y = i * tileSize;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // 천원 (중앙점) 그리기
    final centerPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final center = GameState.boardSize ~/ 2;
    final centerX = (center + 0.5) * tileSize;
    final centerY = (center + 0.5) * tileSize;

    canvas.drawCircle(
      Offset(centerX, centerY),
      3,
      centerPaint,
    );

    // 화점 (모서리 점들) 그리기 - 13x13 보드의 경우
    final starPoints = [
      [3, 3], [3, 9], [9, 3], [9, 9], // 모서리 4개
      [6, 3], [6, 9], [3, 6], [9, 6], // 변의 중앙 4개
    ];

    for (final point in starPoints) {
      final x = (point[0] + 0.5) * tileSize;
      final y = (point[1] + 0.5) * tileSize;
      canvas.drawCircle(
        Offset(x, y),
        2,
        centerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) => false;
}
