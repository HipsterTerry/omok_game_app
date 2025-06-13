import '../models/game_state.dart';
import '../logic/ai_player.dart';

/// 렌주룰 위반 타입
enum ForbiddenType {
  none,
  doubleThree, // 삼삼
  doubleFour, // 사사
  overline, // 장목 (6목 이상)
  fourThree, // 사삼 (고급 난이도만)
}

/// 고급 난이도에서만 작동하는 렌주룰 평가기 (최적화 버전)
/// 기존 코드와 완전히 분리되어 외부에서 동작
class AdvancedRenjuRuleEvaluator {
  // 성능 최적화를 위한 캐시
  static Map<String, List<Position>>
  _forbiddenCache = {};
  static String _lastBoardHash = '';

  /// 금지 위치 정보 (최적화됨)
  static List<Position> getForbiddenPositions(
    List<List<PlayerType?>> board,
    PlayerType currentPlayer,
    AIDifficulty? aiDifficulty,
  ) {
    // 흑돌만 렌주룰 적용
    if (currentPlayer != PlayerType.black) {
      return [];
    }

    // 보드 해시 생성 (간단한 캐싱)
    final boardHash = _generateBoardHash(board);
    final cacheKey =
        '$boardHash-${aiDifficulty?.toString() ?? 'none'}';

    // 캐시된 결과가 있으면 반환
    if (_forbiddenCache.containsKey(cacheKey) &&
        boardHash == _lastBoardHash) {
      return _forbiddenCache[cacheKey]!;
    }

    List<Position> forbiddenPositions = [];
    final boardSize = board.length;

    // 최적화: 돌이 놓인 주변 영역만 체크 (전체 보드 스캔 대신)
    final checkPositions = _getRelevantPositions(
      board,
      boardSize,
    );

    for (final pos in checkPositions) {
      final row = pos.row;
      final col = pos.col;

      // 빈 자리만 체크
      if (board[row][col] != null) continue;

      final forbiddenType = _getForbiddenType(
        board,
        row,
        col,
        currentPlayer,
        aiDifficulty,
      );

      if (forbiddenType != ForbiddenType.none) {
        forbiddenPositions.add(
          Position(row, col),
        );
      }
    }

    // 캐시 저장
    _forbiddenCache[cacheKey] =
        forbiddenPositions;
    _lastBoardHash = boardHash;

    return forbiddenPositions;
  }

  /// 보드 해시 생성 (간단한 버전)
  static String _generateBoardHash(
    List<List<PlayerType?>> board,
  ) {
    final buffer = StringBuffer();
    for (int i = 0; i < board.length; i++) {
      for (int j = 0; j < board[i].length; j++) {
        final cell = board[i][j];
        if (cell == PlayerType.black) {
          buffer.write('B$i$j');
        } else if (cell == PlayerType.white) {
          buffer.write('W$i$j');
        }
      }
    }
    return buffer.toString();
  }

