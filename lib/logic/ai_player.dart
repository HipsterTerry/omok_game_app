import 'dart:math' as math;
import '../models/game_state.dart';
import '../models/enhanced_game_state.dart';
import '../logic/omok_game_logic.dart';
import '../logic/renju_rule_checker.dart';

enum AIDifficulty { easy, normal, hard }

class AIPlayer {
  final AIDifficulty difficulty;
  final PlayerType aiPlayerType;
  final math.Random _random = math.Random();

  AIPlayer({
    required this.difficulty,
    required this.aiPlayerType,
  });

  // AI의 다음 수를 계산
  Future<Position?> getNextMove(
    EnhancedGameState gameState,
  ) async {
    // 실제 게임에서는 사용자 경험을 위해 약간의 지연 추가
    await Future.delayed(
      Duration(milliseconds: _getThinkingTime()),
    );

    switch (difficulty) {
      case AIDifficulty.easy:
        return _getEasyMove(gameState);
      case AIDifficulty.normal:
        return _getNormalMove(gameState);
      case AIDifficulty.hard:
        return _getHardMove(gameState);
    }
  }

  int _getThinkingTime() {
    switch (difficulty) {
      case AIDifficulty.easy:
        return 500 +
            _random.nextInt(500); // 0.5-1초
      case AIDifficulty.normal:
        return 1000 +
            _random.nextInt(1000); // 1-2초
      case AIDifficulty.hard:
        return 1500 +
            _random.nextInt(1500); // 1.5-3초
    }
  }

  // 쉬움: 무작위 위치 (유효한 수만)
  Position? _getEasyMove(
    EnhancedGameState gameState,
  ) {
    final validMoves = _getValidMoves(gameState);
    if (validMoves.isEmpty) return null;

    return validMoves[_random.nextInt(
      validMoves.length,
    )];
  }

  // 보통: 기본 공격/수비 로직
  Position? _getNormalMove(
    EnhancedGameState gameState,
  ) {
    // 1. 즉시 승리 가능한 수 찾기
    final winningMove = _findWinningMove(
      gameState,
      aiPlayerType,
    );
    if (winningMove != null) return winningMove;

    // 2. 상대방 승리 차단
    final opponentType =
        aiPlayerType == PlayerType.black
        ? PlayerType.white
        : PlayerType.black;
    final blockingMove = _findWinningMove(
      gameState,
      opponentType,
    );
    if (blockingMove != null) return blockingMove;

    // 3. 3연속 만들기
    final threatenMove = _findThreateningMove(
      gameState,
      aiPlayerType,
    );
    if (threatenMove != null) return threatenMove;

    // 4. 상대방 3연속 차단
    final blockThreatenMove =
        _findThreateningMove(
          gameState,
          opponentType,
        );
    if (blockThreatenMove != null)
      return blockThreatenMove;

    // 5. 중앙 근처 랜덤
    return _getCenterBiasedMove(gameState);
  }

  // 어려움: 고급 전략 (미니맥스 간소화 버전)
  Position? _getHardMove(
    EnhancedGameState gameState,
  ) {
    // 1. 즉시 승리
    final winningMove = _findWinningMove(
      gameState,
      aiPlayerType,
    );
    if (winningMove != null) return winningMove;

    // 2. 상대방 승리 차단
    final opponentType =
        aiPlayerType == PlayerType.black
        ? PlayerType.white
        : PlayerType.black;
    final blockingMove = _findWinningMove(
      gameState,
      opponentType,
    );
    if (blockingMove != null) return blockingMove;

    // 3. 고급 전략: 여러 수 앞을 내다보는 평가
    return _getBestStrategicMove(gameState);
  }

