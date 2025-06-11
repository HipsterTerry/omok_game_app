import '../models/game_state.dart';

class OmokGameLogic {
  static const int winCondition = 5; // 5목으로 승리

  /// 게임 보드에 돌을 놓고 새로운 게임 상태를 반환
  static GameState makeMove(
    GameState gameState,
    int row,
    int col,
  ) {
    if (!gameState.isValidMove(row, col) ||
        gameState.status != GameStatus.playing) {
      return gameState; // 유효하지 않은 수이거나 게임이 끝난 경우
    }

    // 새로운 보드 상태 생성
    final newBoard = gameState.board
        .map((row) => List<PlayerType?>.from(row))
        .toList();
    newBoard[row][col] = gameState.currentPlayer;

    final newPosition = Position(row, col);
    final newMoves = List<Position>.from(
      gameState.moves,
    )..add(newPosition);

    // 승리 조건 확인
    final winner = checkWinner(
      newBoard,
      newPosition,
    );
    GameStatus newStatus = GameStatus.playing;

    if (winner != null) {
      newStatus = winner == PlayerType.black
          ? GameStatus.blackWin
          : GameStatus.whiteWin;
    } else if (isBoardFull(newBoard)) {
      newStatus = GameStatus.draw;
    }

    return gameState.copyWith(
      board: newBoard,
      currentPlayer:
          newStatus == GameStatus.playing
          ? gameState.nextPlayer
          : gameState.currentPlayer,
      status: newStatus,
      moves: newMoves,
      lastMove: newPosition,
    );
  }

  /// 보드가 가득 찼는지 확인
  static bool isBoardFull(
    List<List<PlayerType?>> board,
  ) {
    for (
      int row = 0;
      row < GameState.boardSize;
      row++
    ) {
      for (
        int col = 0;
        col < GameState.boardSize;
        col++
      ) {
        if (board[row][col] == null) {
          return false;
        }
      }
    }
    return true;
  }

  /// 마지막 수에서 승리 조건을 확인
  static PlayerType? checkWinner(
    List<List<PlayerType?>> board,
    Position lastMove,
  ) {
    final player =
        board[lastMove.row][lastMove.col];
    if (player == null) return null;

    // 8방향 검사 (가로, 세로, 대각선)
    final directions = [
      [0, 1], // 가로
      [1, 0], // 세로
      [1, 1], // 우하향 대각선
      [1, -1], // 좌하향 대각선
    ];

    for (final direction in directions) {
      final count =
          1 +
          countDirection(
            board,
            lastMove,
            player,
            direction[0],
            direction[1],
          ) +
          countDirection(
            board,
            lastMove,
            player,
            -direction[0],
            -direction[1],
          );

      if (count >= winCondition) {
        return player;
      }
    }
    return null;
  }

  /// 특정 방향으로 연속된 같은 색 돌의 개수를 셈
  static int countDirection(
    List<List<PlayerType?>> board,
    Position start,
    PlayerType player,
    int deltaRow,
    int deltaCol,
  ) {
    int count = 0;
    int row = start.row + deltaRow;
    int col = start.col + deltaCol;

    while (row >= 0 &&
        row < GameState.boardSize &&
        col >= 0 &&
        col < GameState.boardSize &&
        board[row][col] == player) {
      count++;
      row += deltaRow;
      col += deltaCol;
    }

    return count;
  }

  /// 게임을 초기 상태로 리셋
  static GameState resetGame() {
    return GameState();
  }

  /// 게임 상태를 문자열로 표현 (디버깅용)
  static String boardToString(
    List<List<PlayerType?>> board,
  ) {
    StringBuffer buffer = StringBuffer();
    for (
      int row = 0;
      row < GameState.boardSize;
      row++
    ) {
      for (
        int col = 0;
        col < GameState.boardSize;
        col++
      ) {
        final cell = board[row][col];
        if (cell == null) {
          buffer.write('.');
        } else if (cell == PlayerType.black) {
          buffer.write('●');
        } else {
          buffer.write('○');
        }
        buffer.write(' ');
      }
      buffer.writeln();
    }
    return buffer.toString();
  }
}
