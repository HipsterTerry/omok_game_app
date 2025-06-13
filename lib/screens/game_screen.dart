import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../logic/omok_game_logic.dart';
import '../logic/advanced_renju_rule_evaluator.dart';
import '../widgets/simple_renju_wrapper.dart';
import '../widgets/game_countdown_overlay.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() =>
      _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState _gameState;
  bool _showCountdown = true;
  bool _gameStarted = false;

  @override
  void initState() {
    super.initState();
    _gameState = GameState();
  }

  void _onTileTap(int row, int col) {
    // 카운트다운 중이거나 게임이 시작되지 않았으면 차단
    if (_showCountdown ||
        !_gameStarted ||
        _gameState.status != GameStatus.playing) {
      return;
    }

    setState(() {
      _gameState = OmokGameLogic.makeMove(
        _gameState,
        row,
        col,
      );
    });

    // 게임 종료 시 결과 표시
    if (_gameState.status != GameStatus.playing) {
      _showGameResult();
    }
  }

  void _onCountdownComplete() {
    setState(() {
      _showCountdown = false;
      _gameStarted = true;
    });
  }

  void _showGameResult() {
    String message;
    switch (_gameState.status) {
      case GameStatus.blackWin:
        message = '흑돌 승리!';
        break;
      case GameStatus.whiteWin:
        message = '백돌 승리!';
        break;
      case GameStatus.draw:
        message = '무승부!';
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('게임 종료'),
        content: Text(message),
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

  void _resetGame() {
    // 렌주룰 캐시 초기화
    AdvancedRenjuRuleEvaluator.clearCache();

    setState(() {
      _gameState = OmokGameLogic.resetGame();
      _showCountdown = true;
      _gameStarted = false;
    });
  }

  String _getCurrentPlayerText() {
    return _gameState.currentPlayer ==
            PlayerType.black
        ? '흑돌'
        : '백돌';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Omok Arena'),
        backgroundColor: Theme.of(
          context,
        ).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _resetGame,
            icon: const Icon(Icons.refresh),
            tooltip: '게임 초기화',
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 게임 상태 표시
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                ),
                child: Column(
                  children: [
                    Text(
                      '현재 턴: ${_getCurrentPlayerText()}',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '수 순서: ${_gameState.moves.length + 1}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge,
                    ),
                    if (_gameState.status !=
                        GameStatus.playing)
                      Container(
                        margin:
                            const EdgeInsets.only(
                              top: 8,
                            ),
                        padding:
                            const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius:
                              BorderRadius.circular(
                                20,
                              ),
                        ),
                        child: Text(
                          _gameState.status ==
                                  GameStatus
                                      .blackWin
                              ? '흑돌 승리!'
                              : _gameState
                                        .status ==
                                    GameStatus
                                        .whiteWin
                              ? '백돌 승리!'
                              : '무승부!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // 게임 보드
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                            16,
                          ),
                      child: SimpleRenjuWrapper(
                        gameState: _gameState,
                        onTileTap: _onTileTap,
                      ),
                    ),
                  ),
                ),
              ),

              // 하단 버튼들
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _resetGame,
                      icon: const Icon(
                        Icons.refresh,
                      ),
                      label: const Text('새 게임'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.of(
                            context,
                          ).pop(),
                      icon: const Icon(
                        Icons.home,
                      ),
                      label: const Text('홈으로'),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 카운트다운 오버레이
          GameCountdownOverlay(
            showCountdown: _showCountdown,
            onCountdownComplete:
                _onCountdownComplete,
          ),
        ],
      ),
    );
  }
}
