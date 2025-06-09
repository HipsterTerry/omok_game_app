import 'package:flutter/material.dart';
import '../models/enhanced_game_state.dart';
import '../models/character.dart';
import '../models/player_profile.dart';
import '../models/game_state.dart';
import '../logic/omok_game_logic.dart';
import '../logic/ai_player.dart';
import '../widgets/enhanced_game_board_widget.dart';
import '../widgets/game_timer_widget.dart';
import '../widgets/game_hud_widget.dart';
import '../widgets/skill_activation_widget.dart';
import '../widgets/animated_stone_widget.dart';
import '../widgets/skill_effect_animations.dart';
import '../services/sound_manager.dart';
import '../logic/renju_rule_checker.dart';

class EnhancedGameScreen extends StatefulWidget {
  final BoardSize boardSize;
  final Character? playerCharacter;
  final bool isAIGame;
  final AIDifficulty? aiDifficulty;

  const EnhancedGameScreen({
    super.key,
    required this.boardSize,
    this.playerCharacter,
    this.isAIGame = false,
    this.aiDifficulty,
  });

  @override
  State<EnhancedGameScreen> createState() =>
      _EnhancedGameScreenState();
}

class _EnhancedGameScreenState
    extends State<EnhancedGameScreen>
    with TickerProviderStateMixin {
  late EnhancedGameState _gameState;
  AIPlayer? _aiPlayer;
  final SoundManager _soundManager =
      SoundManager();

  // 애니메이션 관련
  late AnimationController
  _stoneAnimationController;
  Position? _lastPlacedStone;
  bool _isShowingSkillEffect = false;

  @override
  void initState() {
    super.initState();

    _stoneAnimationController =
        AnimationController(
          duration: const Duration(
            milliseconds: 500,
          ),
          vsync: this,
        );

    _initializeGame();
    _placeFirstStone(); // 13x13 중앙에 첫 돌 배치

    // AI 게임인 경우 AI 플레이어 초기화
    if (widget.isAIGame &&
        widget.aiDifficulty != null) {
      _aiPlayer = AIPlayer(
        difficulty: widget.aiDifficulty!,
        aiPlayerType: PlayerType.white, // AI는 백돌
      );
    }

    // 배경음악 시작
    _soundManager.playBackgroundMusic();
    _soundManager.playGameStart();
  }

  void _initializeGame() {
    final blackPlayerState = PlayerGameState(
      character: widget.playerCharacter,
      availableItems: {},
      timeRemaining: 300,
    );

    final whitePlayerState = PlayerGameState(
      character: null, // AI 또는 다른 플레이어
      availableItems: {},
      timeRemaining: 300,
    );

    _gameState = EnhancedGameState(
      boardSize: widget.boardSize.size,
      blackPlayerState: blackPlayerState,
      whitePlayerState: whitePlayerState,
    );
  }

  void _placeFirstStone() {
    // 모든 보드 크기에서 중앙 화점에 흑돌 배치
    int centerRow, centerCol;

    switch (widget.boardSize.size) {
      case 13:
        centerRow = 6; // 13x13의 정중앙 (0~12 중 6)
        centerCol = 6;
        break;
      case 17:
        centerRow = 8; // 17x17의 정중앙 (0~16 중 8)
        centerCol = 8;
        break;
      case 21:
        centerRow = 10; // 21x21의 정중앙 (0~20 중 10)
        centerCol = 10;
        break;
      default:
        // 기본값 (만약 다른 크기가 있다면)
        centerRow = widget.boardSize.size ~/ 2;
        centerCol = widget.boardSize.size ~/ 2;
    }

    setState(() {
      _gameState.board[centerRow][centerCol] =
          PlayerType.black;

      final newPosition = Position(
        centerRow,
        centerCol,
      );
      final newMoves = List<Position>.from(
        _gameState.moves,
      )..add(newPosition);

      _gameState = _gameState.copyWith(
        board: _gameState.board,
        currentPlayer:
            PlayerType.white, // 백돌 차례로 변경
        moves: newMoves,
        lastMove: newPosition,
        turnCount: 1,
      );
    });
  }

  void _onTileTap(int row, int col) {
    if (_gameState.status != GameStatus.playing) {
      return;
    }

    // AI 턴인 경우 사용자 입력 무시
    if (widget.isAIGame &&
        _gameState.currentPlayer ==
            PlayerType.white) {
      return;
    }

    if (!_gameState.isValidMove(row, col)) {
      return;
    }

    // 렌주 룰 검증 (흑돌만)
    if (!RenjuRuleChecker.isValidMove(
      _gameState.board,
      row,
      col,
      _gameState.currentPlayer,
    )) {
      _showRenjuRuleDialog();
      return;
    }

    _makeMove(row, col);
  }

  void _makeMove(int row, int col) async {
    final currentPlayer =
        _gameState.currentPlayer;

    // 사운드 효과
    _soundManager.playStonePlace(
      currentPlayer == PlayerType.black,
    );

    setState(() {
      // 기본 오목 로직 적용
      final newBoard = _gameState.board
          .map(
            (row) => List<PlayerType?>.from(row),
          )
          .toList();
      newBoard[row][col] = currentPlayer;

      final newPosition = Position(row, col);
      final newMoves = List<Position>.from(
        _gameState.moves,
      )..add(newPosition);

      // 승리 조건 확인
      final winner = OmokGameLogic.checkWinner(
        newBoard,
        newPosition,
      );
      GameStatus newStatus = GameStatus.playing;

      if (winner != null) {
        newStatus =
            currentPlayer == PlayerType.black
            ? GameStatus.blackWin
            : GameStatus.whiteWin;
      } else if (OmokGameLogic.isBoardFull(
        newBoard,
      )) {
        newStatus = GameStatus.draw;
      }

      // 턴 수 증가
      final newTurnCount =
          _gameState.turnCount + 1;

      _gameState = _gameState.copyWith(
        board: newBoard,
        currentPlayer:
            newStatus == GameStatus.playing
            ? _gameState.nextPlayer
            : _gameState.currentPlayer,
        moves: newMoves,
        lastMove: newPosition,
        status: newStatus,
        turnCount: newTurnCount,
      );

      _lastPlacedStone = newPosition;
    });

    // 애니메이션 재생
    _stoneAnimationController.forward();

    if (_gameState.status != GameStatus.playing) {
      _handleGameEnd();
    } else if (widget.isAIGame &&
        _gameState.currentPlayer ==
            PlayerType.white) {
      // AI 턴
      _handleAITurn();
    }
  }

  void _handleAITurn() async {
    if (_aiPlayer == null ||
        _gameState.status != GameStatus.playing)
      return;

    // 현재 플레이어가 AI인지 확인
    if (_gameState.currentPlayer !=
        PlayerType.white)
      return;

    // 짧은 지연으로 자연스러운 느낌
    await Future.delayed(
      const Duration(milliseconds: 200),
    );

    // AI 스킬 사용 결정
    if (_aiPlayer!.shouldUseSkill(_gameState)) {
      _usePlayerSkill(PlayerType.white);
      await Future.delayed(
        const Duration(milliseconds: 800),
      );
    }

    // 게임이 여전히 진행 중인지 확인
    if (_gameState.status != GameStatus.playing)
      return;

    // AI 수 계산
    final aiMove = await _aiPlayer!.getNextMove(
      _gameState,
    );
    if (aiMove != null &&
        _gameState.status == GameStatus.playing &&
        _gameState.currentPlayer ==
            PlayerType.white) {
      _makeMove(aiMove.row, aiMove.col);
    }
  }

  void _handleGameEnd() {
    // 게임 종료 사운드
    if (_gameState.status ==
        GameStatus.blackWin) {
      if (widget.isAIGame) {
        _soundManager.playVictory(); // 플레이어 승리
      } else {
        _soundManager.playVictory();
      }
    } else if (_gameState.status ==
        GameStatus.whiteWin) {
      if (widget.isAIGame) {
        _soundManager.playDefeat(); // AI 승리
      } else {
        _soundManager.playVictory();
      }
    }

    _showGameResult();
  }

  void _useSkill() {
    if (!_gameState.canUseSkill()) return;

    final character =
        _gameState.currentPlayerState.character;
    if (character == null) return;

    setState(() {
      // 스킬 사용 상태 업데이트
      final currentPlayerState = _gameState
          .currentPlayerState
          .copyWith(skillUsed: true);

      _gameState = _gameState.copyWith(
        blackPlayerState:
            _gameState.currentPlayer ==
                PlayerType.black
            ? currentPlayerState
            : _gameState.blackPlayerState,
        whitePlayerState:
            _gameState.currentPlayer ==
                PlayerType.white
            ? currentPlayerState
            : _gameState.whitePlayerState,
      );

      // 게임 로그에 추가
      _gameState = _gameState.addToLog(
        '${_gameState.currentPlayer == PlayerType.black ? '흑돌' : '백돌'}이 ${character.skill.name} 스킬을 사용했습니다.',
      );
    });

    // 스킬 효과 다이얼로그 표시
    _showSkillEffectDialog(character.skill);
  }

  void _showSkillEffectDialog(
    CharacterSkill skill,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getSkillIcon(skill.type),
              color: _getSkillColor(skill.type),
            ),
            const SizedBox(width: 8),
            Text(skill.name),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              skill.description,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getSkillColor(
                  skill.type,
                ).withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(8),
              ),
              child: const Text(
                '스킬이 발동되었습니다!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showRenjuRuleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.warning,
              color: Colors.red,
            ),
            SizedBox(width: 8),
            Text('렌주 룰 위반'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              '흑돌은 다음 조건에 해당하는 수를 둘 수 없습니다:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text('• 삼삼: 3을 동시에 2개 이상 만드는 수'),
            Text('• 사사: 4를 동시에 2개 이상 만드는 수'),
            Text('• 장목: 6목 이상 만드는 수'),
            SizedBox(height: 12),
            Text(
              '다른 위치에 돌을 놓아주세요.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _onTimeUp(PlayerType player) {
    if (_gameState.status != GameStatus.playing)
      return;

    setState(() {
      _gameState = _gameState.copyWith(
        status: player == PlayerType.black
            ? GameStatus
                  .whiteWin // 흑돌 시간 초과시 백돌 승리
            : GameStatus
                  .blackWin, // 백돌 시간 초과시 흑돌 승리
      );
    });

    _showTimeUpDialog(player);
  }

  void _showTimeUpDialog(PlayerType player) {
    final playerName = player == PlayerType.black
        ? '흑돌'
        : '백돌';
    final winner = player == PlayerType.black
        ? '백돌'
        : '흑돌';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.timer_off,
              color: Colors.red,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text('시간 초과!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$playerName의 시간이 초과되었습니다.',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.yellow.withOpacity(
                      0.8,
                    ),
                    Colors.orange.withOpacity(
                      0.6,
                    ),
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    '🎉 승리!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '$winner 승리!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: const Text('새 게임'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(
                context,
              ).pop(); // 게임 화면 종료
            },
            child: const Text('메인으로'),
          ),
        ],
      ),
    );
  }

  IconData _getSkillIcon(SkillType type) {
    switch (type) {
      case SkillType.offensive:
        return Icons.flash_on;
      case SkillType.defensive:
        return Icons.shield;
      case SkillType.disruptive:
        return Icons.shuffle;
      case SkillType.timeControl:
        return Icons.access_time;
    }
  }

  Color _getSkillColor(SkillType type) {
    switch (type) {
      case SkillType.offensive:
        return Colors.red;
      case SkillType.defensive:
        return Colors.blue;
      case SkillType.disruptive:
        return Colors.purple;
      case SkillType.timeControl:
        return Colors.orange;
    }
  }

  void _showGameResult() {
    String message;
    Color messageColor;

    switch (_gameState.status) {
      case GameStatus.blackWin:
        message = '흑돌 승리!';
        messageColor = Colors.green;
        break;
      case GameStatus.whiteWin:
        message = '백돌 승리!';
        messageColor = Colors.green;
        break;
      case GameStatus.draw:
        message = '무승부!';
        messageColor = Colors.orange;
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _gameState.status == GameStatus.draw
                  ? Icons.handshake
                  : Icons.emoji_events,
              color: messageColor,
            ),
            const SizedBox(width: 8),
            Text('게임 종료'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: messageColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildGameSummary(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: const Text('다시 시작'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(
                context,
              ).pop(); // 홈으로 돌아가기
            },
            child: const Text('홈으로'),
          ),
        ],
      ),
    );
  }

  Widget _buildGameSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            '게임 시간',
            _formatDuration(
              _gameState.elapsedTime,
            ),
          ),
          _buildSummaryRow(
            '총 수',
            '${_gameState.moves.length}수',
          ),
          _buildSummaryRow(
            '보드 크기',
            '${_gameState.boardSize}x${_gameState.boardSize}',
          ),
          if (_gameState
                  .blackPlayerState
                  .character !=
              null)
            _buildSummaryRow(
              '사용 캐릭터',
              _gameState
                  .blackPlayerState
                  .character!
                  .koreanName,
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 2,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _resetGame() {
    setState(() {
      _initializeGame();
    });
  }

  Widget _buildBottomSkillControls() {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.6),
            Colors.black.withOpacity(0.9),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceEvenly,
        children: [
          // 흑돌 스킬 버튼
          SkillActivationWidget(
            character: _gameState
                .blackPlayerState
                .character,
            canUseSkill: !_gameState
                .blackPlayerState
                .skillUsed,
            isCurrentTurn:
                _gameState.currentPlayer ==
                PlayerType.black,
            onSkillActivated: () =>
                _usePlayerSkill(PlayerType.black),
          ),

          // 중앙 게임 로그 버튼
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[700],
              border: Border.all(
                color: Colors.grey[500]!,
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: _showGameLog,
              icon: const Icon(
                Icons.history,
                color: Colors.white,
                size: 18,
              ),
              tooltip: '게임 로그',
            ),
          ),

          // 백돌 스킬 버튼
          SkillActivationWidget(
            character: _gameState
                .whitePlayerState
                .character,
            canUseSkill: !_gameState
                .whitePlayerState
                .skillUsed,
            isCurrentTurn:
                _gameState.currentPlayer ==
                PlayerType.white,
            onSkillActivated: () =>
                _usePlayerSkill(PlayerType.white),
          ),
        ],
      ),
    );
  }

  Widget _buildGameControls() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: _resetGame,
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            tooltip: '게임 초기화',
          ),
          IconButton(
            onPressed: () =>
                Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close,
              color: Colors.white,
            ),
            tooltip: '게임 종료',
          ),
        ],
      ),
    );
  }

  void _usePlayerSkill(PlayerType player) {
    if (_gameState.currentPlayer != player)
      return;

    final playerState = player == PlayerType.black
        ? _gameState.blackPlayerState
        : _gameState.whitePlayerState;

    if (playerState.skillUsed ||
        playerState.character == null)
      return;

    // 스킬 사운드 효과
    _soundManager.playSkillActivation(
      playerState.character!.skillType,
    );

    setState(() {
      final updatedPlayerState = playerState
          .copyWith(skillUsed: true);

      _gameState = _gameState.copyWith(
        blackPlayerState:
            player == PlayerType.black
            ? updatedPlayerState
            : _gameState.blackPlayerState,
        whitePlayerState:
            player == PlayerType.white
            ? updatedPlayerState
            : _gameState.whitePlayerState,
      );

      // 게임 로그에 추가
      final playerName =
          player == PlayerType.black
          ? '흑돌'
          : '백돌';
      final skillName =
          playerState.character!.skillName;
      _gameState = _gameState.addToLog(
        '$playerName이 $skillName 스킬을 사용했습니다.',
      );

      _isShowingSkillEffect = true;
    });

    // 스킬 이펙트 애니메이션 표시
    _showSkillEffectAnimation(
      playerState.character!,
    );
  }

  void _showSkillEffectAnimation(
    Character character,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: SizedBox(
          width: 300,
          height: 300,
          child: SkillEffectAnimations(
            skillType: character.skillType,
            tier: character.tier,
            boardSize: const Size(300, 300),
            onComplete: () {
              Navigator.of(context).pop();
              setState(() {
                _isShowingSkillEffect = false;
              });
            },
          ),
        ),
      ),
    );
  }

  void _showGameLog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('게임 로그'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: _gameState.gameLog.isEmpty
              ? const Center(
                  child: Text('아직 기록이 없습니다.'),
                )
              : ListView.builder(
                  itemCount:
                      _gameState.gameLog.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Text(
                        '${index + 1}.',
                      ),
                      title: Text(
                        _gameState.gameLog[index],
                      ),
                      dense: true,
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _stoneAnimationController.dispose();
    _soundManager.stopBackgroundMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF1A1A1A,
      ), // 어두운 배경
      body: SafeArea(
        child: Stack(
          children: [
            // 메인 게임 화면
            Column(
              children: [
                // 타이머 HUD 시스템
                _buildGameStatusHeader(),

                // 게임 보드 (중앙)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(4),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // 정사각형 크기 계산 (가장 작은 치수 기준)
                          final boardSize =
                              constraints
                                      .maxWidth <
                                  constraints
                                      .maxHeight
                              ? constraints
                                    .maxWidth
                              : constraints
                                    .maxHeight;

                          return EnhancedGameBoardWidget(
                            gameState: _gameState,
                            boardSizeType:
                                widget.boardSize,
                            onTileTap: _onTileTap,
                            boardSize:
                                boardSize *
                                0.98, // 98% 크기로 최대 확대
                            showCoordinates:
                                false, // 깔끔한 UI를 위해 좌표 숨김
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // 하단 스킬 및 컨트롤 영역
                _buildBottomSkillControls(),
              ],
            ),

            // 상단 우측 게임 컨트롤 (작게)
            Positioned(
              top: 16,
              right: 16,
              child: _buildGameControls(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameStatusHeader() {
    final currentCharacter =
        _gameState.currentPlayerState.character;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[900]!.withOpacity(0.95),
            Colors.grey[800]!.withOpacity(0.85),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // 타이머 및 게임 정보
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
            children: [
              // 흑돌 타이머
              Expanded(
                child: GameTimerWidget(
                  key: ValueKey(
                    'black_timer_${_gameState.turnCount}',
                  ),
                  isCurrentPlayer:
                      _gameState.currentPlayer ==
                      PlayerType.black,
                  initialTime: _gameState
                      .blackPlayerState
                      .timeRemaining,
                  moveTimeLimit: 30,
                  onTimeUp: () =>
                      _onTimeUp(PlayerType.black),
                  primaryColor: Colors.grey[300]!,
                  accentColor: Colors.grey[500]!,
                  playerName: "흑돌",
                ),
              ),

              // 중앙 게임 정보
              Container(
                margin:
                    const EdgeInsets.symmetric(
                      horizontal: 4,
                    ),
                padding:
                    const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.withOpacity(
                        0.9,
                      ),
                      Colors.yellow.withOpacity(
                        0.7,
                      ),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_gameState.currentPlayer == PlayerType.black ? '흑돌' : '백돌'} 차례',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_gameState.turnCount}수 다음',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                    ),
                    Text(
                      '렌주룰',
                      style: TextStyle(
                        color: Colors.red[200],
                        fontSize: 6,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // 백돌 타이머
              Expanded(
                child: GameTimerWidget(
                  key: ValueKey(
                    'white_timer_${_gameState.turnCount}',
                  ),
                  isCurrentPlayer:
                      _gameState.currentPlayer ==
                      PlayerType.white,
                  initialTime: _gameState
                      .whitePlayerState
                      .timeRemaining,
                  moveTimeLimit: 30,
                  onTimeUp: () =>
                      _onTimeUp(PlayerType.white),
                  primaryColor: Colors.blue[300]!,
                  accentColor: Colors.blue[500]!,
                  playerName: "백돌",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: _resetGame,
            icon: const Icon(Icons.refresh),
            label: const Text('새 게임'),
          ),
          ElevatedButton.icon(
            onPressed: () =>
                Navigator.of(context).pop(),
            icon: const Icon(Icons.home),
            label: const Text('홈으로'),
          ),
        ],
      ),
    );
  }

  Color _getTierColor(CharacterTier tier) {
    switch (tier) {
      case CharacterTier.heaven:
        return const Color(0xFFFFD700);
      case CharacterTier.earth:
        return const Color(0xFF8B4513);
      case CharacterTier.human:
        return const Color(0xFF708090);
    }
  }

  IconData _getCharacterIcon(CharacterType type) {
    switch (type) {
      case CharacterType.rat:
        return Icons.mouse;
      case CharacterType.ox:
        return Icons.emoji_nature;
      case CharacterType.tiger:
        return Icons.pets;
      case CharacterType.rabbit:
        return Icons.cruelty_free;
      case CharacterType.dragon:
        return Icons.whatshot;
      case CharacterType.snake:
        return Icons.timeline;
      case CharacterType.horse:
        return Icons.directions_run;
      case CharacterType.goat:
        return Icons.agriculture;
      case CharacterType.monkey:
        return Icons.face;
      case CharacterType.rooster:
        return Icons.alarm;
      case CharacterType.dog:
        return Icons.pets_outlined;
      case CharacterType.pig:
        return Icons.savings;
    }
  }
}
