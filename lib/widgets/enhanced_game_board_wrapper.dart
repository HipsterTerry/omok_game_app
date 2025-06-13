import 'package:flutter/material.dart';
import '../models/enhanced_game_state.dart';
import '../models/game_state.dart';
import '../models/player_profile.dart';
import '../logic/ai_player.dart';
import '../logic/advanced_renju_rule_evaluator.dart';
import 'enhanced_game_board_widget.dart';
import 'forbidden_move_overlay.dart';
import 'renju_warning_overlay.dart';

/// 기존 EnhancedGameBoardWidget을 감싸서 렌주룰 기능을 추가하는 래퍼
/// 기존 코드는 전혀 수정하지 않고 외부에서만 기능 추가
class EnhancedGameBoardWrapper extends StatefulWidget {
  final EnhancedGameState gameState;
  final Function(int row, int col) onTileTap;
  final double? boardSize;
  final bool showCoordinates;
  final BoardSize boardSizeType;
  final AIDifficulty? aiDifficulty;

  const EnhancedGameBoardWrapper({
    super.key,
    required this.gameState,
    required this.onTileTap,
    required this.boardSizeType,
    this.boardSize,
    this.showCoordinates = false,
    this.aiDifficulty,
  });

  @override
  State<EnhancedGameBoardWrapper> createState() =>
      _EnhancedGameBoardWrapperState();
}

class _EnhancedGameBoardWrapperState extends State<EnhancedGameBoardWrapper> {
  @override
  Widget build(BuildContext context) {
    // 모바일 환경에 최적화된 보드 크기 설정 (기존 로직과 동일)
    final screenSize = MediaQuery.of(context).size;
    final availableSize = screenSize.width < screenSize.height
        ? screenSize.width -
              40 // 세로 모드: 좌우 여백 40px
        : screenSize.height - 200; // 가로 모드: 상하 UI 공간 확보

    final size = widget.boardSize ?? availableSize;

    return Stack(
      alignment: Alignment.center,
      children: [
        // 기존 게임판 위젯 (전혀 수정하지 않음)
        EnhancedGameBoardWidget(
          gameState: widget.gameState,
          onTileTap: _handleTileTap,
          boardSizeType: widget.boardSizeType,
          boardSize: size,
          showCoordinates: widget.showCoordinates,
        ),

        // 렌주룰 금지 위치 오버레이 (새로 추가)
        ForbiddenMoveOverlay(
          board: widget.gameState.board,
          currentPlayer: widget.gameState.currentPlayer,
          aiDifficulty: widget.aiDifficulty,
          boardSize: size,
          gridSize: widget.gameState.boardSize,
          onForbiddenTap: _handleForbiddenTap,
        ),
      ],
    );
  }

  /// 기존 onTileTap을 감싸서 렌주룰 체크 추가
  void _handleTileTap(int row, int col) {
    // 금지 수인지 확인
    final forbiddenType = AdvancedRenjuRuleEvaluator.getForbiddenTypeAt(
      widget.gameState.board,
      row,
      col,
      widget.gameState.currentPlayer,
      widget.aiDifficulty,
    );

    if (forbiddenType != ForbiddenType.none) {
      // 금지 수이면 경고 메시지 표시하고 차단
      _handleForbiddenTap(row, col, forbiddenType);
      return;
    }

    // 유효한 수이면 기존 로직 실행
    widget.onTileTap(row, col);
  }

  /// 금지 수 클릭 시 경고 메시지 표시
  void _handleForbiddenTap(int row, int col, ForbiddenType forbiddenType) {
    if (!mounted) return;

    RenjuWarningHelper.showWarning(context, forbiddenType);
  }
}
