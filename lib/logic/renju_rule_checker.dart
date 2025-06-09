import '../models/game_state.dart';

class RenjuRuleChecker {
  static const int BOARD_SIZE = 19;

  /// 렌주 룰 위반 체크 (흑돌만 적용)
  static bool isValidMove(
    List<List<PlayerType?>> board,
    int row,
    int col,
    PlayerType player,
  ) {
    if (player != PlayerType.black) {
      return true; // 백돌은 렌주 룰 적용 안함
    }

    // 임시로 돌 놓기
    board[row][col] = player;

    bool isValid = true;

    // 삼삼 체크
    if (_hasDoubleThree(board, row, col, player)) {
      isValid = false;
    }

    // 사사 체크
    if (_hasDoubleFour(board, row, col, player)) {
      isValid = false;
    }

    // 장목 체크 (6목 이상)
    if (_hasOverline(board, row, col, player)) {
      isValid = false;
    }

    // 임시 돌 제거
    board[row][col] = null;

    return isValid;
  }

  /// 삼삼 체크: 3을 만드는 2개 이상의 방향이 있는지
  static bool _hasDoubleThree(
    List<List<PlayerType?>> board,
    int row,
    int col,
    PlayerType player,
  ) {
    int threeCount = 0;

    // 4개 축 방향 체크
    List<List<List<int>>> axisDirections = [
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

    for (var axis in axisDirections) {
      if (_isOpenThree(board, row, col, axis[0], axis[1], player)) {
        threeCount++;
      }
    }

    return threeCount >= 2;
  }

  /// 사사 체크: 4를 만드는 2개 이상의 방향이 있는지
  static bool _hasDoubleFour(
    List<List<PlayerType?>> board,
    int row,
    int col,
    PlayerType player,
  ) {
    int fourCount = 0;

    List<List<List<int>>> axisDirections = [
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

    for (var axis in axisDirections) {
      if (_isOpenFour(board, row, col, axis[0], axis[1], player)) {
        fourCount++;
      }
    }

    return fourCount >= 2;
  }

  /// 장목 체크: 6목 이상인지
  static bool _hasOverline(
    List<List<PlayerType?>> board,
    int row,
    int col,
    PlayerType player,
  ) {
    List<List<List<int>>> axisDirections = [
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

    for (var axis in axisDirections) {
      int count = 1; // 현재 위치 포함

      // 양방향으로 연속된 돌 개수 세기
      for (var dir in axis) {
        int r = row + dir[0];
        int c = col + dir[1];

        while (_isValidPosition(r, c, board.length) && board[r][c] == player) {
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

  /// 열린 3 체크 (양쪽이 뚫려있는 3)
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
    while (_isValidPosition(r, c, board.length) && board[r][c] == player) {
      count++;
      r += dir1[0];
      c += dir1[1];
    }
    if (_isValidPosition(r, c, board.length) && board[r][c] == null) {
      leftOpen = true;
    }

    // 반대쪽 방향 체크
    r = row + dir2[0];
    c = col + dir2[1];
    while (_isValidPosition(r, c, board.length) && board[r][c] == player) {
      count++;
      r += dir2[0];
      c += dir2[1];
    }
    if (_isValidPosition(r, c, board.length) && board[r][c] == null) {
      rightOpen = true;
    }

    return count == 3 && leftOpen && rightOpen;
  }

  /// 열린 4 체크 (한쪽이라도 뚫려있는 4)
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
    while (_isValidPosition(r, c, board.length) && board[r][c] == player) {
      count++;
      r += dir1[0];
      c += dir1[1];
    }
    if (_isValidPosition(r, c, board.length) && board[r][c] == null) {
      leftOpen = true;
    }

    // 반대쪽 방향 체크
    r = row + dir2[0];
    c = col + dir2[1];
    while (_isValidPosition(r, c, board.length) && board[r][c] == player) {
      count++;
      r += dir2[0];
      c += dir2[1];
    }
    if (_isValidPosition(r, c, board.length) && board[r][c] == null) {
      rightOpen = true;
    }

    return count == 4 && (leftOpen || rightOpen);
  }

  /// 유효한 위치인지 체크
  static bool _isValidPosition(int row, int col, int boardSize) {
    return row >= 0 && row < boardSize && col >= 0 && col < boardSize;
  }

  /// 승리 조건 체크 (정확히 5목)
  static bool checkWinCondition(
    List<List<PlayerType?>> board,
    int row,
    int col,
    PlayerType player,
  ) {
    List<List<List<int>>> axisDirections = [
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

    for (var axis in axisDirections) {
      int count = 1; // 현재 위치 포함

      // 양방향으로 연속된 돌 개수 세기
      for (var dir in axis) {
        int r = row + dir[0];
        int c = col + dir[1];

        while (_isValidPosition(r, c, board.length) && board[r][c] == player) {
          count++;
          r += dir[0];
          c += dir[1];
        }
      }

      if (count == 5) {
        // 정확히 5목
        return true;
      }
    }

    return false;
  }

  /// 금수 위치 표시용 (UI에서 사용)
  static List<List<int>> getForbiddenMoves(
    List<List<PlayerType?>> board,
    PlayerType player,
  ) {
    List<List<int>> forbidden = [];

    if (player != PlayerType.black) {
      return forbidden; // 백돌은 금수 없음
    }

    for (int row = 0; row < board.length; row++) {
      for (int col = 0; col < board[row].length; col++) {
        if (board[row][col] == null && !isValidMove(board, row, col, player)) {
          forbidden.add([row, col]);
        }
      }
    }

    return forbidden;
  }
}
