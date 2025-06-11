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
    // 화면 크기 정보 가져오기
    final screenSize = MediaQuery.of(
      context,
    ).size;
    final isSmallScreen = screenSize.height < 700;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFDF7E3), // 새로운 배경색
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableHeight =
                  constraints.maxHeight;
              return SingleChildScrollView(
                physics:
                    const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: availableHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 16.0,
                          ),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          // 게임 로고/제목
                          Container(
                            padding:
                                const EdgeInsets.all(
                                  16,
                                ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFFFD966,
                              ), // 새로운 버튼 색상
                              shape:
                                  BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors
                                      .black
                                      .withOpacity(
                                        0.15,
                                      ),
                                  blurRadius: 20,
                                  offset:
                                      const Offset(
                                        0,
                                        8,
                                      ),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.grid_on,
                              size: isSmallScreen
                                  ? 48
                                  : 64,
                              color: const Color(
                                0xFF2D2D2D,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          // 게임 제목
                          Text(
                            'Omok Arena',
                            style: TextStyle(
                              fontSize:
                                  isSmallScreen
                                  ? 36
                                  : 48,
                              fontWeight:
                                  FontWeight.bold,
                              fontFamily:
                                  'Cafe24Ohsquare', // 타이틀 폰트
                              color: const Color(
                                0xFF2D2D2D,
                              ),
                              shadows: [
                                Shadow(
                                  offset:
                                      const Offset(
                                        2,
                                        2,
                                      ),
                                  blurRadius: 4,
                                  color:
                                      const Color(
                                        0xFFFFA3A3,
                                      ).withOpacity(
                                        0.3,
                                      ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          // 플레이 모드 선택 제목 (게임 설명 대체)
                          Container(
                            padding:
                                const EdgeInsets.all(
                                  12,
                                ),
                            margin:
                                const EdgeInsets.only(
                                  bottom: 12,
                                ),
                            decoration: BoxDecoration(
                              color:
                                  const Color(
                                    0xFFA3D8F4,
                                  ).withOpacity(
                                    0.3,
                                  ), // 보조 포인트 색상
                              borderRadius:
                                  BorderRadius.circular(
                                    12,
                                  ),
                              border: Border.all(
                                color:
                                    const Color(
                                      0xFFA3D8F4,
                                    ),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '🎮 플레이 모드 선택',
                                  style: TextStyle(
                                    color: const Color(
                                      0xFF2D2D2D,
                                    ),
                                    fontSize:
                                        isSmallScreen
                                        ? 16
                                        : 18,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    fontFamily:
                                        'SUIT', // 기본 텍스트 폰트
                                  ),
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  '13x13 / 17x17 / 21x21 보드\n렌주룰 적용 • 1수당 30초 제한 • 스킬 시스템',
                                  style: TextStyle(
                                    color:
                                        const Color(
                                          0xFF2D2D2D,
                                        ).withOpacity(
                                          0.8,
                                        ),
                                    fontSize:
                                        isSmallScreen
                                        ? 11
                                        : 13,
                                    height: 1.3,
                                    fontFamily:
                                        'Pretendard', // 서브 텍스트 폰트
                                  ),
                                  textAlign:
                                      TextAlign
                                          .center,
                                ),
                              ],
                            ),
                          ),

                          // 게임 모드 선택 버튼들
                          Column(
                            children: [
                              // 2인 플레이 버튼 (로컬 멀티플레이어)
                              SizedBox(
                                width: double
                                    .infinity,
                                height:
                                    isSmallScreen
                                    ? 60
                                    : 72,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _showBoardSizeDialog(
                                      context,
                                      isAI: false,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(
                                          0xFFFFD966,
                                        ), // 버튼 배경색
                                    foregroundColor:
                                        const Color(
                                          0xFF2D2D2D,
                                        ), // 메인 텍스트 색상
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                            12,
                                          ),
                                    ),
                                    elevation: 6,
                                    shadowColor:
                                        Colors
                                            .black
                                            .withOpacity(
                                              0.2,
                                            ),
                                    padding:
                                        const EdgeInsets.symmetric(
                                          horizontal:
                                              12,
                                          vertical:
                                              8,
                                        ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      Icon(
                                        Icons
                                            .people,
                                        size:
                                            isSmallScreen
                                            ? 24
                                            : 28,
                                        color: const Color(
                                          0xFF2D2D2D,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Flexible(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '2인 플레이 (로컬)',
                                              style: TextStyle(
                                                fontSize: isSmallScreen
                                                    ? 14
                                                    : 16,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'SUIT',
                                                color: const Color(
                                                  0xFF2D2D2D,
                                                ),
                                              ),
                                              maxLines:
                                                  1,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              '한 화면에서 두 명이 플레이',
                                              style: TextStyle(
                                                fontSize: isSmallScreen
                                                    ? 10
                                                    : 12,
                                                fontFamily: 'Pretendard',
                                                color:
                                                    const Color(
                                                      0xFF2D2D2D,
                                                    ).withOpacity(
                                                      0.7,
                                                    ),
                                              ),
                                              maxLines:
                                                  1,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 12,
                              ),

                              // 1인 플레이 버튼 (AI 대전)
                              SizedBox(
                                width: double
                                    .infinity,
                                height:
                                    isSmallScreen
                                    ? 60
                                    : 72,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _showBoardSizeDialog(
                                      context,
                                      isAI: true,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(
                                          0xFFFFA3A3,
                                        ), // 액센트 포인트 색상
                                    foregroundColor:
                                        const Color(
                                          0xFF2D2D2D,
                                        ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                            12,
                                          ),
                                    ),
                                    elevation: 6,
                                    shadowColor:
                                        Colors
                                            .black
                                            .withOpacity(
                                              0.2,
                                            ),
                                    padding:
                                        const EdgeInsets.symmetric(
                                          horizontal:
                                              12,
                                          vertical:
                                              8,
                                        ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      Icon(
                                        Icons
                                            .smart_toy,
                                        size:
                                            isSmallScreen
                                            ? 24
                                            : 28,
                                        color: const Color(
                                          0xFF2D2D2D,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Flexible(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '1인 플레이 (AI 대전)',
                                              style: TextStyle(
                                                fontSize: isSmallScreen
                                                    ? 14
                                                    : 16,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'SUIT',
                                                color: const Color(
                                                  0xFF2D2D2D,
                                                ),
                                              ),
                                              maxLines:
                                                  1,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              'AI와 대전하기 (개발 중)',
                                              style: TextStyle(
                                                fontSize: isSmallScreen
                                                    ? 10
                                                    : 12,
                                                fontFamily: 'Pretendard',
                                                color:
                                                    const Color(
                                                      0xFF2D2D2D,
                                                    ).withOpacity(
                                                      0.7,
                                                    ),
                                              ),
                                              maxLines:
                                                  1,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 16,
                              ),

                              // 추가 메뉴 버튼들
                              Row(
                                children: [
                                  // 게임 규칙 버튼
                                  Expanded(
                                    child: SizedBox(
                                      height:
                                          isSmallScreen
                                          ? 40
                                          : 48,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (
                                                    context,
                                                  ) => const GameRulesScreen(),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFA3D8F4,
                                          ).withOpacity(0.8),
                                          foregroundColor:
                                              const Color(
                                                0xFF2D2D2D,
                                              ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                4,
                                            vertical:
                                                4,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              size:
                                                  isSmallScreen
                                                  ? 14
                                                  : 16,
                                              color: const Color(
                                                0xFF2D2D2D,
                                              ),
                                            ),
                                            const SizedBox(
                                              height:
                                                  2,
                                            ),
                                            Flexible(
                                              child: Text(
                                                '게임 규칙',
                                                style: TextStyle(
                                                  fontSize: isSmallScreen
                                                      ? 9
                                                      : 11,
                                                  fontFamily: 'SUIT',
                                                  color: const Color(
                                                    0xFF2D2D2D,
                                                  ),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 12,
                                  ),

                                  // 캐릭터 도감 버튼
                                  Expanded(
                                    child: SizedBox(
                                      height:
                                          isSmallScreen
                                          ? 40
                                          : 48,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (
                                                    context,
                                                  ) => const LotteryScreen(),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFA3D8F4,
                                          ).withOpacity(0.8),
                                          foregroundColor:
                                              const Color(
                                                0xFF2D2D2D,
                                              ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                4,
                                            vertical:
                                                4,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.casino,
                                              size:
                                                  isSmallScreen
                                                  ? 14
                                                  : 16,
                                              color: const Color(
                                                0xFF2D2D2D,
                                              ),
                                            ),
                                            const SizedBox(
                                              height:
                                                  2,
                                            ),
                                            Flexible(
                                              child: Text(
                                                '캐릭터 뽑기',
                                                style: TextStyle(
                                                  fontSize: isSmallScreen
                                                      ? 9
                                                      : 11,
                                                  fontFamily: 'SUIT',
                                                  color: const Color(
                                                    0xFF2D2D2D,
                                                  ),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 24,
                          ),

                          // 버전 정보
                          Text(
                            'Omok Arena v1.0.0',
                            style: TextStyle(
                              color: const Color(
                                0xFF2D2D2D,
                              ).withOpacity(0.5),
                              fontSize: 12,
                              fontFamily:
                                  'Pretendard',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
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
        backgroundColor: const Color(0xFFFDF7E3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Color(0xFFA3D8F4),
            width: 2,
          ),
        ),
        title: Text(
          '보드 크기 선택',
          style: TextStyle(
            fontFamily: 'Cafe24Ohsquare',
            color: const Color(0xFF2D2D2D),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '게임할 보드 크기를 선택하세요:',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: const Color(
                  0xFF2D2D2D,
                ).withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
            ...BoardSize.values.map(
              (size) => Card(
                color: const Color(
                  0xFFFFD966,
                ).withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                  side: const BorderSide(
                    color: Color(0xFFFFD966),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  leading: Icon(
                    _getBoardSizeIcon(size),
                    color: _getBoardSizeColor(
                      size,
                    ),
                  ),
                  title: Text(
                    size.description,
                    style: const TextStyle(
                      fontFamily: 'SUIT',
                      color: Color(0xFF2D2D2D),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${size.size}x${size.size} 보드',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: const Color(
                        0xFF2D2D2D,
                      ).withOpacity(0.7),
                    ),
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
            style: TextButton.styleFrom(
              backgroundColor: const Color(
                0xFFFFA3A3,
              ).withOpacity(0.8),
              foregroundColor: const Color(
                0xFF2D2D2D,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(8),
              ),
            ),
            onPressed: () =>
                Navigator.of(context).pop(),
            child: const Text(
              '취소',
              style: TextStyle(
                fontFamily: 'SUIT',
                fontWeight: FontWeight.bold,
              ),
            ),
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
