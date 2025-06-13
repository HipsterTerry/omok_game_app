import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../logic/advanced_renju_rule_evaluator.dart';
import '../logic/ai_player.dart';

/// 금지 위치를 표시하는 오버레이 위젯
/// 기존 게임판 위에 Stack으로 겹쳐서 표시
class ForbiddenMoveOverlay
    extends StatelessWidget {
  final List<List<PlayerType?>> board;
  final PlayerType currentPlayer;
  final AIDifficulty? aiDifficulty;
  final double boardSize;
  final int gridSize;
  final Function(
    int row,
    int col,
    ForbiddenType type,
  )?
  onForbiddenTap;

  const ForbiddenMoveOverlay({
    super.key,
    required this.board,
    required this.currentPlayer,
    required this.aiDifficulty,
    required this.boardSize,
    required this.gridSize,
    this.onForbiddenTap,
  });

  @override
  Widget build(BuildContext context) {
    // 흑돌이 아니면 렌주룰 적용 안함
    if (currentPlayer != PlayerType.black) {
      return const SizedBox.shrink();
    }

    final cellSize = boardSize / (gridSize + 1);
    final forbiddenPositions =
        AdvancedRenjuRuleEvaluator.getForbiddenPositions(
          board,
          currentPlayer,
          aiDifficulty,
        );

    // 디버깅: 금지 위치 개수 출력
    print(
      '🚫 금지 위치 개수: ${forbiddenPositions.length}',
    );
    for (var pos in forbiddenPositions) {
      print('🚫 금지 위치: (${pos.row}, ${pos.col})');
    }

    // IgnorePointer로 터치 이벤트를 하위 위젯으로 통과시킴
    return IgnorePointer(
      child: SizedBox(
        width: boardSize,
        height: boardSize,
        child: Stack(
          children: forbiddenPositions.map((
            position,
          ) {
            final x =
                (position.col + 1) * cellSize;
            final y =
                (position.row + 1) * cellSize;

            return Positioned(
              left: x - 14, // 중앙 정렬
              top: y - 14,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(
                    0.3,
                  ),
                  borderRadius:
                      BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.red.withOpacity(
                      0.9,
                    ),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red
                          .withOpacity(0.3),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.clear,
                  size: 20,
                  color: Colors.red.shade700,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
