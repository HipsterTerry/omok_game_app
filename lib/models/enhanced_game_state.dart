import 'game_state.dart';
import 'character.dart';
import 'game_item.dart';
import 'player_profile.dart';

class PlayerGameState {
  final Character? character;
  final bool skillUsed; // 스킬 사용 여부
  final Map<String, GameItemState>
  availableItems; // 사용 가능한 아이템들
  final int timeRemaining; // 남은 시간 (초)

  const PlayerGameState({
    this.character,
    this.skillUsed = false,
    required this.availableItems,
    this.timeRemaining = 300, // 기본 5분
  });

  bool canUseSkill() {
    return character != null && !skillUsed;
  }

  PlayerGameState copyWith({
    Character? character,
    bool? skillUsed,
    Map<String, GameItemState>? availableItems,
    int? timeRemaining,
  }) {
    return PlayerGameState(
      character: character ?? this.character,
      skillUsed: skillUsed ?? this.skillUsed,
      availableItems:
          availableItems ??
          Map.from(this.availableItems),
      timeRemaining:
          timeRemaining ?? this.timeRemaining,
    );
  }
}

class EnhancedGameState extends GameState {
  final int boardSize;
  final PlayerGameState blackPlayerState;
  final PlayerGameState whitePlayerState;
  final int turnCount; // 턴 수
  final List<String>
  gameLog; // 게임 로그 (스킬/아이템 사용 기록)
  final bool isPaused;
  final DateTime gameStartTime;

  EnhancedGameState({
    required this.boardSize,
    List<List<PlayerType?>>? board,
    PlayerType currentPlayer = PlayerType.black,
    GameStatus status = GameStatus.playing,
    List<Position>? moves,
    Position? lastMove,
    required this.blackPlayerState,
    required this.whitePlayerState,
    this.turnCount = 0,
    List<String>? gameLog,
    this.isPaused = false,
    DateTime? gameStartTime,
  }) : gameLog = gameLog ?? [],
       gameStartTime =
           gameStartTime ?? DateTime.now(),
       super(
         board:
             board ??
             List.generate(
               boardSize,
               (_) =>
                   List.filled(boardSize, null),
             ),
         currentPlayer: currentPlayer,
         status: status,
         moves: moves,
         lastMove: lastMove,
       );

  @override
  EnhancedGameState copyWith({
    int? boardSize,
    List<List<PlayerType?>>? board,
    PlayerType? currentPlayer,
    GameStatus? status,
    List<Position>? moves,
    Position? lastMove,
    PlayerGameState? blackPlayerState,
    PlayerGameState? whitePlayerState,
    int? turnCount,
    List<String>? gameLog,
    bool? isPaused,
    DateTime? gameStartTime,
  }) {
    return EnhancedGameState(
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
      blackPlayerState:
          blackPlayerState ??
          this.blackPlayerState,
      whitePlayerState:
          whitePlayerState ??
          this.whitePlayerState,
      turnCount: turnCount ?? this.turnCount,
      gameLog: gameLog ?? List.from(this.gameLog),
      isPaused: isPaused ?? this.isPaused,
      gameStartTime:
          gameStartTime ?? this.gameStartTime,
    );
  }

  @override
  bool isValidMove(int row, int col) {
    if (row < 0 ||
        row >= boardSize ||
        col < 0 ||
        col >= boardSize) {
      return false;
    }
    return board[row][col] == null;
  }

  PlayerGameState get currentPlayerState {
    return currentPlayer == PlayerType.black
        ? blackPlayerState
        : whitePlayerState;
  }

  PlayerGameState get opponentPlayerState {
    return currentPlayer == PlayerType.black
        ? whitePlayerState
        : blackPlayerState;
  }

  Duration get elapsedTime {
    return DateTime.now().difference(
      gameStartTime,
    );
  }

  // 스킬 사용 가능 여부 확인
  bool canUseSkill() {
    return currentPlayerState.canUseSkill();
  }

  // 아이템 사용 가능 여부 확인
  bool canUseItem(String itemId) {
    final itemState =
        currentPlayerState.availableItems[itemId];
    if (itemState == null) return false;
    return itemState.canUseOnTurn(turnCount);
  }

  // 게임 로그 추가
  EnhancedGameState addToLog(String logEntry) {
    return copyWith(
      gameLog: [...gameLog, logEntry],
    );
  }

  // 턴 종료 시 상태 업데이트
  EnhancedGameState endTurn() {
    return copyWith(
      currentPlayer: nextPlayer,
      turnCount: turnCount + 1,
    );
  }

  // 캐릭터 스킬 효과 적용된 승률 보너스 계산
  double getWinRateBonus() {
    final character =
        currentPlayerState.character;
    if (character == null) return 0.0;
    return character.winRateBonus;
  }

  // 게임 결과를 위한 최종 상태
  GameResult toGameResult(
    PlayerProfile winner,
    PlayerProfile loser,
  ) {
    return GameResult(
      winner: winner,
      loser: loser,
      gameStatus: status,
      totalMoves: moves.length,
      gameDuration: elapsedTime,
      boardSize: boardSize,
      winnerCharacter: winner.selectedCharacter,
      gameLog: gameLog,
      endTime: DateTime.now(),
    );
  }
}

class GameResult {
  final PlayerProfile winner;
  final PlayerProfile loser;
  final GameStatus gameStatus;
  final int totalMoves;
  final Duration gameDuration;
  final int boardSize;
  final Character? winnerCharacter;
  final List<String> gameLog;
  final DateTime endTime;

  const GameResult({
    required this.winner,
    required this.loser,
    required this.gameStatus,
    required this.totalMoves,
    required this.gameDuration,
    required this.boardSize,
    this.winnerCharacter,
    required this.gameLog,
    required this.endTime,
  });

  int get experienceGained {
    // 승리: 100 경험치, 패배: 20 경험치, 무승부: 50 경험치
    // 게임 시간과 보드 크기에 따른 보너스
    int baseExp = gameStatus == GameStatus.draw
        ? 50
        : 100;
    int timeBonus = (gameDuration.inMinutes * 2)
        .clamp(0, 50);
    int boardBonus =
        (boardSize - 13) * 10; // 큰 보드일수록 보너스

    return baseExp + timeBonus + boardBonus;
  }

  int get coinsEarned {
    // 승리: 50 코인, 패배: 10 코인, 무승부: 25 코인
    int baseCoins = gameStatus == GameStatus.draw
        ? 25
        : 50;
    int moveBonus = (totalMoves / 10)
        .round()
        .clamp(0, 20);

    return baseCoins + moveBonus;
  }
}