  // 유효한 모든 수 찾기
  List<Position> _getValidMoves(
    EnhancedGameState gameState,
  ) {
    final validMoves = <Position>[];

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
        if (gameState.isValidMove(row, col)) {
          // 렌주 룰 검증
          if (RenjuRuleChecker.isValidMove(
            gameState.board,
            row,
            col,
            aiPlayerType,
          )) {
            validMoves.add(Position(row, col));
          }
        }
      }
    }

    return validMoves;
  }

  // 즉시 승리 가능한 수 찾기
  Position? _findWinningMove(
    EnhancedGameState gameState,
    PlayerType playerType,
  ) {
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
        if (gameState.isValidMove(row, col)) {
          // 렌주 룰 검증
          if (!RenjuRuleChecker.isValidMove(
            gameState.board,
            row,
            col,
            playerType,
          ))
            continue;

          // 임시로 돌 놓기
          final tempBoard = gameState.board
              .map(
                (row) =>
                    List<PlayerType?>.from(row),
              )
              .toList();
          tempBoard[row][col] = playerType;

          // 승리 확인
          if (OmokGameLogic.checkWinner(
                tempBoard,
                Position(row, col),
              ) ==
              playerType) {
            return Position(row, col);
          }
        }
      }
    }
    return null;
  }

  // 3연속 만들 수 있는 수 찾기
  Position? _findThreateningMove(
    EnhancedGameState gameState,
    PlayerType playerType,
  ) {
    final candidates = <Position>[];

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
        if (gameState.isValidMove(row, col)) {
          if (!RenjuRuleChecker.isValidMove(
            gameState.board,
            row,
            col,
            playerType,
          ))
            continue;

          final score = _evaluatePosition(
            gameState,
            Position(row, col),
            playerType,
          );
          if (score >= 3) {
            // 3연속 이상의 가치
            candidates.add(Position(row, col));
          }
        }
      }
    }

    if (candidates.isNotEmpty) {
      return candidates[_random.nextInt(
        candidates.length,
      )];
    }
    return null;
  }

  // 중앙 편향 랜덤 수
  Position? _getCenterBiasedMove(
    EnhancedGameState gameState,
  ) {
    final validMoves = _getValidMoves(gameState);
    if (validMoves.isEmpty) return null;

    final center = gameState.boardSize / 2;

    // 중앙에서 가까운 순으로 정렬
    validMoves.sort((a, b) {
      final distA = math.sqrt(
        math.pow(a.row - center, 2) +
            math.pow(a.col - center, 2),
      );
      final distB = math.sqrt(
        math.pow(b.row - center, 2) +
            math.pow(b.col - center, 2),
      );
      return distA.compareTo(distB);
    });

    // 상위 30% 중에서 랜덤 선택
    final topCount = math.max(
      1,
      (validMoves.length * 0.3).round(),
    );
    final topMoves = validMoves
        .take(topCount)
        .toList();

    return topMoves[_random.nextInt(
      topMoves.length,
    )];
  }

  // 고급 전략적 수 (간소화된 미니맥스)
  Position? _getBestStrategicMove(
    EnhancedGameState gameState,
  ) {
    final validMoves = _getValidMoves(gameState);
    if (validMoves.isEmpty) return null;

    Position? bestMove;
    double bestScore = double.negativeInfinity;

    for (final move in validMoves) {
      final score =
          _evaluatePosition(
            gameState,
            move,
            aiPlayerType,
          ) -
          _evaluatePosition(
                gameState,
                move,
                aiPlayerType == PlayerType.black
                    ? PlayerType.white
                    : PlayerType.black,
              ) *
              0.8;

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove;
  }

  // 위치 평가 함수
  double _evaluatePosition(
    EnhancedGameState gameState,
    Position pos,
    PlayerType playerType,
  ) {
    double score = 0.0;

    // 8방향 검사
    final directions = [
      [-1, -1],
      [-1, 0],
      [-1, 1],
      [0, -1],
      [0, 1],
      [1, -1],
      [1, 0],
      [1, 1],
    ];

    for (final dir in directions) {
      final lineScore = _evaluateLine(
        gameState,
        pos,
        dir,
        playerType,
      );
      score += lineScore;
    }

    // 중앙 보너스
    final center = gameState.boardSize / 2;
    final centerDistance = math.sqrt(
      math.pow(pos.row - center, 2) +
          math.pow(pos.col - center, 2),
    );
    score +=
        (gameState.boardSize - centerDistance) *
        0.1;

    return score;
  }

  // 한 방향 라인 평가
  double _evaluateLine(
    EnhancedGameState gameState,
    Position pos,
    List<int> direction,
    PlayerType playerType,
  ) {
    int consecutive = 0;
    int openEnds = 0;

    // 한 방향으로 검사
    for (int i = 1; i < 5; i++) {
      final newRow = pos.row + direction[0] * i;
      final newCol = pos.col + direction[1] * i;

      if (newRow < 0 ||
          newRow >= gameState.boardSize ||
          newCol < 0 ||
          newCol >= gameState.boardSize) {
        break;
      }

      if (gameState.board[newRow][newCol] ==
          playerType) {
        consecutive++;
      } else if (gameState
              .board[newRow][newCol] ==
          null) {
        openEnds++;
        break;
      } else {
        break;
      }
    }

    // 반대 방향으로 검사
    for (int i = 1; i < 5; i++) {
      final newRow = pos.row - direction[0] * i;
      final newCol = pos.col - direction[1] * i;

      if (newRow < 0 ||
          newRow >= gameState.boardSize ||
          newCol < 0 ||
          newCol >= gameState.boardSize) {
        break;
      }

      if (gameState.board[newRow][newCol] ==
          playerType) {
        consecutive++;
      } else if (gameState
              .board[newRow][newCol] ==
          null) {
        openEnds++;
        break;
      } else {
        break;
      }
    }

    // 점수 계산
    if (consecutive >= 4) return 1000.0; // 5목
    if (consecutive == 3 && openEnds == 2)
      return 100.0; // 열린 4목
    if (consecutive == 3 && openEnds == 1)
      return 50.0; // 막힌 4목
    if (consecutive == 2 && openEnds == 2)
      return 10.0; // 열린 3목
    if (consecutive == 2 && openEnds == 1)
      return 5.0; // 막힌 3목
    if (consecutive == 1 && openEnds == 2)
      return 2.0; // 열린 2목

    return 1.0; // 기본 점수
  }

  // AI가 스킬을 사용할지 결정
  bool shouldUseSkill(
    EnhancedGameState gameState,
  ) {
    if (gameState.currentPlayerState.skillUsed)
      return false;
    if (gameState.currentPlayerState.character ==
        null)
      return false;

    switch (difficulty) {
      case AIDifficulty.easy:
        return _random.nextDouble() <
            0.1; // 10% 확률
      case AIDifficulty.normal:
        return _random.nextDouble() <
            0.3; // 30% 확률
      case AIDifficulty.hard:
        return _random.nextDouble() <
            0.5; // 50% 확률
    }
  }
}
