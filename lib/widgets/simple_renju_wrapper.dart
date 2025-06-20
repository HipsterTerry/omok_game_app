import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../logic/advanced_renju_rule_evaluator.dart';

import 'game_board_widget.dart';

import 'renju_warning_overlay.dart';

class SimpleRenjuWrapper extends StatefulWidget {
  final GameState gameState;
  final Function(int row, int col) onTileTap;
  final double? boardSize;

  const SimpleRenjuWrapper({
    super.key,
    required this.gameState,
    required this.onTileTap,
    this.boardSize,
  });

  @override
  State<SimpleRenjuWrapper> createState() =>
      _SimpleRenjuWrapperState();
}

class _SimpleRenjuWrapperState
    extends State<SimpleRenjuWrapper> {
  String? _currentWarning;

  @override
  Widget build(BuildContext context) {
    final size =
        widget.boardSize ??
        MediaQuery.of(context).size.width * 0.9;

    return Stack(
      alignment: Alignment.center,
      children: [
        // 기존 게임판 위젯 (전혀 수정하지 않음)
        GameBoardWidget(
          gameState: widget.gameState,
          onStonePlace: (position) =>
              _handleTileTap(
                position.row,
                position.col,
              ),
        ),

        // 렌주룰 금지 위치 오버레이
        Positioned.fill(
          child: _buildForbiddenOverlay(size),
        ),

        // 경고 메시지 오버레이
        if (_currentWarning != null)
          RenjuWarningOverlay(
            message: _currentWarning!,
            onComplete: () {
              setState(() {
                _currentWarning = null;
              });
            },
          ),
      ],
    );
  }

  Widget _buildForbiddenOverlay(double size) {
    final boardSize = widget.gameState.boardSize;
    final tileSize = size / boardSize;
    final List<Widget> markers = [];

    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        if (widget.gameState.board[row][col] ==
            null) {
          final forbiddenType =
              AdvancedRenjuRuleEvaluator.getForbiddenTypeAt(
                widget.gameState.board,
                row,
                col,
                widget.gameState.currentPlayer,
                null, // 기본 게임은 AI 난이도 없음
              );

          if (forbiddenType !=
              ForbiddenType.none) {
            markers.add(
              Positioned(
                left:
                    col * tileSize +
                    (tileSize - 24) / 2,
                top:
                    row * tileSize +
                    (tileSize - 24) / 2,
                child: GestureDetector(
                  onTap: () =>
                      _handleForbiddenTap(
                        row,
                        col,
                        forbiddenType,
                      ),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.red
                          .withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.red,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 16,
                    ),
                  ),
                ),
              ),
            );
          }
        }
      }
    }

    return Stack(children: markers);
  }

  void _handleTileTap(int row, int col) {
    // 금지 수인지 확인
    final forbiddenType =
        AdvancedRenjuRuleEvaluator.getForbiddenTypeAt(
          widget.gameState.board,
          row,
          col,
          widget.gameState.currentPlayer,
          null, // 기본 게임은 AI 난이도 없음
        );

    if (forbiddenType != ForbiddenType.none) {
      // 금지 수이면 경고 메시지 표시하고 차단
      _handleForbiddenTap(
        row,
        col,
        forbiddenType,
      );
      return;
    }

    // 유효한 수이면 기존 로직 실행
    widget.onTileTap(row, col);
  }

  void _handleForbiddenTap(
    int row,
    int col,
    ForbiddenType forbiddenType,
  ) {
    // 흑돌만 렌주룰 적용
    if (widget.gameState.currentPlayer !=
        PlayerType.black) {
      widget.onTileTap(row, col);
      return;
    }

    print(
      '🚫 금지 수 감지: ($row, $col) - $forbiddenType',
    );

    String warningMessage;
    switch (forbiddenType) {
      case ForbiddenType.doubleThree:
        warningMessage = '삼삼입니다!';
        break;
      case ForbiddenType.doubleFour:
        warningMessage = '사사입니다!';
        break;
      case ForbiddenType.overline:
        warningMessage = '장목입니다!';
        break;
      case ForbiddenType.fourThree:
        warningMessage = '사삼입니다!';
        break;
      default:
        return;
    }

    setState(() {
      _currentWarning = warningMessage;
    });
  }
}
