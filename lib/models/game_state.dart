enum PlayerType { black, white }

enum GameStatus {
  playing,
  blackWin,
  whiteWin,
  draw,
}

class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Position &&
        other.row == row &&
        other.col == col;
  }

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => 'Position($row, $col)';
}

class GameState {
  static const int defaultBoardSize = 13;

  // 🎯 동적 보드 크기 지원
  final int boardSize;

  // 보드 상태: null = 빈 칸, PlayerType.black = 흑돌, PlayerType.white = 백돌
  final List<List<PlayerType?>> board;
  final PlayerType currentPlayer;
  final GameStatus status;
  final List<Position> moves; // 게임 진행 기록
  final Position? lastMove; // 마지막 둔 수

  GameState({
    this.boardSize = defaultBoardSize,
    List<List<PlayerType?>>? board,
    this.currentPlayer = PlayerType.black,
    this.status = GameStatus.playing,
    List<Position>? moves,
    this.lastMove,
  }) : board =
           board ??
           List.generate(
             boardSize,
             (_) => List.filled(boardSize, null),
           ),
       moves = moves ?? [];

  GameState copyWith({
    int? boardSize,
    List<List<PlayerType?>>? board,
    PlayerType? currentPlayer,
    GameStatus? status,
    List<Position>? moves,
    Position? lastMove,
  }) {
    return GameState(
      boardSize: boardSize ?? this.boardSize,
      board:
          board ??
          this.board
              .map(
                (row) =>
                    List<PlayerType?>.from(row),
              )
              .toList(),
      currentPlayer:
          currentPlayer ?? this.currentPlayer,
      status: status ?? this.status,
      moves: moves ?? List.from(this.moves),
      lastMove: lastMove ?? this.lastMove,
    );
  }

  bool isValidMove(int row, int col) {
    if (row < 0 ||
        row >= boardSize ||
        col < 0 ||
        col >= boardSize) {
      return false;
    }
    return board[row][col] == null;
  }

  PlayerType get nextPlayer =>
      currentPlayer == PlayerType.black
      ? PlayerType.white
      : PlayerType.black;

  // 🎯 편의 메서드: 새로운 보드 크기로 게임 생성
  static GameState createWithBoardSize(int size) {
    return GameState(boardSize: size);
  }
}
