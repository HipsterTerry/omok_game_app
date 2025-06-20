import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/enhanced_game_state.dart';
import '../models/character.dart';
import '../models/player_profile.dart';
import '../models/game_state.dart';
import '../logic/omok_game_logic.dart';
import '../logic/ai_player.dart';

import '../widgets/enhanced_game_board_wrapper.dart';
import '../widgets/animated_countdown.dart';

import '../widgets/game_countdown_overlay.dart';
import '../widgets/player_assignment_overlay.dart';

import '../services/sound_manager.dart';

import '../logic/advanced_renju_rule_evaluator.dart';
import 'dart:async';
import 'dart:math' as math;

class EnhancedGameScreen extends StatefulWidget {
  final BoardSize boardSize;
  final Character? blackCharacter;
  final Character? whiteCharacter;
  final bool isAIGame;
  final AIDifficulty? aiDifficulty;

  const EnhancedGameScreen({
    super.key,
    required this.boardSize,
    this.blackCharacter,
    this.whiteCharacter,
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
  bool _showCountdown = true;
  bool _gameStarted = false;

  // 애니메이션 관련
  late AnimationController
  _stoneAnimationController;
  Position? _lastPlacedStone;
  bool _isShowingSkillEffect = false;

  // 타이머 관련
  Timer? _gameTimer;
  Timer? _turnTimer;
  int _blackTotalTime = 300; // 5분 = 300초
  int _whiteTotalTime = 300; // 5분 = 300초
  int _turnTimeRemaining = 30; // 1수당 30초
  bool _isPendingUndoRequest = false;

  // 랜덤 플레이어 배정 관련 (흑돌은 항상 먼저, 누가 흑돌인지만 랜덤)
  bool _isPlayerBlack =
      true; // 플레이어가 흑돌인지 여부 (AI 게임용)
  bool _isPlayer1Black =
      true; // 플레이어1이 흑돌인지 여부 (2인 게임용)
  bool _isPlayerAssignmentShown =
      false; // 플레이어 배정 표시 여부

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
    // 첫 돌 배치는 카운트다운 완료 후에 실행

    // AI 게임인 경우 AI 플레이어 초기화
    if (widget.isAIGame &&
        widget.aiDifficulty != null) {
      // 랜덤으로 플레이어가 흑돌인지 백돌인지 결정
      _isPlayerBlack = math.Random().nextBool();

      // AI는 플레이어가 아닌 색을 담당
      final aiPlayerType = _isPlayerBlack
          ? PlayerType.white
          : PlayerType.black;

      _aiPlayer = AIPlayer(
        difficulty: widget.aiDifficulty!,
        aiPlayerType: aiPlayerType,
      );
    } else {
      // 2인 게임인 경우 플레이어1이 흑돌인지 랜덤 결정
      _isPlayer1Black = math.Random().nextBool();
    }

    // 배경음악 시작
    _soundManager.playBackgroundMusic();
    _soundManager.playGameStart();

    // 타이머는 카운트다운 완료 후에 시작
  }

  void _initializeGame() {
    final blackPlayerState = PlayerGameState(
      character: widget.blackCharacter,
      availableItems: {},
      timeRemaining: _blackTotalTime,
    );

    final whitePlayerState = PlayerGameState(
      character: widget.whiteCharacter,
      availableItems: {},
      timeRemaining: _whiteTotalTime,
    );

    _gameState = EnhancedGameState(
      boardSize: widget.boardSize.size,
      blackPlayerState: blackPlayerState,
      whitePlayerState: whitePlayerState,
      currentPlayer:
          PlayerType.black, // 흑돌이 항상 먼저 시작
    );
  }

  void _placeFirstStone() {
    // 모든 보드 크기에서 중앙 화점에 흑돌 배치 (항상 흑돌이 먼저)
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
      // 새로운 보드 생성하여 중앙에 흑돌 배치
      final newBoard = _gameState.board
          .map(
            (row) => List<PlayerType?>.from(row),
          )
          .toList();
      newBoard[centerRow][centerCol] =
          PlayerType.black;

      final newPosition = Position(
        centerRow,
        centerCol,
      );
      final newMoves = List<Position>.from(
        _gameState.moves,
      )..add(newPosition);

      _gameState = _gameState.copyWith(
        board: newBoard,
        currentPlayer:
            PlayerType.white, // 다음은 백돌 차례
        moves: newMoves,
        lastMove: newPosition,
        turnCount: 1,
      );
    });
  }

  void _onTileTap(int row, int col) {
    // 카운트다운 중이거나 게임이 시작되지 않았으면 차단
    if (_showCountdown ||
        !_gameStarted ||
        _gameState.status != GameStatus.playing) {
      return;
    }

    // AI 턴인 경우 사용자 입력 무시
    if (widget.isAIGame &&
        _aiPlayer != null &&
        _gameState.currentPlayer ==
            _aiPlayer!.aiPlayerType) {
      return;
    }

    if (!_gameState.isValidMove(row, col)) {
      return;
    }

    // 기존 렌주룰 체크는 새로운 AdvancedRenjuRuleEvaluator로 대체됨
    // (EnhancedGameBoardWrapper에서 처리)

    _makeMove(row, col);
  }

  void _onPlayerAssignmentComplete() {
    setState(() {
      _isPlayerAssignmentShown = true;
    });
  }

  void _onCountdownComplete() {
    setState(() {
      _showCountdown = false;
      _gameStarted = true;
    });

    // 카운트다운 완료 후 첫 돌 배치
    _placeFirstStone();

    // 카운트다운 완료 후 타이머 시작
    _startTurnTimer();
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

    // 수를 놓은 후 턴이 바뀌었으므로 30초 타이머 리셋
    if (_gameState.status == GameStatus.playing) {
      _startTurnTimer();
    }

    // 애니메이션 재생
    _stoneAnimationController.forward();

    if (_gameState.status != GameStatus.playing) {
      _handleGameEnd();
    } else if (widget.isAIGame &&
        _aiPlayer != null &&
        _gameState.currentPlayer ==
            _aiPlayer!.aiPlayerType) {
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
        _aiPlayer!.aiPlayerType)
      return;

    // 짧은 지연으로 자연스러운 느낌
    await Future.delayed(
      const Duration(milliseconds: 200),
    );

    // AI 스킬 사용 결정
    if (_aiPlayer!.shouldUseSkill(_gameState)) {
      _useCharacterSkill();
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
            _aiPlayer!.aiPlayerType) {
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
    // 텍스트 설명 없이 순수한 시각적 임팩트만
    _showPureSkillEffect(skill);
  }

  void _showPureSkillEffect(
    CharacterSkill skill,
  ) {
    // 강력한 햅틱 피드백
    HapticFeedback.heavyImpact();

    // 1초 후 자동으로 사라지는 순수 이펙트
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(
        alpha: 0.8,
      ),
      builder: (context) {
        // 1초 후 자동 닫기
        Future.delayed(
          const Duration(milliseconds: 1000),
          () {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
          },
        );

        return Center(
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _getSkillColor(
                    skill.type,
                  ).withValues(alpha: 0.9),
                  _getSkillColor(
                    skill.type,
                  ).withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(
                milliseconds: 800,
              ),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, _) {
                return Transform.scale(
                  scale: 0.5 + (value * 1.5),
                  child: Opacity(
                    opacity: 1.0 - value,
                    child: Icon(
                      _getSkillIcon(skill.type),
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
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
                    Colors.yellow.withValues(
                      alpha: 0.8,
                    ),
                    Colors.orange.withValues(
                      alpha: 0.6,
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
        color: Colors.grey.withValues(alpha: 0.1),
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
    // 기존 타이머들 정지
    _gameTimer?.cancel();
    _turnTimer?.cancel();

    // 렌주룰 캐시 초기화
    AdvancedRenjuRuleEvaluator.clearCache();

    // AI 게임인 경우 AI 플레이어 재초기화
    if (widget.isAIGame &&
        widget.aiDifficulty != null) {
      // 새로운 랜덤 플레이어 배정
      _isPlayerBlack = math.Random().nextBool();

      final aiPlayerType = _isPlayerBlack
          ? PlayerType.white
          : PlayerType.black;

      _aiPlayer = AIPlayer(
        difficulty: widget.aiDifficulty!,
        aiPlayerType: aiPlayerType,
      );
    } else {
      // 2인 게임인 경우 새로운 랜덤 플레이어1 배정
      _isPlayer1Black = math.Random().nextBool();
    }

    setState(() {
      // 게임 상태 완전 초기화
      _gameState = EnhancedGameState(
        boardSize: widget.boardSize.size,
        blackPlayerState: PlayerGameState(
          character: widget.blackCharacter,
          availableItems: {},
          timeRemaining: _blackTotalTime,
        ),
        whitePlayerState: PlayerGameState(
          character: widget.whiteCharacter,
          availableItems: {},
          timeRemaining: _whiteTotalTime,
        ),
        currentPlayer:
            PlayerType.black, // 흑돌이 항상 먼저 시작
      );

      // 타이머 관련 변수들 초기화
      _turnTimeRemaining = 30;
      _showCountdown = true;
      _gameStarted = false;
      _lastPlacedStone = null;
      _isShowingSkillEffect = false;
      _isPendingUndoRequest = false;
      _isPlayerAssignmentShown = false;
    });

    // 애니메이션 초기화
    _stoneAnimationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.black, // 홈 화면과 동일한 검은색 배경
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 100,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(
            left: 8,
            top: 8,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () =>
                Navigator.of(context).pop(),
          ),
        ),
        title: Container(
          padding: const EdgeInsets.only(top: 12),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              // 수 카운터 (홈 화면 스타일)
              Container(
                width: 90,
                height: 75,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.00, -1.00),
                    end: Alignment(0, 1),
                    colors: [
                      const Color(0xFF2196F3),
                      const Color(
                        0xFF2196F3,
                      ).withOpacity(0.7),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF2196F3,
                      ).withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${_gameState.turnCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontFamily:
                              'Cafe24Ohsquare',
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '수',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily:
                            'Cafe24Ohsquare',
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // 30초 카운터 (애니메이션 버전)
              AnimatedCountdown(
                remainingTime: _turnTimeRemaining,
                size: 90, // 기존 Container와 동일한 크기
              ),

              const SizedBox(width: 16),

              // 게임 설정 아이콘 (홈 화면 스타일)
              Container(
                width: 90,
                height: 75,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.00, -1.00),
                    end: Alignment(0, 1),
                    colors: [
                      const Color(0xFF757575),
                      const Color(
                        0xFF757575,
                      ).withOpacity(0.7),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.settings,
                      color: const Color(
                        0xFF5C47CE,
                      ),
                      size: 24,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '설정',
                      style: TextStyle(
                        color: const Color(
                          0xFF5C47CE,
                        ),
                        fontSize: 12,
                        fontFamily: 'SUIT',
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // 🔸 플레이어 타이머 영역 - 키치 테마
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(
                          0xFFF4FEFF,
                        ).withValues(alpha: 0.9),
                        const Color(
                          0xFFDFFBFF,
                        ).withValues(alpha: 0.9),
                      ],
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(
                          0xFF51D4EB,
                        ),
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // 흑돌 타이머
                      Expanded(
                        child: _buildPlayerTimer(
                          PlayerType.black,
                          _blackTotalTime,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // 백돌 타이머
                      Expanded(
                        child: _buildPlayerTimer(
                          PlayerType.white,
                          _whiteTotalTime,
                        ),
                      ),
                    ],
                  ),
                ),

                // 🔸 턴 표시 영역
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          _gameState
                                  .currentPlayer ==
                              PlayerType.black
                          ? [
                              Colors.grey[800]!,
                              Colors.grey[700]!,
                            ]
                          : [
                              Colors.blue[700]!,
                              Colors.blue[600]!,
                            ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.circle,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_gameState.currentPlayer == PlayerType.black ? "흑돌" : "백돌"}의 차례',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      if (_gameState
                                  .currentPlayer ==
                              PlayerType.black
                          ? _gameState
                                    .blackPlayerState
                                    .character !=
                                null
                          : _gameState
                                    .whitePlayerState
                                    .character !=
                                null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          _getCharacterIcon(
                            (_gameState.currentPlayer ==
                                        PlayerType
                                            .black
                                    ? _gameState
                                          .blackPlayerState
                                          .character!
                                    : _gameState
                                          .whitePlayerState
                                          .character!)
                                .type,
                          ),
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                ),

                // 🎮 메인 게임 보드 (화면의 대부분 차지)
                Expanded(
                  flex:
                      12, // 보드에 더 많은 공간 할당 (10→12)
                  child: Container(
                    padding: const EdgeInsets.all(
                      2,
                    ), // 패딩 더 줄임 (4→2)
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // 화면의 거의 전체를 보드로 사용 (더 크게)
                        final maxSize =
                            math.min(
                              constraints
                                  .maxWidth,
                              constraints
                                  .maxHeight,
                            ) *
                            0.99; // 0.98→0.99로 증가

                        return Center(
                          child: Stack(
                            children: [
                              // 메인 게임 보드
                              EnhancedGameBoardWrapper(
                                gameState:
                                    _gameState,
                                boardSizeType:
                                    widget
                                        .boardSize,
                                onTileTap:
                                    _onTileTap,
                                boardSize:
                                    maxSize,
                                showCoordinates:
                                    false, // 좌표 표시 비활성화
                                aiDifficulty: widget
                                    .aiDifficulty,
                              ),

                              // 오목판에는 스킬버튼 제거 (하단으로 이동)
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // 🎯 게임 정보 및 컨트롤 (더 작게)
                Container(
                  padding: const EdgeInsets.all(
                    8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black
                        .withValues(alpha: 0.9),
                    borderRadius:
                        const BorderRadius.vertical(
                          top: Radius.circular(
                            20,
                          ),
                        ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(
                              alpha: 0.5,
                            ),
                        blurRadius: 10,
                        offset: const Offset(
                          0,
                          -2,
                        ),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      // 스킬 버튼과 정보
                      if (_gameState
                                  .blackPlayerState
                                  .character !=
                              null ||
                          _gameState
                                  .whitePlayerState
                                  .character !=
                              null)
                        _buildBottomSkillSection(),

                      const SizedBox(height: 8),

                      // 게임 컨트롤
                      _buildBasicGameControls(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 플레이어 배정 오버레이 (가장 먼저 표시)
          if (!_isPlayerAssignmentShown)
            PlayerAssignmentOverlay(
              firstPlayer:
                  PlayerType.black, // 흑돌이 항상 먼저
              isPlayerBlack: widget.isAIGame
                  ? _isPlayerBlack
                  : _isPlayer1Black,
              isAIGame: widget.isAIGame,
              onComplete:
                  _onPlayerAssignmentComplete,
            ),

          // 카운트다운 오버레이
          if (_isPlayerAssignmentShown)
            GameCountdownOverlay(
              showCountdown: _showCountdown,
              onCountdownComplete:
                  _onCountdownComplete,
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentTurnDisplay() {
    final currentCharacter =
        _gameState.currentPlayer ==
            PlayerType.black
        ? _gameState.blackPlayerState.character
        : _gameState.whitePlayerState.character;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              _gameState.currentPlayer ==
                  PlayerType.black
              ? [
                  Colors.grey[800]!,
                  Colors.grey[600]!,
                ]
              : [
                  Colors.blue[700]!,
                  Colors.blue[500]!,
                ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons.circle,
            color:
                _gameState.currentPlayer ==
                    PlayerType.black
                ? Colors.white
                : Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '${_gameState.currentPlayer == PlayerType.black ? "흑돌" : "백돌"}의 차례',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (currentCharacter != null) ...[
            const SizedBox(width: 8),
            Icon(
              _getCharacterIcon(
                currentCharacter.type,
              ),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              currentCharacter.koreanName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayersInfo() {
    return Row(
      children: [
        // 흑돌 플레이어
        Expanded(
          child: _buildPlayerCard(
            PlayerType.black,
            _gameState.blackPlayerState,
            _gameState.currentPlayer ==
                PlayerType.black,
          ),
        ),

        const SizedBox(width: 12),

        // 게임 정보
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(
              alpha: 0.2,
            ),
            borderRadius: BorderRadius.circular(
              12,
            ),
            border: Border.all(
              color: Colors.purple,
            ),
          ),
          child: Column(
            children: [
              Text(
                '${_gameState.turnCount}수',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'TURN',
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // 백돌 플레이어
        Expanded(
          child: _buildPlayerCard(
            PlayerType.white,
            _gameState.whitePlayerState,
            _gameState.currentPlayer ==
                PlayerType.white,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerCard(
    PlayerType playerType,
    PlayerGameState playerState,
    bool isCurrentTurn,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isCurrentTurn
            ? (playerType == PlayerType.black
                      ? Colors.orange
                      : Colors.blue)
                  .withValues(alpha: 0.3)
            : Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentTurn
              ? (playerType == PlayerType.black
                    ? Colors.orange
                    : Colors.blue)
              : Colors.grey,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // 플레이어 이름 & 돌
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                Icons.circle,
                color:
                    playerType == PlayerType.black
                    ? Colors.grey[600]
                    : Colors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                playerType == PlayerType.black
                    ? '흑돌'
                    : '백돌',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // 시간
          Text(
            _formatTime(
              playerState.timeRemaining,
            ),
            style: TextStyle(
              color: isCurrentTurn
                  ? (playerType ==
                            PlayerType.black
                        ? Colors.orange
                        : Colors.blue)
                  : Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          // 캐릭터 정보
          if (playerState.character != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Icon(
                  _getCharacterIcon(
                    playerState.character!.type,
                  ),
                  color: playerState
                      .character!
                      .tierColor,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    playerState
                        .character!
                        .koreanName,
                    style: TextStyle(
                      color: playerState
                          .character!
                          .tierColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow:
                        TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildGameControls() {
    return Column(
      children: [
        // 두 플레이어 스킬 정보 (항상 양쪽 모두 표시)
        _buildBothPlayersSkillInfo(),

        const SizedBox(height: 12),

        // 게임 컨트롤 버튼들 (무르기만)
        _buildBasicGameControls(),
      ],
    );
  }

  Widget _buildBothPlayersSkillInfo() {
    return Row(
      children: [
        // 흑돌 플레이어 스킬
        Expanded(
          child: _buildPlayerSkillCard(
            PlayerType.black,
            _gameState.blackPlayerState,
            _gameState.currentPlayer ==
                PlayerType.black,
          ),
        ),

        const SizedBox(width: 12),

        // 백돌 플레이어 스킬
        Expanded(
          child: _buildPlayerSkillCard(
            PlayerType.white,
            _gameState.whitePlayerState,
            _gameState.currentPlayer ==
                PlayerType.white,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerSkillCard(
    PlayerType playerType,
    PlayerGameState playerState,
    bool isCurrentTurn,
  ) {
    final character = playerState.character;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: character != null
              ? [
                  character.tierColor.withValues(
                    alpha: isCurrentTurn
                        ? 0.4
                        : 0.2,
                  ),
                  character.tierColor.withValues(
                    alpha: isCurrentTurn
                        ? 0.2
                        : 0.1,
                  ),
                ]
              : [
                  Colors.grey.withValues(
                    alpha: 0.2,
                  ),
                  Colors.grey.withValues(
                    alpha: 0.1,
                  ),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentTurn
              ? (character?.tierColor ??
                    Colors.orange)
              : Colors.grey,
          width: isCurrentTurn ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          // 플레이어 헤더
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                Icons.circle,
                color:
                    playerType == PlayerType.black
                    ? Colors.grey[600]
                    : Colors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                playerType == PlayerType.black
                    ? '흑돌'
                    : '백돌',
                style: TextStyle(
                  color: isCurrentTurn
                      ? Colors.white
                      : Colors.grey[400],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isCurrentTurn) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.play_arrow,
                  color: Colors.amber,
                  size: 16,
                ),
              ],
            ],
          ),

          const SizedBox(height: 6),

          // 캐릭터 정보
          if (character != null) ...[
            Icon(
              _getCharacterIcon(character.type),
              color: character.tierColor,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              character.koreanName,
              style: TextStyle(
                color: character.tierColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            // 스킬 정보 (간소화, 터치 시 상세 정보)
            GestureDetector(
              onTap: () => _showSkillDetailDialog(
                character,
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(
                        alpha: 0.8,
                      ),
                      Colors.black.withValues(
                        alpha: 0.6,
                      ),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      BorderRadius.circular(8),
                  border: Border.all(
                    color: _getSkillTypeColor(
                      character.skill.type,
                    ).withValues(alpha: 0.7),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getSkillTypeColor(
                        character.skill.type,
                      ).withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getSkillIcon(
                        character.skill.type,
                      ),
                      color: _getSkillTypeColor(
                        character.skill.type,
                      ),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        character.skill.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight:
                              FontWeight.bold,
                          shadows: [
                            Shadow(
                              color:
                                  _getSkillTypeColor(
                                    character
                                        .skill
                                        .type,
                                  ).withValues(
                                    alpha: 0.8,
                                  ),
                              blurRadius: 4,
                              offset: Offset(
                                0,
                                0,
                              ),
                            ),
                          ],
                        ),
                        textAlign:
                            TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            // 스킬 상태
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: playerState.skillUsed
                    ? Colors.grey
                    : character.tierColor,
                borderRadius:
                    BorderRadius.circular(8),
              ),
              child: Text(
                playerState.skillUsed
                    ? '사용됨'
                    : '사용가능',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ] else ...[
            const Icon(
              Icons.person_outline,
              color: Colors.grey,
              size: 20,
            ),
            const SizedBox(height: 4),
            const Text(
              '캐릭터 없음',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBasicGameControls() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🎯 새로운 무르기 버튼 (Android RelativeLayout 스타일)
          Container(
            width: 161,
            height: 48,
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(
                8,
              ),
              color: _gameState.moves.isNotEmpty
                  ? Colors.orange.shade600
                  : Colors.grey.shade500,
              child: InkWell(
                borderRadius:
                    BorderRadius.circular(8),
                onTap: _gameState.moves.isNotEmpty
                    ? _requestUndo
                    : null,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          _gameState
                              .moves
                              .isNotEmpty
                          ? Colors.orange.shade700
                          : Colors.grey.shade600,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.undo,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '무르기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w600,
                          fontFamily: 'SUIT',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 🎯 새로운 기권 버튼 (Android RelativeLayout 스타일)
          Container(
            width: 161,
            height: 48,
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(
                8,
              ),
              color: Colors.red.shade800,
              child: InkWell(
                borderRadius:
                    BorderRadius.circular(8),
                onTap: _showSurrenderDialog,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.shade900,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.block,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '기권',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w600,
                          fontFamily: 'SUIT',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPlayerControls() {
    final currentCharacter =
        _gameState.currentPlayer ==
            PlayerType.black
        ? _gameState.blackPlayerState.character
        : _gameState.whitePlayerState.character;

    return Column(
      children: [
        // 강력한 스킬 사용 버튼 (현재 플레이어만)
        if (currentCharacter != null) ...[
          Container(
            width: double.infinity,
            height: 80,
            margin: const EdgeInsets.only(
              bottom: 16,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _canUseSkill()
                    ? [
                        currentCharacter.tierColor
                            .withValues(
                              alpha: 0.8,
                            ),
                        currentCharacter
                            .tierColor,
                        currentCharacter.tierColor
                            .withValues(
                              alpha: 0.9,
                            ),
                      ]
                    : [
                        Colors.grey.withValues(
                          alpha: 0.3,
                        ),
                        Colors.grey.withValues(
                          alpha: 0.5,
                        ),
                        Colors.grey.withValues(
                          alpha: 0.4,
                        ),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(
                20,
              ),
              boxShadow: _canUseSkill()
                  ? [
                      BoxShadow(
                        color: currentCharacter
                            .tierColor
                            .withValues(
                              alpha: 0.5,
                            ),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(
                          0,
                          5,
                        ),
                      ),
                      BoxShadow(
                        color: currentCharacter
                            .tierColor
                            .withValues(
                              alpha: 0.3,
                            ),
                        blurRadius: 25,
                        spreadRadius: 5,
                        offset: const Offset(
                          0,
                          10,
                        ),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black
                            .withValues(
                              alpha: 0.2,
                            ),
                        blurRadius: 8,
                        offset: const Offset(
                          0,
                          3,
                        ),
                      ),
                    ],
              border: Border.all(
                color: _canUseSkill()
                    ? Colors.white.withValues(
                        alpha: 0.5,
                      )
                    : Colors.grey.withValues(
                        alpha: 0.3,
                      ),
                width: 2,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _canUseSkill()
                    ? _useCharacterSkill
                    : null,
                borderRadius:
                    BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(
                    16,
                  ),
                  child: Row(
                    children: [
                      // 스킬 아이콘
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white
                              .withValues(
                                alpha: 0.2,
                              ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white
                                .withValues(
                                  alpha: 0.5,
                                ),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _getSkillIcon(
                            currentCharacter
                                .skill
                                .type,
                          ),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // 스킬 정보
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            Text(
                              '⚡ ${currentCharacter.skill.name}',
                              style:
                                  const TextStyle(
                                    color: Colors
                                        .white,
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                              decoration: BoxDecoration(
                                color: Colors
                                    .white
                                    .withValues(
                                      alpha: 0.2,
                                    ),
                                borderRadius:
                                    BorderRadius.circular(
                                      6,
                                    ),
                              ),
                              child: const Text(
                                '💫 Ready 💫',
                                style: TextStyle(
                                  color: Colors
                                      .white,
                                  fontSize: 10,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 사용 상태 표시
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                        decoration: BoxDecoration(
                          color: _canUseSkill()
                              ? Colors.white
                                    .withValues(
                                      alpha: 0.2,
                                    )
                              : Colors.grey
                                    .withValues(
                                      alpha: 0.3,
                                    ),
                          borderRadius:
                              BorderRadius.circular(
                                12,
                              ),
                        ),
                        child: Text(
                          _canUseSkill()
                              ? 'READY'
                              : 'USED',
                          style: TextStyle(
                            color: _canUseSkill()
                                ? Colors.white
                                : Colors
                                      .grey[400],
                            fontSize: 12,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],

        // 게임 컨트롤 버튼들 (작게)
        Row(
          children: [
            // 🎯 새로운 무르기 요청 버튼 (Android RelativeLayout 스타일)
            Container(
              width: 120,
              height: 48,
              child: Material(
                elevation: 2,
                borderRadius:
                    BorderRadius.circular(8),
                color: _isPendingUndoRequest
                    ? Colors.grey.shade500
                    : (_gameState.moves.length > 1
                          ? Colors.orange.shade600
                          : Colors.grey.shade500),
                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(8),
                  onTap:
                      _gameState.moves.length >
                              1 &&
                          !_isPendingUndoRequest
                      ? _requestUndo
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(
                            8,
                          ),
                      border: Border.all(
                        color:
                            _isPendingUndoRequest
                            ? Colors.grey.shade600
                            : (_gameState
                                          .moves
                                          .length >
                                      1
                                  ? Colors
                                        .orange
                                        .shade700
                                  : Colors
                                        .grey
                                        .shade600),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        Icon(
                          _isPendingUndoRequest
                              ? Icons
                                    .hourglass_empty
                              : Icons.undo,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isPendingUndoRequest
                              ? '대기중...'
                              : '무르기',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w600,
                            fontFamily: 'SUIT',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // 🎯 새로운 항복 버튼 (Android RelativeLayout 스타일)
            Container(
              width: 161,
              height: 48,
              child: Material(
                elevation: 2,
                borderRadius:
                    BorderRadius.circular(8),
                color: Colors.red.shade600,
                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(8),
                  onTap: () =>
                      _showSurrenderDialog(),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(
                            8,
                          ),
                      border: Border.all(
                        color:
                            Colors.red.shade700,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        Icon(
                          Icons.flag,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '항복',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w600,
                            fontFamily: 'SUIT',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _canUseSkill() {
    final currentCharacter =
        _gameState.currentPlayer ==
            PlayerType.black
        ? _gameState.blackPlayerState.character
        : _gameState.whitePlayerState.character;

    final skillUsed =
        _gameState.currentPlayer ==
            PlayerType.black
        ? _gameState.blackPlayerState.skillUsed
        : _gameState.whitePlayerState.skillUsed;

    return currentCharacter != null &&
        !skillUsed &&
        _gameState.turnCount >= 3;
  }

  void _useCharacterSkill() {
    final currentCharacter =
        _gameState.currentPlayer ==
            PlayerType.black
        ? _gameState.blackPlayerState.character
        : _gameState.whitePlayerState.character;

    if (currentCharacter != null &&
        _canUseSkill()) {
      // 강력한 햅틱 피드백
      HapticFeedback.heavyImpact();

      // 스킬 사용 상태 업데이트
      setState(() {
        if (_gameState.currentPlayer ==
            PlayerType.black) {
          _gameState = _gameState.copyWith(
            blackPlayerState: _gameState
                .blackPlayerState
                .copyWith(skillUsed: true),
          );
        } else {
          _gameState = _gameState.copyWith(
            whitePlayerState: _gameState
                .whitePlayerState
                .copyWith(skillUsed: true),
          );
        }
      });

      // 스킬 효과 적용
      _applySkillEffect(currentCharacter);

      // 강력한 스킬 사용 애니메이션
      _showMegaSkillEffect(currentCharacter);
    }
  }

  void _showMegaSkillEffect(Character character) {
    // 강력한 햅틱 피드백만
    HapticFeedback.heavyImpact();

    // 순수한 시각적 임팩트만 - 2초간 풀스크린 이펙트
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(
        alpha: 0.9,
      ),
      builder: (context) {
        // 2초 후 자동 닫기
        Future.delayed(
          const Duration(milliseconds: 2000),
          () {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
          },
        );

        return Center(
          child: Container(
            width: 200,
            height: 200,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(
                milliseconds: 1500,
              ),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // 외부 확산 이펙트
                    Transform.scale(
                      scale: value * 3,
                      child: Opacity(
                        opacity: 1.0 - value,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration:
                              BoxDecoration(
                                shape: BoxShape
                                    .circle,
                                border: Border.all(
                                  color: character
                                      .tierColor,
                                  width: 3,
                                ),
                              ),
                        ),
                      ),
                    ),
                    // 중앙 캐릭터 아이콘
                    Transform.scale(
                      scale: 0.5 + (value * 1.5),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient:
                              RadialGradient(
                                colors: [
                                  character
                                      .tierColor,
                                  character
                                      .tierColor
                                      .withValues(
                                        alpha:
                                            0.3,
                                      ),
                                ],
                              ),
                        ),
                        child: Icon(
                          _getCharacterIcon(
                            character.type,
                          ),
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    ).then((_) {
      // 다이얼로그 닫힌 후 가벼운 햅틱
      HapticFeedback.lightImpact();
    });
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          '⏸️ 게임 일시정지',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '게임을 어떻게 하시겠습니까?',
              style: TextStyle(
                color: Colors.white.withOpacity(
                  0.8,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(),
            child: Text(
              '계속하기',
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              '게임 종료',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          '⚙️ 게임 설정',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '게임 설정을 조정할 수 있습니다.',
              style: TextStyle(
                color: Colors.white.withOpacity(
                  0.8,
                ),
              ),
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text(
                '사운드 효과',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              value: true,
              onChanged: (value) {},
              activeColor: Colors.blue,
            ),
            SwitchListTile(
              title: Text(
                '배경 음악',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              value: true,
              onChanged: (value) {},
              activeColor: Colors.blue,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(),
            child: Text(
              '확인',
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _stoneAnimationController.dispose();
    _gameTimer?.cancel();
    _turnTimer?.cancel();
    _soundManager.stopBackgroundMusic();
    super.dispose();
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

  void _startTurnTimer() {
    _turnTimer?.cancel();
    _turnTimeRemaining = 30;
    _turnTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_gameState.status ==
                GameStatus.playing &&
            !_gameState.isPaused) {
          setState(() {
            _turnTimeRemaining--;

            // 총 시간도 함께 감소
            if (_gameState.currentPlayer ==
                PlayerType.black) {
              _blackTotalTime = math.max(
                0,
                _blackTotalTime - 1,
              );
              _gameState = _gameState.copyWith(
                blackPlayerState: _gameState
                    .blackPlayerState
                    .copyWith(
                      timeRemaining:
                          _blackTotalTime,
                    ),
              );

              // 총 시간 초과 체크
              if (_blackTotalTime <= 0) {
                _handleTurnTimeUp();
                return;
              }
            } else {
              _whiteTotalTime = math.max(
                0,
                _whiteTotalTime - 1,
              );
              _gameState = _gameState.copyWith(
                whitePlayerState: _gameState
                    .whitePlayerState
                    .copyWith(
                      timeRemaining:
                          _whiteTotalTime,
                    ),
              );

              // 총 시간 초과 체크
              if (_whiteTotalTime <= 0) {
                _handleTurnTimeUp();
                return;
              }
            }

            // 1수 시간 초과 체크
            if (_turnTimeRemaining <= 0) {
              _handleTurnTimeUp();
            }
          });
        }
      },
    );
  }

  void _handleTurnTimeUp() {
    // 30초 시간 초과시 현재 플레이어 패배
    _gameTimer?.cancel();
    _turnTimer?.cancel();

    setState(() {
      _gameState = _gameState.copyWith(
        status:
            _gameState.currentPlayer ==
                PlayerType.black
            ? GameStatus
                  .whiteWin // 흑돌 시간 초과 -> 백돌 승리
            : GameStatus
                  .blackWin, // 백돌 시간 초과 -> 흑돌 승리
      );
    });

    // 시간 초과 패배 메시지
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_gameState.currentPlayer == PlayerType.black ? "흑돌" : "백돌"} 시간 초과! ${_gameState.currentPlayer == PlayerType.black ? "백돌" : "흑돌"} 승리!',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );

    _showGameResult();
  }

  void _applySkillEffect(Character character) {
    // 스킬 타입별 효과 적용
    switch (character.skill.type) {
      case SkillType.offensive:
        // 공격형: 상대방 시간 감소
        setState(() {
          if (_gameState.currentPlayer ==
              PlayerType.black) {
            _whiteTotalTime = math.max(
              0,
              _whiteTotalTime - 30,
            );
            _gameState = _gameState.copyWith(
              whitePlayerState: _gameState
                  .whitePlayerState
                  .copyWith(
                    timeRemaining:
                        _whiteTotalTime,
                  ),
            );
          } else {
            _blackTotalTime = math.max(
              0,
              _blackTotalTime - 30,
            );
            _gameState = _gameState.copyWith(
              blackPlayerState: _gameState
                  .blackPlayerState
                  .copyWith(
                    timeRemaining:
                        _blackTotalTime,
                  ),
            );
          }
        });
        break;
      case SkillType.defensive:
        // 수비형: 자신의 시간 증가
        setState(() {
          if (_gameState.currentPlayer ==
              PlayerType.black) {
            _blackTotalTime += 60;
            _gameState = _gameState.copyWith(
              blackPlayerState: _gameState
                  .blackPlayerState
                  .copyWith(
                    timeRemaining:
                        _blackTotalTime,
                  ),
            );
          } else {
            _whiteTotalTime += 60;
            _gameState = _gameState.copyWith(
              whitePlayerState: _gameState
                  .whitePlayerState
                  .copyWith(
                    timeRemaining:
                        _whiteTotalTime,
                  ),
            );
          }
        });
        break;
      case SkillType.disruptive:
        // 교란형: 마지막 수 표시 제거
        setState(() {
          _gameState = _gameState.copyWith(
            lastMove: null,
          );
        });
        break;
      case SkillType.timeControl:
        // 시간 조작: 양쪽 시간 조정
        setState(() {
          _blackTotalTime += 30;
          _whiteTotalTime += 30;
          _gameState = _gameState.copyWith(
            blackPlayerState: _gameState
                .blackPlayerState
                .copyWith(
                  timeRemaining: _blackTotalTime,
                ),
            whitePlayerState: _gameState
                .whitePlayerState
                .copyWith(
                  timeRemaining: _whiteTotalTime,
                ),
          );
        });
        break;
    }
  }

  IconData _getSkillIcon(SkillType type) {
    switch (type) {
      case SkillType.offensive:
        return Icons.flash_on;
      case SkillType.defensive:
        return Icons.shield;
      case SkillType.disruptive:
        return Icons.psychology;
      case SkillType.timeControl:
        return Icons.access_time;
    }
  }

  Color _getSkillTypeColor(SkillType type) {
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

  String _getSkillTypeName(SkillType type) {
    switch (type) {
      case SkillType.offensive:
        return '공격형';
      case SkillType.defensive:
        return '수비형';
      case SkillType.disruptive:
        return '교란형';
      case SkillType.timeControl:
        return '시간조작';
    }
  }

  String _getSkillEffect(SkillType type) {
    switch (type) {
      case SkillType.offensive:
        return '상대방 시간 30초 감소';
      case SkillType.defensive:
        return '자신의 시간 60초 증가';
      case SkillType.disruptive:
        return '마지막 수 위치 숨김';
      case SkillType.timeControl:
        return '양쪽 시간 30초씩 증가';
    }
  }

  void _requestUndo() {
    setState(() {
      _isPendingUndoRequest = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.undo,
              color: Colors.orange,
            ),
            const SizedBox(width: 8),
            const Text('무르기 요청'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_gameState.currentPlayer == PlayerType.black ? "흑돌" : "백돌"} 플레이어가 무르기를 요청했습니다.',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '상대방이 허락해야 무를 수 있습니다.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _isPendingUndoRequest = false;
              });
              Navigator.pop(context);
            },
            child: const Text(
              '거절',
              style: TextStyle(color: Colors.red),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isPendingUndoRequest = false;
              });
              Navigator.pop(context);
              _executeUndo();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text(
              '허락',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _executeUndo() {
    if (_gameState.moves.length > 1) {
      setState(() {
        final newMoves = List<Position>.from(
          _gameState.moves,
        );
        final lastMove = newMoves.removeLast();

        final newBoard = _gameState.board
            .map(
              (row) =>
                  List<PlayerType?>.from(row),
            )
            .toList();
        newBoard[lastMove.row][lastMove.col] =
            null;

        _gameState = _gameState.copyWith(
          board: newBoard,
          moves: newMoves,
          currentPlayer:
              _gameState.currentPlayer ==
                  PlayerType.black
              ? PlayerType.white
              : PlayerType.black,
          turnCount: _gameState.turnCount - 1,
          lastMove: newMoves.isNotEmpty
              ? newMoves.last
              : null,
        );

        // 턴 타이머 재시작
        _startTurnTimer();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('무르기가 실행되었습니다.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSurrenderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('게임 포기'),
        content: Text(
          '${_gameState.currentPlayer == PlayerType.black ? "흑돌" : "백돌"} 플레이어가 게임을 포기하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text('계속하기'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('포기하기'),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallSkillButtons(
    double boardSize,
  ) {
    return Positioned(
      top: 20, // 위쪽으로 이동
      left: 10,
      child: Column(
        children: [
          // 흑돌 플레이어 스킬 버튼
          if (_gameState
                  .blackPlayerState
                  .character !=
              null)
            _buildSmallSkillButton(
              _gameState.blackPlayerState,
              PlayerType.black,
            ),

          const SizedBox(height: 8),

          // 백돌 플레이어 스킬 버튼
          if (_gameState
                  .whitePlayerState
                  .character !=
              null)
            _buildSmallSkillButton(
              _gameState.whitePlayerState,
              PlayerType.white,
            ),
        ],
      ),
    );
  }

  Widget _buildSmallSkillButton(
    PlayerGameState playerState,
    PlayerType playerType,
  ) {
    final character = playerState.character!;
    final isCurrentPlayer =
        _gameState.currentPlayer == playerType;
    final canUse =
        isCurrentPlayer &&
        !playerState.skillUsed &&
        _gameState.status == GameStatus.playing;

    return GestureDetector(
      onTap: canUse ? () => _useSkill() : null,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: canUse
                ? [
                    character.tierColor
                        .withValues(alpha: 0.9),
                    character.tierColor
                        .withValues(alpha: 0.7),
                  ]
                : [
                    Colors.grey.withValues(
                      alpha: 0.5,
                    ),
                    Colors.grey.withValues(
                      alpha: 0.3,
                    ),
                  ],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isCurrentPlayer
                ? Colors.white
                : Colors.grey,
            width: isCurrentPlayer ? 2 : 1,
          ),
          boxShadow: canUse
              ? [
                  BoxShadow(
                    color: character.tierColor
                        .withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              _getSkillIcon(character.skill.type),
              color: canUse
                  ? Colors.white
                  : Colors.grey[400],
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              playerState.skillUsed
                  ? '사용됨'
                  : '스킬',
              style: TextStyle(
                color: canUse
                    ? Colors.white
                    : Colors.grey[400],
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarTimer(
    PlayerType playerType,
    int timeRemaining,
    bool isCurrentTurn,
  ) {
    final minutes = timeRemaining ~/ 60;
    final seconds = timeRemaining % 60;
    final isBlack =
        playerType == PlayerType.black;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isCurrentTurn
            ? (isBlack
                  ? Colors.grey[800]
                  : Colors.blue[700])
            : Colors.grey[600],
        borderRadius: BorderRadius.circular(12),
        border: isCurrentTurn
            ? Border.all(
                color: Colors.yellow,
                width: 2,
              )
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                Icons.circle,
                color: isBlack
                    ? Colors.white
                    : Colors.white,
                size: 12,
              ),
              const SizedBox(width: 4),
              Text(
                isBlack ? '흑돌' : '백돌',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: timeRemaining <= 30
                  ? Colors.red[300]
                  : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showSkillDetailDialog(
    Character character,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(
        alpha: 0.8,
      ),
      builder: (context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: GestureDetector(
              onTap: () {}, // 내부 탭은 전파 방지
              child: AlertDialog(
                backgroundColor: Colors.black
                    .withValues(alpha: 0.9),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(20),
                  side: BorderSide(
                    color: character.tierColor
                        .withValues(alpha: 0.8),
                    width: 2,
                  ),
                ),
                title: Row(
                  children: [
                    Icon(
                      _getCharacterIcon(
                        character.type,
                      ),
                      color: character.tierColor,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      character.koreanName,
                      style: TextStyle(
                        color:
                            character.tierColor,
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // 티어 정보
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                      decoration: BoxDecoration(
                        color:
                            character.tierColor,
                        borderRadius:
                            BorderRadius.circular(
                              12,
                            ),
                      ),
                      child: Text(
                        character.tierName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 스킬 정보
                    Container(
                      padding:
                          const EdgeInsets.all(
                            16,
                          ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getSkillTypeColor(
                              character
                                  .skill
                                  .type,
                            ).withValues(
                              alpha: 0.3,
                            ),
                            _getSkillTypeColor(
                              character
                                  .skill
                                  .type,
                            ).withValues(
                              alpha: 0.1,
                            ),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(
                              12,
                            ),
                        border: Border.all(
                          color:
                              _getSkillTypeColor(
                                character
                                    .skill
                                    .type,
                              ),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getSkillIcon(
                                  character
                                      .skill
                                      .type,
                                ),
                                color:
                                    _getSkillTypeColor(
                                      character
                                          .skill
                                          .type,
                                    ),
                                size: 24,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                character
                                    .skill
                                    .name,
                                style: TextStyle(
                                  color:
                                      _getSkillTypeColor(
                                        character
                                            .skill
                                            .type,
                                      ),
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Text(
                            '종류: ${_getSkillTypeName(character.skill.type)}',
                            style:
                                const TextStyle(
                                  color: Colors
                                      .white70,
                                  fontSize: 14,
                                ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                            decoration: BoxDecoration(
                              color: Colors
                                  .amber[300]!
                                  .withValues(
                                    alpha: 0.2,
                                  ),
                              borderRadius:
                                  BorderRadius.circular(
                                    8,
                                  ),
                            ),
                            child: const Text(
                              '⚡ 스킬 사용 가능 ⚡',
                              style: TextStyle(
                                color:
                                    Colors.white,
                                fontSize: 12,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Text(
                            character
                                .skill
                                .description,
                            style:
                                const TextStyle(
                                  color: Colors
                                      .white,
                                  fontSize: 14,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(),
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopPlayerInfo() {
    return Container(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF667EEA),
            const Color(0xFF764BA2),
            const Color(
              0xFF764BA2,
            ).withValues(alpha: 0.8),
            const Color(
              0xFF764BA2,
            ).withValues(alpha: 0.0),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF667EEA,
            ).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // 상단 컨트롤 바
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              _buildGlassButton(
                icon: Icons.arrow_back_ios_new,
                onPressed: () =>
                    _showPauseDialog(),
              ),

              // 수 번호 디스플레이
              Container(
                padding:
                    const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(
                        alpha: 0.25,
                      ),
                      Colors.white.withValues(
                        alpha: 0.15,
                      ),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white
                        .withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sports_esports,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_gameState.turnCount}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight:
                            FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'SUIT',
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '수',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'SUIT',
                      ),
                    ),
                  ],
                ),
              ),

              _buildGlassButton(
                icon: Icons.tune,
                onPressed: () =>
                    _showSettingsDialog(),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 플레이어 타이머 카드들
          Row(
            children: [
              Expanded(
                child: _buildEnhancedPlayerCard(
                  _gameState.blackPlayerState,
                  true,
                  _gameState.currentPlayer ==
                      PlayerType.black,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEnhancedPlayerCard(
                  _gameState.whitePlayerState,
                  false,
                  _gameState.currentPlayer ==
                      PlayerType.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 턴 인디케이터
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(
                    alpha: 0.2,
                  ),
                  Colors.white.withValues(
                    alpha: 0.1,
                  ),
                ],
              ),
              borderRadius: BorderRadius.circular(
                25,
              ),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.3,
                ),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color:
                        _gameState
                                .currentPlayer ==
                            PlayerType.black
                        ? Colors.black
                        : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          _gameState
                                  .currentPlayer ==
                              PlayerType.black
                          ? Colors.white
                          : Colors.black,
                      width: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _gameState.currentPlayer ==
                          PlayerType.black
                      ? '흑돌의 차례'
                      : '백돌의 차례',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SUIT',
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 유리 효과 버튼
  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.25),
            Colors.white.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.3,
          ),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.1,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  // 향상된 플레이어 카드
  Widget _buildEnhancedPlayerCard(
    PlayerGameState playerState,
    bool isBlack,
    bool isCurrentTurn,
  ) {
    final timeRemaining = isBlack
        ? _blackTotalTime
        : _whiteTotalTime;
    final minutes = timeRemaining ~/ 60;
    final seconds = timeRemaining % 60;
    final isLowTime = timeRemaining <= 30;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCurrentTurn
              ? [
                  Colors.white.withValues(
                    alpha: 0.3,
                  ),
                  Colors.white.withValues(
                    alpha: 0.15,
                  ),
                ]
              : [
                  Colors.white.withValues(
                    alpha: 0.15,
                  ),
                  Colors.white.withValues(
                    alpha: 0.05,
                  ),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrentTurn
              ? Colors.white.withValues(
                  alpha: 0.5,
                )
              : Colors.white.withValues(
                  alpha: 0.2,
                ),
          width: 2,
        ),
        boxShadow: isCurrentTurn
            ? [
                BoxShadow(
                  color: Colors.white.withValues(
                    alpha: 0.3,
                  ),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          // 플레이어 타입과 아이콘
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isBlack
                      ? Colors.black
                      : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isBlack
                        ? Colors.white
                        : Colors.black,
                    width: 1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isBlack ? '흑돌' : '백돌',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SUIT',
                ),
              ),
              if (isCurrentTurn) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.all(
                    2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // 시간 표시
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isLowTime
                  ? Colors.red.withValues(
                      alpha: 0.3,
                    )
                  : Colors.white.withValues(
                      alpha: 0.2,
                    ),
              borderRadius: BorderRadius.circular(
                12,
              ),
              border: Border.all(
                color: isLowTime
                    ? Colors.red.withValues(
                        alpha: 0.5,
                      )
                    : Colors.white.withValues(
                        alpha: 0.3,
                      ),
                width: 1,
              ),
            ),
            child: Text(
              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: isLowTime
                    ? Colors.red[100]
                    : Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'SUIT',
                shadows: const [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 1),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ),

          // 캐릭터 정보 (있는 경우)
          if (playerState.character != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: playerState
                    .character!
                    .tierColor
                    .withValues(alpha: 0.3),
                borderRadius:
                    BorderRadius.circular(10),
                border: Border.all(
                  color: playerState
                      .character!
                      .tierColor
                      .withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Icon(
                _getCharacterIcon(
                  playerState.character!.type,
                ),
                color: playerState
                    .character!
                    .tierColor,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomSkillInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[900]!.withValues(
          alpha: 0.8,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[600]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 흑돌 스킬 정보
          if (_gameState
                  .blackPlayerState
                  .character !=
              null)
            Expanded(
              child: _buildQuickSkillInfo(
                _gameState.blackPlayerState,
                PlayerType.black,
              ),
            ),

          if (_gameState
                      .blackPlayerState
                      .character !=
                  null &&
              _gameState
                      .whitePlayerState
                      .character !=
                  null)
            Container(
              width: 1,
              height: 30,
              color: Colors.grey[600],
              margin: const EdgeInsets.symmetric(
                horizontal: 8,
              ),
            ),

          // 백돌 스킬 정보
          if (_gameState
                  .whitePlayerState
                  .character !=
              null)
            Expanded(
              child: _buildQuickSkillInfo(
                _gameState.whitePlayerState,
                PlayerType.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickSkillInfo(
    PlayerGameState playerState,
    PlayerType playerType,
  ) {
    final character = playerState.character!;
    final isCurrentTurn =
        _gameState.currentPlayer == playerType;

    return GestureDetector(
      onTap: () =>
          _showSkillDetailDialog(character),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: isCurrentTurn
              ? character.tierColor.withValues(
                  alpha: 0.3,
                )
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.circle,
              color:
                  playerType == PlayerType.black
                  ? Colors.grey[400]
                  : Colors.white,
              size: 12,
            ),
            const SizedBox(width: 4),
            Text(
              playerType == PlayerType.black
                  ? '흑돌'
                  : '백돌',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              _getSkillIcon(character.skill.type),
              color: _getSkillTypeColor(
                character.skill.type,
              ),
              size: 14,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                character.skill.name,
                style: TextStyle(
                  color: _getSkillTypeColor(
                    character.skill.type,
                  ),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 2),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: playerState.skillUsed
                    ? Colors.grey
                    : character.tierColor,
                borderRadius:
                    BorderRadius.circular(6),
              ),
              child: Text(
                playerState.skillUsed
                    ? '사용됨'
                    : '준비',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerTimer(
    PlayerType playerType,
    int timeRemaining,
  ) {
    final isCurrentTurn =
        _gameState.currentPlayer == playerType;
    final isBlack =
        playerType == PlayerType.black;
    final minutes = timeRemaining ~/ 60;
    final seconds = timeRemaining % 60;
    final playerState = isBlack
        ? _gameState.blackPlayerState
        : _gameState.whitePlayerState;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCurrentTurn
              ? [
                  const Color(0xFF89E0F7),
                  const Color(0xFF51D4EB),
                ]
              : [
                  const Color(
                    0xFFF4FEFF,
                  ).withValues(alpha: 0.7),
                  const Color(
                    0xFFFAF9FB,
                  ).withValues(alpha: 0.7),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: isCurrentTurn
            ? Border.all(
                color: const Color(0xFF5C47CE),
                width: 2,
              )
            : Border.all(
                color: const Color(
                  0xFF51D4EB,
                ).withValues(alpha: 0.5),
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color: isCurrentTurn
                ? const Color(
                    0xFF51D4EB,
                  ).withValues(alpha: 0.3)
                : Colors.white.withValues(
                    alpha: 0.5,
                  ),
            blurRadius: isCurrentTurn ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          // 플레이어 정보
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle,
                    color: isBlack
                        ? Colors.black
                        : Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isBlack ? '흑돌' : '백돌',
                    style: const TextStyle(
                      color: Color(0xFF5C47CE),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SUIT',
                    ),
                  ),
                  if (isCurrentTurn) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.play_arrow,
                      color: const Color(
                        0xFF5C47CE,
                      ),
                      size: 14,
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 4),

              // 시간 표시
              Text(
                '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: timeRemaining <= 30
                      ? Colors.red[600]
                      : const Color(0xFF5C47CE),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SUIT',
                ),
              ),
            ],
          ),

          if (playerState.character != null) ...[
            const SizedBox(width: 12),
            // 캐릭터 아이콘
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: playerState
                    .character!
                    .tierColor
                    .withValues(alpha: 0.3),
                borderRadius:
                    BorderRadius.circular(8),
              ),
              child: Icon(
                _getCharacterIcon(
                  playerState.character!.type,
                ),
                color: playerState
                    .character!
                    .tierColor,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomSkillSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(
              0xFFF4FEFF,
            ).withValues(alpha: 0.95),
            const Color(
              0xFFDFFBFF,
            ).withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF51D4EB),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(
              alpha: 0.8,
            ),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 스킬 버튼들
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              // 흑돌 스킬 버튼
              if (_gameState
                      .blackPlayerState
                      .character !=
                  null)
                _buildBottomSkillButton(
                  _gameState.blackPlayerState,
                  PlayerType.black,
                ),

              if (_gameState
                          .blackPlayerState
                          .character !=
                      null &&
                  _gameState
                          .whitePlayerState
                          .character !=
                      null)
                const SizedBox(width: 24),

              // 백돌 스킬 버튼
              if (_gameState
                      .whitePlayerState
                      .character !=
                  null)
                _buildBottomSkillButton(
                  _gameState.whitePlayerState,
                  PlayerType.white,
                ),
            ],
          ),

          const SizedBox(height: 12),

          // 스킬 정보
          _buildBottomSkillInfo(),
        ],
      ),
    );
  }

  Widget _buildBottomSkillButton(
    PlayerGameState playerState,
    PlayerType playerType,
  ) {
    final character = playerState.character!;
    final isCurrentPlayer =
        _gameState.currentPlayer == playerType;
    final canUse =
        isCurrentPlayer &&
        !playerState.skillUsed &&
        _gameState.status == GameStatus.playing;

    // 스킬 사용했으면 빈 컨테이너 반환 (버튼 사라짐)
    if (playerState.skillUsed) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: Colors.grey.withValues(
              alpha: 0.3,
            ),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              '✨사용완료✨',
              style: TextStyle(
                color: Colors.green,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: canUse
          ? () => _useSkillWithImpact(character)
          : null,
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 300,
        ),
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: canUse
                ? [
                    character.tierColor,
                    character.tierColor
                        .withValues(alpha: 0.8),
                    character.tierColor,
                  ]
                : [
                    Colors.grey.withValues(
                      alpha: 0.7,
                    ),
                    Colors.grey.withValues(
                      alpha: 0.5,
                    ),
                    Colors.grey.withValues(
                      alpha: 0.7,
                    ),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: canUse
                ? Colors.white
                : Colors.grey.withValues(
                    alpha: 0.6,
                  ),
            width: canUse ? 5 : 3,
          ),
          boxShadow: canUse
              ? [
                  BoxShadow(
                    color: character.tierColor
                        .withValues(alpha: 0.8),
                    blurRadius: 25,
                    spreadRadius: 6,
                  ),
                  BoxShadow(
                    color: Colors.white
                        .withValues(alpha: 0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: canUse
                  ? [
                      BoxShadow(
                        color: Colors.white
                            .withValues(
                              alpha: 0.8,
                            ),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: character.tierColor
                            .withValues(
                              alpha: 0.6,
                            ),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              _getSkillIcon(character.skill.type),
              color: canUse
                  ? Colors.white
                  : Colors.grey[500],
              size: 55,
              shadows: canUse
                  ? [
                      Shadow(
                        color: Colors.black
                            .withValues(
                              alpha: 0.8,
                            ),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                      Shadow(
                        color: character.tierColor
                            .withValues(
                              alpha: 0.9,
                            ),
                        blurRadius: 10,
                        offset: Offset(0, 0),
                      ),
                    ]
                  : [
                      Shadow(
                        color: Colors.black
                            .withValues(
                              alpha: 0.3,
                            ),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
            ),
          ),
        ),
      ),
    );
  }

  void _useSkillWithImpact(Character character) {
    // 강력한 임팩트 효과만
    HapticFeedback.heavyImpact();

    // 스킬 사용 로직
    _useSkill();
  }
}

// 스킬 이펙트 전용 다이얼로그
class _SkillEffectDialog extends StatefulWidget {
  final Character character;

  const _SkillEffectDialog({
    required this.character,
  });

  @override
  State<_SkillEffectDialog> createState() =>
      _SkillEffectDialogState();
}

class _SkillEffectDialogState
    extends State<_SkillEffectDialog>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(
        milliseconds: 2000,
      ),
      vsync: this,
    );

    _scaleAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(
              0.0,
              0.6,
              curve: Curves.elasticOut,
            ),
          ),
        );

    _rotationAnimation =
        Tween<double>(
          begin: 0.0,
          end: 2.0,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(
              0.0,
              0.8,
              curve: Curves.easeInOut,
            ),
          ),
        );

    _opacityAnimation =
        Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(
              0.7,
              1.0,
              curve: Curves.easeOut,
            ),
          ),
        );

    _controller.forward();

    // 2초 후 자동 닫기
    Future.delayed(
      const Duration(milliseconds: 2000),
      () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle:
                    _rotationAnimation.value *
                    3.14159,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        widget.character.tierColor
                            .withValues(
                              alpha: 0.9,
                            ),
                        widget.character.tierColor
                            .withValues(
                              alpha: 0.7,
                            ),
                        widget.character.tierColor
                            .withValues(
                              alpha: 0.3,
                            ),
                        Colors.transparent,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget
                            .character
                            .tierColor
                            .withValues(
                              alpha: 0.6,
                            ),
                        blurRadius: 50,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getSkillIcon(
                          widget
                              .character
                              .skill
                              .type,
                        ),
                        size: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget
                            .character
                            .skill
                            .name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight:
                              FontWeight.bold,
                        ),
                        textAlign:
                            TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                        decoration: BoxDecoration(
                          color: Colors.white
                              .withValues(
                                alpha: 0.2,
                              ),
                          borderRadius:
                              BorderRadius.circular(
                                12,
                              ),
                        ),
                        child: Text(
                          'ACTIVATED!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getSkillIcon(SkillType type) {
    switch (type) {
      case SkillType.offensive:
        return Icons.flash_on;
      case SkillType.defensive:
        return Icons.shield;
      case SkillType.disruptive:
        return Icons.psychology;
      case SkillType.timeControl:
        return Icons.access_time;
    }
  }
}
