import 'package:flutter/material.dart';
import 'character_selection_screen.dart';
import 'lottery_screen.dart';
import 'game_rules_screen.dart';

import '../models/player_profile.dart';
import '../logic/ai_player.dart';
import '../widgets/enhanced_visual_effects.dart';
import '../core/constants/index.dart';

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
        decoration: BoxDecoration(
          color: AppColors
              .background, // 키치 테마 배경색 적용
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
                          // 🎨 v2.0.0: 게임 로고 + 타이틀 스택 (겹치기)
                          // 호랑이+토끼 캐릭터 이미지와 "Omok Arena" 타이틀을 Stack으로 겹치게 배치
                          // 캐릭터의 바둑돌이 타이틀 'k'에 거의 닿을 정도로 밀착 배치
                          Container(
                            height: isSmallScreen
                                ? 240
                                : 280,
                            child: Stack(
                              alignment: Alignment
                                  .center,
                              children: [
                                // 캐릭터 이미지 (위쪽)
                                Positioned(
                                  top: 0,
                                  child: Image.asset(
                                    'assets/image/home_logo.png',
                                    width:
                                        isSmallScreen
                                        ? 450
                                        : 550,
                                    height:
                                        isSmallScreen
                                        ? 225
                                        : 275,
                                    fit: BoxFit
                                        .contain,
                                    errorBuilder:
                                        (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Container(
                                            padding: const EdgeInsets.all(
                                              16,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  AppColors.secondary,
                                              shape:
                                                  BoxShape.circle,
                                              border: Border.all(
                                                color: AppColors.secondaryContainer,
                                                width: 2,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.grid_on,
                                              size:
                                                  isSmallScreen
                                                  ? 48
                                                  : 64,
                                              color:
                                                  AppColors.primary,
                                            ),
                                          );
                                        },
                                  ),
                                ),

                                // 게임 제목 (아래쪽으로 이동해서 캐릭터와 겹치게)
                                Positioned(
                                  bottom: 0,
                                  child: Text(
                                    'Omok Arena',
                                    style: TextStyle(
                                      fontSize:
                                          isSmallScreen
                                          ? 42
                                          : 52,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                      fontFamily:
                                          'Cafe24Ohsquare',
                                      color: AppColors
                                          .primary,
                                      shadows: [
                                        Shadow(
                                          offset:
                                              const Offset(
                                                2,
                                                2,
                                              ),
                                          blurRadius:
                                              4,
                                          color: AppColors
                                              .tertiary
                                              .withOpacity(
                                                0.3,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 플레이 모드 선택 제목 - Cloud BG 효과 적용 (간소화)
                          CloudContainer(
                            margin:
                                const EdgeInsets.only(
                                  bottom: 4,
                                ),
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                            child: Text(
                              '🎮 플레이 모드 선택',
                              style: TextStyle(
                                color: AppColors
                                    .primary, // 키치 테마 텍스트 색상
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
                              textAlign: TextAlign
                                  .center,
                            ),
                          ),

                          // 게임 모드 선택 버튼들 (3개 버튼 비율 조정)
                          Column(
                            children: [
                              // 온라인 플레이 버튼 - 새로 추가 (퍼플 계열)
                              VolumetricPlayButton(
                                onPressed: () {
                                  // TODO: 온라인 플레이 기능 구현
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        '온라인 플레이 기능 개발 중입니다!',
                                      ),
                                      duration:
                                          Duration(
                                            seconds:
                                                2,
                                          ),
                                    ),
                                  );
                                },
                                text:
                                    '🌐 온라인 플레이',
                                width: double
                                    .infinity,
                                height:
                                    isSmallScreen
                                    ? 56
                                    : 66,
                                backgroundColor:
                                    AppColors
                                        .accent1, // 미디엄 슬레이트 블루
                              ),

                              const SizedBox(
                                height: 2,
                              ),

                              // 2인 플레이 버튼 - 입체적 효과 적용 (블루 계열)
                              VolumetricPlayButton(
                                onPressed: () {
                                  _showBoardSizeDialog(
                                    context,
                                    isAI: false,
                                  );
                                },
                                text:
                                    '👥 2인 플레이 (로컬)',
                                width: double
                                    .infinity,
                                height:
                                    isSmallScreen
                                    ? 56
                                    : 66,
                                backgroundColor:
                                    AppColors
                                        .accent2, // 로열 블루
                              ),

                              const SizedBox(
                                height: 2,
                              ),

                              // 1인 플레이 버튼 - 입체적 효과 적용 (다크 퍼플 계열)
                              VolumetricPlayButton(
                                onPressed: () {
                                  _showBoardSizeDialog(
                                    context,
                                    isAI: true,
                                  );
                                },
                                text:
                                    '🤖 1인 플레이 (AI 대전)',
                                width: double
                                    .infinity,
                                height:
                                    isSmallScreen
                                    ? 56
                                    : 66,
                                backgroundColor:
                                    AppColors
                                        .accent3, // 다크 슬레이트 블루
                              ),

                              const SizedBox(
                                height: 3,
                              ),

                              // 추가 메뉴 버튼들 - Overflow 해결
                              Row(
                                children: [
                                  // 게임 규칙 버튼
                                  Expanded(
                                    child: Container(
                                      height: 30,
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
                                          padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                8,
                                            vertical:
                                                2,
                                          ),
                                          minimumSize:
                                              Size(
                                                0,
                                                30,
                                              ),
                                        ),
                                        child: Row(
                                          mainAxisSize:
                                              MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              size:
                                                  12,
                                              color:
                                                  AppColors.primary,
                                            ),
                                            const SizedBox(
                                              width:
                                                  4,
                                            ),
                                            Flexible(
                                              child: Text(
                                                '게임 규칙',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontFamily: 'SUIT',
                                                  color: AppColors.primary,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 8,
                                  ),

                                  // 캐릭터 뽑기 버튼
                                  Expanded(
                                    child: Container(
                                      height: 30,
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
                                          padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                8,
                                            vertical:
                                                2,
                                          ),
                                          minimumSize:
                                              Size(
                                                0,
                                                30,
                                              ),
                                        ),
                                        child: Row(
                                          mainAxisSize:
                                              MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.casino,
                                              size:
                                                  12,
                                              color:
                                                  AppColors.primary,
                                            ),
                                            const SizedBox(
                                              width:
                                                  4,
                                            ),
                                            Flexible(
                                              child: Text(
                                                '캐릭터 뽑기',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontFamily: 'SUIT',
                                                  color: AppColors.primary,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
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
                            height: 12,
                          ),

                          // 버전 정보 - 키치 테마 적용
                          AccentText(
                            text:
                                'Omok Arena v1.0.0',
                            style: TextStyle(
                              fontSize: 8,
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
        backgroundColor: AppColors.surfaceHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: AppColors.tertiary,
            width: 2,
          ),
        ),
        title: Text(
          '🎯 보드 크기 선택',
          style: TextStyle(
            fontFamily: 'Cafe24Ohsquare',
            color: AppColors.primary,
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
                color: AppColors.primary
                    .withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
            ...BoardSize.values.map(
              (size) => Card(
                color: AppColors.secondary
                    .withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                  side: BorderSide(
                    color: AppColors.tertiary,
                    width: 2,
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
                    style: TextStyle(
                      fontFamily: 'SUIT',
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${size.size}x${size.size} 보드',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: AppColors.primary
                          .withOpacity(0.7),
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
              backgroundColor:
                  AppColors.secondary,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12),
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
        backgroundColor: AppColors.surfaceHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: AppColors.tertiary,
            width: 2,
          ),
        ),
        title: Text(
          '🤖 AI 난이도 선택',
          style: TextStyle(
            fontFamily: 'Cafe24Ohsquare',
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'AI 난이도를 선택하세요:',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: AppColors.primary,
              ),
            ),
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
            style: TextButton.styleFrom(
              backgroundColor:
                  AppColors.secondary,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12),
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

  Widget _buildDifficultyCard(
    BuildContext context,
    AIDifficulty difficulty,
    String title,
    String description,
    Color color,
  ) {
    return Card(
      color: AppColors.secondary.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.tertiary,
          width: 2,
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.smart_toy,
          color: color,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'SUIT',
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: AppColors.primary.withOpacity(
              0.7,
            ),
          ),
        ),
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
