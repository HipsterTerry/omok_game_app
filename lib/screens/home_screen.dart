import 'package:flutter/material.dart';
import 'character_selection_screen.dart';
import 'lottery_screen.dart';
import 'game_rules_screen.dart';
import '../models/player_profile.dart';
import '../logic/ai_player.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1565C0),
              Color(0xFF42A5F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                // 게임 로고/제목
                Container(
                  padding: const EdgeInsets.all(
                    24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(
                          0,
                          10,
                        ),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.grid_on,
                    size: 80,
                    color: Color(0xFF1565C0),
                  ),
                ),

                const SizedBox(height: 32),

                // 게임 제목
                const Text(
                  'Omok Arena',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 4,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 게임 설명
                const Text(
                  '홀수 보드에서 5목을 완성하세요!\n13x13 / 17x17 / 21x21',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // 게임 모드 선택 버튼들
                Column(
                  children: [
                    // 멀티플레이어 버튼
                    ElevatedButton(
                      onPressed: () {
                        _showBoardSizeDialog(
                          context,
                          isAI: false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.white,
                        foregroundColor:
                            const Color(
                              0xFF1565C0,
                            ),
                        padding:
                            const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 16,
                            ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                30,
                              ),
                        ),
                        elevation: 8,
                      ),
                      child: const Row(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people,
                            size: 28,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '멀티플레이어',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // AI 대전 버튼
                    ElevatedButton(
                      onPressed: () {
                        _showAIDifficultyDialog(
                          context,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.orange,
                        foregroundColor:
                            Colors.white,
                        padding:
                            const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 16,
                            ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                30,
                              ),
                        ),
                        elevation: 8,
                      ),
                      child: const Row(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.smart_toy,
                            size: 28,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'AI와 대전',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 추가 메뉴 버튼들
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    // 복권 센터 버튼
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const LotteryScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.card_giftcard,
                      ),
                      label: const Text('복권 센터'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.purple,
                        foregroundColor:
                            Colors.white,
                        padding:
                            const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                20,
                              ),
                        ),
                        elevation: 4,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // 게임 방법 버튼
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const GameRulesScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.rule,
                      ),
                      label: const Text('게임 방법'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            Colors.white,
                        side: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                        padding:
                            const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                20,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                // 버전 정보
                const Text(
                  'Omok Arena v1.0.0',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBoardSizeDialog(
    BuildContext context, {
    bool isAI = false,
    AIDifficulty? aiDifficulty,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('보드 크기 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('게임할 보드 크기를 선택하세요:'),
            const SizedBox(height: 16),
            ...BoardSize.values.map(
              (size) => Card(
                child: ListTile(
                  leading: Icon(
                    _getBoardSizeIcon(size),
                    color: _getBoardSizeColor(
                      size,
                    ),
                  ),
                  title: Text(size.description),
                  subtitle: Text(
                    '${size.size}x${size.size} 보드',
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _startGame(
                      context,
                      size,
                      isAI: isAI,
                      aiDifficulty: aiDifficulty,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  IconData _getBoardSizeIcon(BoardSize size) {
    switch (size) {
      case BoardSize.small:
        return Icons.grid_3x3;
      case BoardSize.medium:
        return Icons.grid_4x4;
      case BoardSize.large:
        return Icons.apps;
    }
  }

  Color _getBoardSizeColor(BoardSize size) {
    switch (size) {
      case BoardSize.small:
        return Colors.green;
      case BoardSize.medium:
        return Colors.orange;
      case BoardSize.large:
        return Colors.red;
    }
  }

  void _showAIDifficultyDialog(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI 난이도 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('AI 난이도를 선택하세요:'),
            const SizedBox(height: 16),
            _buildDifficultyCard(
              context,
              AIDifficulty.easy,
              '🟢 쉬움',
              '초보자용 - AI가 무작위로 수를 둡니다',
              Colors.green,
            ),
            const SizedBox(height: 8),
            _buildDifficultyCard(
              context,
              AIDifficulty.normal,
              '🟡 보통',
              '중급자용 - 기본적인 공격/수비 전략을 사용합니다',
              Colors.orange,
            ),
            const SizedBox(height: 8),
            _buildDifficultyCard(
              context,
              AIDifficulty.hard,
              '🔴 어려움',
              '고급자용 - 고급 전략과 수읽기를 사용합니다',
              Colors.red,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyCard(
    BuildContext context,
    AIDifficulty difficulty,
    String title,
    String description,
    Color color,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.smart_toy,
          color: color,
        ),
        title: Text(title),
        subtitle: Text(description),
        onTap: () {
          Navigator.of(context).pop();
          _startGame(
            context,
            BoardSize.medium,
            isAI: true,
            aiDifficulty: difficulty,
          );
        },
      ),
    );
  }

  void _showGameRules(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('게임 규칙'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🎯 목표',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '13x13 보드에서 자신의 돌 5개를 연속으로 놓아 5목을 완성하면 승리합니다.',
              ),
              SizedBox(height: 16),
              Text(
                '🎮 게임 방법',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• 흑돌이 먼저 시작합니다\n• 턴마다 한 개씩 돌을 놓습니다\n• 가로, 세로, 대각선 중 하나로 5개가 연결되면 승리\n• 빈 자리에만 돌을 놓을 수 있습니다',
              ),
              SizedBox(height: 16),
              Text(
                '🏆 승리 조건',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '자신의 돌 5개가 연속으로 연결되면 즉시 승리합니다.\n보드가 가득 차면 무승부입니다.',
              ),
            ],
          ),
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

  void _startGame(
    BuildContext context,
    BoardSize boardSize, {
    bool isAI = false,
    AIDifficulty? aiDifficulty,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CharacterSelectionScreen(
              boardSize: boardSize,
              isAIGame: isAI,
              aiDifficulty: aiDifficulty,
            ),
      ),
    );
  }
}
