import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../logic/omok_game_logic.dart';
import '../widgets/simple_game_board.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState _gameState;

  @override
  void initState() {
    super.initState();
    _gameState = GameState();
  }

  void _onTileTap(int row, int col) {
    if (_gameState.status != GameStatus.playing) {
      return;
    }

    setState(() {
      _gameState = OmokGameLogic.makeMove(_gameState, row, col);
    });

    // 게임 종료 시 결과 표시
    if (_gameState.status != GameStatus.playing) {
      _showGameResult();
    }
  }

  void _showGameResult() {
    String message;
    Color resultColor;
    switch (_gameState.status) {
      case GameStatus.blackWin:
        message = '흑돌 승리! 🎉';
        resultColor = const Color(0xFF424242);
        break;
      case GameStatus.whiteWin:
        message = '백돌 승리! 🎉';
        resultColor = const Color(0xFFE0E0E0);
        break;
      case GameStatus.draw:
        message = '무승부! 🤝';
        resultColor = const Color(0xFFFFC107);
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white, width: 2),
        ),
        title: Text(
          '게임 종료',
          style: TextStyle(
            fontFamily: 'Cafe24Ohsquare',
            fontSize: 24,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          message,
          style: TextStyle(
            fontFamily: 'Cafe24Ohsquare',
            fontSize: 20,
            color: resultColor,
            letterSpacing: -0.3,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFigmaButton(
                text: '다시 시작',
                color: const Color(0xFF4CAF50),
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetGame();
                },
                width: 100,
                fontSize: 14,
              ),
              _buildFigmaButton(
                text: '홈으로',
                color: const Color(0xFF2196F3),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                width: 100,
                fontSize: 14,
              ),
            ],
          ),
        ],
        actionsPadding: const EdgeInsets.all(16),
      ),
    );
  }

  // 홈 화면 스타일의 Figma 버튼
  Widget _buildFigmaButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
    double width = 120,
    double fontSize = 16,
  }) {
    return Container(
      width: width,
      height: 40,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: width,
              height: 40,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignOutside,
                    color: Color(0x590A0A0A),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Container(
                decoration: ShapeDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.00, -1.00),
                    end: Alignment(0, 1),
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 3, color: Colors.white),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 8,
            top: 4,
            right: 8,
            child: Container(
              height: 32,
              child: GestureDetector(
                onTap: onPressed,
                child: Center(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontFamily: 'Cafe24Ohsquare',
                      height: 0,
                      letterSpacing: -0.20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    setState(() {
      _gameState = GameState();
    });
  }

  String _getCurrentPlayerText() {
    return _gameState.currentPlayer == PlayerType.black ? '흑돌' : '백돌';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 홈 화면과 동일한 검은색 배경
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Omok Arena',
          style: TextStyle(
            fontFamily: 'Cafe24Ohsquare',
            fontSize: 22,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _resetGame,
            icon: const Icon(Icons.refresh, color: Colors.white, size: 24),
            tooltip: '게임 초기화',
          ),
        ],
      ),
      body: Column(
        children: [
          // 게임 상태 표시 (홈 화면 스타일)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // 현재 턴 표시
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.00, -1.00),
                      end: Alignment(0, 1),
                      colors: [
                        _gameState.currentPlayer == PlayerType.black
                            ? const Color(0xFF424242)
                            : const Color(0xFFE0E0E0),
                        (_gameState.currentPlayer == PlayerType.black
                                ? const Color(0xFF424242)
                                : const Color(0xFFE0E0E0))
                            .withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    '현재 턴: ${_getCurrentPlayerText()}',
                    style: TextStyle(
                      fontFamily: 'Cafe24Ohsquare',
                      fontSize: 18,
                      color: _gameState.currentPlayer == PlayerType.black
                          ? Colors.white
                          : Colors.black,
                      letterSpacing: -0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 12),

                // 수 순서 표시
                Text(
                  '수 순서: ${_gameState.moves.length + 1}',
                  style: TextStyle(
                    fontFamily: 'Cafe24Ohsquare',
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                    letterSpacing: -0.3,
                  ),
                ),

                // 게임 결과 표시
                if (_gameState.status != GameStatus.playing)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0.00, -1.00),
                        end: Alignment(0, 1),
                        colors: [
                          _gameState.status == GameStatus.blackWin
                              ? const Color(0xFF424242)
                              : _gameState.status == GameStatus.whiteWin
                              ? const Color(0xFFE0E0E0)
                              : const Color(0xFFFFC107),
                          (_gameState.status == GameStatus.blackWin
                                  ? const Color(0xFF424242)
                                  : _gameState.status == GameStatus.whiteWin
                                  ? const Color(0xFFE0E0E0)
                                  : const Color(0xFFFFC107))
                              .withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Text(
                      _gameState.status == GameStatus.blackWin
                          ? '🎉 흑돌 승리! 🎉'
                          : _gameState.status == GameStatus.whiteWin
                          ? '🎉 백돌 승리! 🎉'
                          : '🤝 무승부! 🤝',
                      style: TextStyle(
                        fontFamily: 'Cafe24Ohsquare',
                        fontSize: 18,
                        color: _gameState.status == GameStatus.whiteWin
                            ? Colors.black
                            : Colors.white,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),

          // 게임 보드 - 깔끔하게 중앙에 배치
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: SimpleGameBoard(
                        gameState: _gameState,
                        onTileTap: _onTileTap,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 하단 버튼들 (홈 화면 스타일)
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFigmaButton(
                  text: '다시 시작',
                  color: const Color(0xFF4CAF50),
                  onPressed: _resetGame,
                ),
                _buildFigmaButton(
                  text: '홈으로',
                  color: const Color(0xFF2196F3),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                _buildFigmaButton(
                  text: '항복',
                  color: const Color(0xFFF44336),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Colors.white, width: 2),
                        ),
                        title: Text(
                          '항복하시겠습니까?',
                          style: TextStyle(
                            fontFamily: 'Cafe24Ohsquare',
                            fontSize: 20,
                            color: Colors.white,
                            letterSpacing: -0.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildFigmaButton(
                                text: '취소',
                                color: const Color(0xFF757575),
                                onPressed: () => Navigator.of(context).pop(),
                                width: 80,
                                fontSize: 14,
                              ),
                              _buildFigmaButton(
                                text: '항복',
                                color: const Color(0xFFF44336),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                                width: 80,
                                fontSize: 14,
                              ),
                            ],
                          ),
                        ],
                        actionsPadding: const EdgeInsets.all(16),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