  /// 관련 위치만 추출 (성능 최적화)
  static List<Position> _getRelevantPositions(
    List<List<PlayerType?>> board,
    int boardSize,
  ) {
    List<Position> positions = [];

    // 돌이 놓인 위치 주변 3칸 이내만 체크
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        if (board[row][col] != null) {
          // 주변 3x3 영역 추가
          for (int dr = -3; dr <= 3; dr++) {
            for (int dc = -3; dc <= 3; dc++) {
              final newRow = row + dr;
              final newCol = col + dc;
              if (_isValidPosition(
                    newRow,
                    newCol,
                    boardSize,
                  ) &&
                  board[newRow][newCol] == null) {
                positions.add(
                  Position(newRow, newCol),
                );
              }
            }
          }
        }
      }
    }

    // 중복 제거
    final uniquePositions = <String, Position>{};
    for (final pos in positions) {
      uniquePositions['${pos.row}-${pos.col}'] =
          pos;
    }

    return uniquePositions.values.toList();
  }

  /// 특정 위치의 금지 타입 확인
  static ForbiddenType getForbiddenTypeAt(
    List<List<PlayerType?>> board,
    int row,
    int col,
    PlayerType currentPlayer,
    AIDifficulty? aiDifficulty,
  ) {
    if (currentPlayer != PlayerType.black) {
      return ForbiddenType.none;
    }

    if (board[row][col] != null) {
      return ForbiddenType.none;
    }

    return _getForbiddenType(
      board,
      row,
      col,
      currentPlayer,
      aiDifficulty,
    );
  }

  /// 금지 타입별 한국어 메시지
  static String getForbiddenMessage(
    ForbiddenType type,
  ) {
    switch (type) {
      case ForbiddenType.doubleThree:
        return "삼삼입니다!";
      case ForbiddenType.doubleFour:
        return "사사입니다!";
      case ForbiddenType.overline:
        return "장목입니다!";
      case ForbiddenType.fourThree:
        return "사삼입니다!";
      case ForbiddenType.none:
        return "";
    }
  }

  /// 캐시 초기화 (게임 리셋 시 호출)
  static void clearCache() {
    _forbiddenCache.clear();
    _lastBoardHash = '';
  }

  /// 내부: 금지 타입 계산
  static ForbiddenType _getForbiddenType(
    List<List<PlayerType?>> board,
    int row,
    int col,
    PlayerType player,
    AIDifficulty? aiDifficulty,
  ) {
    // 임시로 돌 놓기
    board[row][col] = player;

    ForbiddenType result = ForbiddenType.none;

    // 장목 체크 (우선순위 높음)
    if (_hasOverline(board, row, col, player)) {
      result = ForbiddenType.overline;
    }
    // 사사 체크
    else if (_hasDoubleFour(
      board,
      row,
      col,
      player,
    )) {
      result = ForbiddenType.doubleFour;
    }
    // 삼삼 체크
    else if (_hasDoubleThree(
      board,
      row,
      col,
      player,
    )) {
      result = ForbiddenType.doubleThree;
    }
    // 사삼 체크 (고급 난이도만)
    else if (aiDifficulty == AIDifficulty.hard &&
        _hasFourThree(board, row, col, player)) {
      result = ForbiddenType.fourThree;
    }

    // 임시 돌 제거
    board[row][col] = null;

    return result;
  }

  /// 삼삼 체크
  static bool _hasDoubleThree(
    List<List<PlayerType?>> board,
    int row,
    int col,
    PlayerType player,
  ) {
    int openThreeCount = 0;

    // 4개 방향 체크
    final directions = [
      [
        [-1, -1],
        [1, 1],
      ], // 대각선 \
      [
        [-1, 0],
        [1, 0],
      ], // 세로
      [
        [-1, 1],
        [1, -1],
      ], // 대각선 /
      [
        [0, -1],
        [0, 1],
      ], // 가로
    ];

    for (var direction in directions) {
      if (_isOpenThree(
        board,
        row,
        col,
        direction[0],
        direction[1],
        player,
      )) {
        openThreeCount++;
      }
    }

    return openThreeCount >= 2;
  }

  /// 사사 체크
  static bool _hasDoubleFour(
    List<List<PlayerType?>> board,
    int row,
    int col,
    PlayerType player,
  ) {
    int openFourCount = 0;

    final directions = [
      [
        [-1, -1],
        [1, 1],
      ], // 대각선 \
      [
        [-1, 0],
        [1, 0],
      ], // 세로
      [
        [-1, 1],
        [1, -1],
      ], // 대각선 /
      [
        [0, -1],
        [0, 1],
      ], // 가로
    ];

    for (var direction in directions) {
      if (_isOpenFour(
        board,
        row,
        col,
        direction[0],
        direction[1],
        player,
      )) {
        openFourCount++;
      }
    }

    return openFourCount >= 2;
  }

  /// 장목 체크 (6목 이상)
  static bool _hasOverline(
    List<List<PlayerType?>> board,
    int row,
    int col,
    PlayerType player,
  ) {
    final directions = [
      [
        [-1, -1],
        [1, 1],
      ], // 대각선 \
      [
        [-1, 0],
        [1, 0],
      ], // 세로
      [
        [-1, 1],
        [1, -1],
      ], // 대각선 /
      [
        [0, -1],
        [0, 1],
      ], // 가로
    ];

    for (var direction in directions) {
      int count = 1; // 현재 위치 포함

      // 양방향으로 연속된 돌 개수 세기
      for (var dir in direction) {
        int r = row + dir[0];
        int c = col + dir[1];

        while (_isValidPosition(
              r,
              c,
              board.length,
            ) &&
            board[r][c] == player) {
          count++;
          r += dir[0];
          c += dir[1];
        }
      }

      if (count >= 6) {
        return true;
      }
    }

    return false;
  }

  /// 사삼 체크 (고급 난이도 전용)
  static bool _hasFourThree(
    List<List<PlayerType?>> board,
    int row,
    int col,
    PlayerType player,
  ) {
    int fourCount = 0;
    int threeCount = 0;

    final directions = [
      [
        [-1, -1],
        [1, 1],
      ], // 대각선 \
      [
        [-1, 0],
        [1, 0],
      ], // 세로
      [
        [-1, 1],
        [1, -1],
      ], // 대각선 /
      [
        [0, -1],
        [0, 1],
      ], // 가로
    ];

    for (var direction in directions) {
      if (_isOpenFour(
        board,
        row,
        col,
        direction[0],
        direction[1],
        player,
      )) {
        fourCount++;
      } else if (_isOpenThree(
        board,
        row,
        col,
        direction[0],
        direction[1],
        player,
      )) {
        threeCount++;
      }
    }

    return fourCount >= 1 && threeCount >= 1;
  }

  /// 열린 3 체크
  static bool _isOpenThree(
    List<List<PlayerType?>> board,
    int row,
    int col,
    List<int> dir1,
    List<int> dir2,
    PlayerType player,
  ) {
    int count = 1; // 현재 위치
    bool leftOpen = false;
    bool rightOpen = false;

    // 한쪽 방향 체크
    int r = row + dir1[0];
    int c = col + dir1[1];
    while (_isValidPosition(r, c, board.length) &&
        board[r][c] == player) {
      count++;
      r += dir1[0];
      c += dir1[1];
    }
    if (_isValidPosition(r, c, board.length) &&
        board[r][c] == null) {
      leftOpen = true;
    }

    // 반대쪽 방향 체크
    r = row + dir2[0];
    c = col + dir2[1];
    while (_isValidPosition(r, c, board.length) &&
        board[r][c] == player) {
      count++;
      r += dir2[0];
      c += dir2[1];
    }
    if (_isValidPosition(r, c, board.length) &&
        board[r][c] == null) {
      rightOpen = true;
    }

    return count == 3 && leftOpen && rightOpen;
  }

  /// 열린 4 체크
  static bool _isOpenFour(
    List<List<PlayerType?>> board,
    int row,
    int col,
    List<int> dir1,
    List<int> dir2,
    PlayerType player,
  ) {
    int count = 1; // 현재 위치
    bool leftOpen = false;
    bool rightOpen = false;

    // 한쪽 방향 체크
    int r = row + dir1[0];
    int c = col + dir1[1];
    while (_isValidPosition(r, c, board.length) &&
        board[r][c] == player) {
      count++;
      r += dir1[0];
      c += dir1[1];
    }
    if (_isValidPosition(r, c, board.length) &&
        board[r][c] == null) {
      leftOpen = true;
    }

    // 반대쪽 방향 체크
    r = row + dir2[0];
    c = col + dir2[1];
    while (_isValidPosition(r, c, board.length) &&
        board[r][c] == player) {
      count++;
      r += dir2[0];
      c += dir2[1];
    }
    if (_isValidPosition(r, c, board.length) &&
        board[r][c] == null) {
      rightOpen = true;
    }

    return count == 4 && (leftOpen || rightOpen);
  }

  /// 유효한 위치인지 체크
  static bool _isValidPosition(
    int row,
    int col,
    int boardSize,
  ) {
    return row >= 0 &&
        row < boardSize &&
        col >= 0 &&
        col < boardSize;
  }
}
